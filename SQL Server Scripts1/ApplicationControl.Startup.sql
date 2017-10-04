/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2014 (12.0.5000)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2014
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [DWH_Archive]
GO

/****** Object:  StoredProcedure [dbo].[ApplicationControl.Startup]    Script Date: 05-Oct-17 8:38:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













-- ===========================================================================
-- Author:		Adrian Bell
-- Create date: 20/08/2015
-- Description:	Preloads the ApplicationControl table at the start of a new DWH installation
--
-- Update history:
--		23/8/2017 - JDJ: added missing jobs, changed default JobID value to 1000...
						

-- Calling Arguments:
--		JobID			Tells the SP who called it, which will then allow it to look up the run params 

--	1. Associate this SP with JobID = 1000 :
--				Exec dbo.[ApplicationControl.Startup] '1000'
--

-- ===========================================================================


CREATE PROCEDURE [dbo].[ApplicationControl.Startup] (
	@JobID		INT				=0 
	)			-- The Calling Program or Service name
AS
	BEGIN
		Set NoCount On;

-- set up most ov the variables and pre-plug them with default values

	Declare @Mode			Varchar(32)		= 'Sync',			-- Mode is always 'Sync'
			@LoggingFlag	Varchar (1)		= 'Y'				-- Set to 'Y' to write to table ApplicationErrorLog, else 'N'
	
	Declare	@USN			nVarchar (64)	= 'Executed by Unknown Job ''' + ltrim(str(@JobID)) + '''' + '(' + @Mode + ' Mode)' ,
			@ProcName		varchar(64),
			@Starting		datetime,
			@Ending			datetime,
			@MergedRows		int = 0,
			@InsertedRows	int = 0,
			@ProvidedRows	int = 0,
			@ErrorReturned	int = 0,
			@ReturnStatus	int = 0,
			@Inserted		Int = 0,
			@Updated		Int = 0,
			@Deleted		Int = 0,
			@InsertStatus	int = 0,
			@Debug			varchar(1) = 'N',
			@InsertCount	Int = 0,
			@UpdateCount	Int = 0,
			@DeleteCount	Int = 0


	If @Debug = 'Y'  Select @JobID = 1000;								-- debugging setting

	select @ProcName=OBJECT_NAME(@@PROCID),
			@Starting = Getdate();
		
	If @Debug = 'Y'
		Begin
			print @Mode
			Print @LoggingFlag
			PRINT @USN
		END	;
 
	Truncate table [DWH_Archive].[dbo].[ApplicationControl]

	Insert into [DWH_Archive].[dbo].[ApplicationControl] values ('1000','Fetch External Data','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1100','Fetch Manad Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1200','Fetch PS Finance Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1205','Fetch PSFinance Tables (FinanceOnly)','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1300','Fetch PS HR Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1400','Fetch Carelink Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1500','Fetch EPASAsh Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1550','Fetch EPASKog Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1600','Fetch LSD Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('1700','Fetch GrantsManagement Tables','Sync','30',NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2000','Archive External Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2100','Archive Manad Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2200','Archive PS Finance Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2205','Insert PSFinance Archive Tables (FinanceOnly)','Sync',NULL,NULL,'Y') 
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2300','Archive PS HR Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2400','Archive Carelink Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2500','Archive ePAS (Ash) Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2550','Archive ePAS (Kog) Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2600','Archive LSD Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('2700','Archive GrantsManagement Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('3000','Insert BI Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('3005','Insert BI Tables (Finance Only)','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('3100','Insert KPI Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('3200','Insert Mums and Kids Matter tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('3600','Insert LSD_BI tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('4000','Publish BI Datamarts','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('4005','Publish BI Datamarts (Finance Only)','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('4600','Publish LSD_BI Datamart','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('5000','Rebuild TM1 Cubes','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('5005','Rebuild TM1 Cubes (Finance Only)','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('5600','Rebuild LSD_BI TM1 Cube','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('9000','Update Logging Tables','Sync',NULL,NULL,'Y')
	INSERT INTO [DWH_Archive].[dbo].[ApplicationControl] VALUES ('9600','Update LSD Logging Tables','Sync',NULL,NULL,'Y')
		 

END 

	RETURN @ErrorReturned		-- Advise the calling program the original error return from the insert












GO



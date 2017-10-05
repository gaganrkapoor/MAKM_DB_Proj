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

/****** Object:  StoredProcedure [dbo].[Work.MAKM.CarePlanGoals.Insert]    Script Date: 05-Oct-17 9:51:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- ===========================================================================
-- Author:		Gagan Kapoor
-- Create date: 07/09/2017
-- Description:	Insert into Work.MAKM.CarePlanGoals from CareLink+ tables in DWH_Archive DB
--				The table has the meeting details (Meeting date and Meeting Status) from the MAKM care Plan template under the 'Meetings and Reviews' tab
--
-- Update History   
--			04/10/2017 GK: test for git, this is the initial changed version
-- Calling Arguments:
--		JobID			Tells the SP who called it, which will then allow it to look up the run params 

--	1. Associate this SP with JobID = 3100 :
--				Exec dbo.[Work.MAKM.CarePlanGoals.Insert] '3200'
--
--
-- ===========================================================================


CREATE Procedure [dbo].[Work.MAKM.CarePlanGoals.Insert] (
	@JobID		Int				=0
	)			-- The Calling Program or Service name
as
	Begin
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


		If @Debug = 'Y' 	Select @JobID = 3100	;								-- debugging setting


	Select	@LoggingFlag	= isnull(LoggingFlag,'Y'),
			@USN			= 'Executed by Job ''' + ltrim(str(@JobID)) + '''' + '(' + @Mode + ' Mode)'
	From	[DWH_Archive].dbo.[ApplicationControl]
	Where	[JobID] = @JobID
			

		select @ProcName=OBJECT_NAME(@@PROCID),
				@Starting = Getdate();
		
	If @Debug = 'Y'
		Begin
			print @Mode
			Print @LoggingFlag
			Print @USN
		End	;		
		
	DECLARE @StartFetchDate DATE = '2015-07-01',
			@DWHLoadedDate DateTime = getDate()

BEGIN TRY

TRUNCATE TABLE [dbo].[Work.MAKM.CarePlanGoals]

INSERT INTO /*WDWH_OT*/[dbo].[Work.MAKM.CarePlanGoals]
 
	
  -- outcomes dataset
select ID, OriginalName, FilledFormId, DateCreated,AcpSectionId AS GoalID, SectionName AS GoalName,FilledSubSectionId,ClientID, PersonID, LastName,firstName, [Goal] AS Goal, Convert(Date,[Target Date],103) AS TargetDate, Convert(Date,[Date Completed],103) AS DateCompleted
 FROM 
(
 
Select	t.ID,t.OriginalName, QA.FilledFormId, FF.DateCreated,asq.AcpSectionId, s.SectionName,QA.FilledSubSectionId,C.ClientID, FF.PersonId, p.LastName, p.Firstname, aq.QuestionText, 
CASE 
	WHEN a.AnswerText IS NOT NULL THEN a.AnswerText
	WHEN a.AnswerNumeric IS NOT NULL THEN CONVERT(NVARCHAR(15), a.AnswerNumeric)
	WHEN a.AnswerTime IS NOT NULL THEN CONVERT(NVARCHAR(15), a.AnswerTime, 103)
	ELSE NULL
END AS Answer
from /*WDWH_IT*/ dbo.[Carelink.acpSectionQuestion] asq 
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.acpquestion] aq		on asq.AcpQuestionId = aq.Id and aq.IsActive = 1
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.acpquestionanswer] QA ON QA.SectionQuestionID = asq.ID  and QA.IsActive = 1  
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.ACPAnswer] A			ON a.Id= QA.AnswerId and A.IsActive = 1
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.AcpSection] S			ON S.Id = asq.AcpSectionId and S.IsActive = 1

INNER JOIN/*WDWH_IT*/ dbo.[Carelink.AcpFilledForm] FF		ON FF.Id = QA.FilledFormId and ff.IsActive = 1
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.AcpTemplateVersion] TV ON TV.Id = FF.AcpTemplateVersionId AND TV.IsActive = 1
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.AcpTemplate]	T		ON T.Id = TV.AcpTemplateId and T.IsActive = 1 
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.Person] P			on p.PersonID = ff.PersonId and p.Active = 1
INNER JOIN/*WDWH_IT*/ dbo.[Carelink.Client] C			on C.PersonID = P.PersonId AND c.Active=1

where aq.QuestionText IN ('Goal', 'Target Date', 'Date Completed')
and asq.IsActive = 1
AND t.OriginalName = 'Makm Care Plan'

 ) a 
 pivot
 (
 MAX(a.Answer) FOR a.QuestionText IN ([Goal], [Target Date], [Date Completed])
 ) AS piv

 

	Set @InsertedRows	= @@ROwCount
	Set @ErrorReturned	= @@Error
	Set	@Ending			= getdate()

 
	---------- -- Audit logging 

		Insert into [DWH_Archive].[dbo].ApplicationRunLog
		Select	DB_Name() as HostDB, 
				@ProcName as StoredProc, 
				@Mode as RunMode,
				Null as SelectKey1,
				Null as SelectKey2,
				@Starting as StartDateTime, 
				@Ending as EndDateTime, 
				@ProvidedRows as RowsRead, 
				@InsertedRows as Inserted,
				0 as Updated,
				@ErrorReturned as ErrorCode
											
END TRY
	
BEGIN CATCH 
			Declare @ErrorNum Int = Error_Number () ,
					@ErrorMsg NVarchar (4000) = Error_Message(),
					@ErrorProc NVarchar(126) = Error_Procedure(),
					@ErrorSeverity Int = ERROR_SEVERITY() ,
					@ErrorState Int = ERROR_STATE(),
					@ErrorLine Int = ERROR_LINE()
			Declare @DataError NVarchar (4000) = 'Error '+ Convert (nvarchar (10), @ErrorNum)
					+ ' in package (' + @ErrorProc + ')'  
					+ ', Error Details: ' + @ErrorMsg 
					+ '(Severity ' + Convert (nvarchar (5), @ErrorSeverity) 
					+ '/ State '  + Convert (nvarchar (5), @ErrorState) 
					+ '/ Line '  + Convert (nvarchar (5), @ErrorLine) + ')'

			RaisError (@DataError, @ErrorSeverity, @ErrorState);
			
			Insert into dbo.ApplicationErrorLog 
			values (
					GetDate(),
					@USN,
					@ErrorProc,
					@ErrorLine,
					@ErrorNum,
					@ErrorMsg ,
					@ErrorSeverity,
					@ErrorState );
END CATCH

END;















GO



--Create Database--
create database covid19
go

--Use-Database--

use Covid19
go

--Create-tables--
create table Zones
(
zoneid int not null primary key,
zonename nvarchar(30) not null
)
go
create table Areas
(
areaid int not null primary key,
areaname nvarchar(30) not null,
currentzone int not null references zones(zoneid)
)
go

create table Dailyrecords
(
[Date] date not null,
areaid int not null references Areas(areaid),
newcase int null,
deathcase int null,
curedcase int null,
primary key ([Date],areaid)
)
go
create table zonetracks
(
zonetrackid int identity primary key,
areaid int not null references Areas(areaid),
zoneid int not null references Zones(zoneid),
lastupdate DATE not null
)
go
--Views--

CREATE VIEW todaysrecords
AS
SELECT  dailyrecords.date, areas.areaname, dailyrecords.newcase, dailyrecords.deathcase, dailyrecords.curedcase, zones.zonename, areas.currentzone
FROM   dailyrecords INNER JOIN
areas ON dailyrecords.areaid = areas.areaid INNER JOIN
zones ON areas.currentzone = zones.zoneid INNER JOIN
zonetracks ON areas.areaid = zonetracks.areaid AND zones.zoneid = zonetracks.zoneid
where cast([Date] as date) = cast(getdate() as date)
go
CREATE view vCaseRecord 
AS
SELECT DR.AreaID ,[Date], AreaName, NewCase, DeathCase, curedcase 
FROM DailyRecords DR
INNER JOIN Areas AR ON DR.AreaID = AR.AreaId

GO
--Insert -Procedure--

CREATE PROC spInsertZone @id int,
@ZoneName NVARCHAR(20)
AS

BEGIN TRY 

INSERT INTO Zones (zoneid, ZoneName)
VALUES (@id, @ZoneName)
END TRY

BEGIN CATCH
	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
GO

--Update-Pprocedure-For-"Zones"

CREATE PROC spUpdateZone @ZoneID int, @ZoneName NVARCHAR(20)

AS
BEGIN TRY
	UPDATE Zones
	SET  ZoneName = ISNULL(@ZoneName,ZoneName)
	WHERE Zoneid = @ZoneID
END TRY
BEGIN CATCH
	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
GO
-- Delete-Procedure  from "Zones" ---------

CREATE PROC spDeleteZone
@ZoneId int
AS
BEGIN TRY
	DELETE Zones WHERE Zoneid=@ZoneId
END TRY
BEGIN CATCH
	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
GO


--Insert-Procedure-for-"Areas"----

create PROC spInsertAreas @id int, @AreaName NVARCHAR(20), @CurrentZone INT
AS
BEGIN TRY 

INSERT INTO Areas(areaid, AreaName,CurrentZone)
VALUES (@id,@AreaName,@CurrentZone)
END TRY

BEGIN CATCH

	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
GO

-- Update-Procedure--for--"Area"--- 
CREATE PROC spUpdateAreas @AreaID int, @AreaName NVARCHAR(20),@CurrentZone int
AS
BEGIN TRY
	UPDATE Areas
	SET  AreaName = ISNULL(@AreaName,AreaName), CurrentZone = ISNULL(@CurrentZone, CurrentZone)
	WHERE AreaId = @AreaID
END TRY
BEGIN CATCH
	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
GO
-- procedure to delete from "Area" 

CREATE PROC spDeleteArea @AreaId int
AS
BEGIN TRY
	DELETE Areas WHERE AreaId=@AreaId
END TRY
BEGIN CATCH
	DECLARE @msg  NVARCHAR (1000)
	SELECT @msg = ERROR_MESSAGE()
	RAISERROR(@msg, 16,1)
END CATCH
								
GO
create PROC spInsertDailyRecords @Date DATE, @AreaID NVARCHAR(10), @NewCase INT, @DeathCase INT, @Cure INT
AS
BEGIN TRY

		INSERT INTO DailyRecords ([Date],AreaID,NewCase,DeathCase,curedcase ) VALUES
		(@Date,@AreaID, @NewCase,@DeathCase,@Cure)
END TRY
BEGIN CATCH
	print ERROR_MESSAGE()
	RAISERROR('Inserted already', 11, 1)
END CATCH
GO

-- procedure to update "DailyRecords"

CREATE PROC spUpdateDailyRecords @Date DATE, @AreaID int, @NewCases INT, @DeathCases INT, @Cured INT
AS
	UPDATE DailyRecords
	SET  Date = ISNULL(@Date,Date),NewCase = ISNULL(@NewCases,NewCase),
	     DeathCase= ISNULL(@DeathCases,DeathCase),curedcase = ISNULL(@Cured,curedcase)
	WHERE areaId = @AreaID AND CAST([Date] as DATE) = @date
GO



--proc for deleting "DailyRecords" 

CREATE PROC spDeleteFromDailyRecords @AreaID int, @Date DATE
AS
BEGIN TRY
	 DELETE FROM DailyRecords
	 WHERE AreaID = @AreaID AND CAST([Date] AS date) = @Date
	 --Date = @Date
END TRY

BEGIN CATCH
	RAISERROR('Data can not be Deleted', 11, 1)
END CATCH
GO
-----procedure to records

CREATE FUNCTION spCaseRecord (
	@Area NVARCHAR(20),
	@StartDate DATE,
	@EndDate DATE ) RETURNS TABLE
AS
CREATE FUNCTION fnCaseRecord (
	@Area INT,
	@StartDate DATE,
	@EndDate DATE ) RETURNS TABLE
AS
RETURN (SELECT DR.AreaID ,[Date], AreaName, NewCase, DeathCase, curedcase 
FROM DailyRecords DR
INNER JOIN Areas AR ON DR.AreaID = AR.AreaId
WHERE AR.areaid = @Area AND  Date BETWEEN @StartDate AND '2022-03-31'
)
GO
create function totalDeaths(@areaid int) returns int
as
begin
declare @c int 
SELECT       @c=SUM(deathcase) 
FROM            dailyrecords
where areaid = @areaid
return @c
end
go
create function totalCases(@areaid int) returns int
as
begin
declare @c int 
SELECT       @c=SUM(newcase) 
FROM            dailyrecords
where areaid = @areaid
return @c
end
go
CREATE FUNCTION fnAreaSummary(@areaid INT) RETURNS TABLE
AS
RETURN (
SELECT        areaid, SUM(deathcase) as deaths, sum(curedcase) as cured, sum(newcase) as infected
FROM            dailyrecords
group by areaid
having areaid=@areaid
)
GO
create function areainzone(@zoneid int)
	returns table
as
return (
select * from areas
where currentzone=@zoneid
)
go
--triggers
create trigger trchangezoneoninsert
on dailyrecords
after insert
as
begin 
	declare @d date, @aid int, @nc int, @i INT
	SELECT  @d =[date], @aid=areaid,@nc=NewCase  from inserted
	if @nc >=20
	begin
			update areas
			set currentzone = 3
			where areaid = @aid

			insert into zonetracks (areaid, zoneid, lastupdate)
			values(@aid, 3, getdate())
		end
	else if @nc >=10
	begin
			update areas
			set currentzone = 2
			where areaid = @aid

			insert into zonetracks (areaid, zoneid, lastupdate)
			values(@aid, 2, getdate())
		end
	else
	begin
			update areas
			set currentzone = 2
			where areaid = @aid

			insert into zonetracks (areaid, zoneid, lastupdate)
			values( @aid, 1, getdate())
	end
	
end
go
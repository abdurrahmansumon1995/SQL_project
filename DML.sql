use covid19
go
insert into Zones values
(1,'Red'),(2,'Yellow'),(3,'Green')
go
insert into Areas values
(1,'Mirpur',1),(2,'Motijheel',2)
go

insert into Dailyrecords values
('2022-01-01',1,55,23,11),('2022-01-02',2,23,4,2)
go
insert into zonetracks values
(1,1,'2022-01-01'),(1,2,'2022-01-02'),(1,1,'2022-01-03')
go
select*from Areas
go
select*from Zones
go
select*from Dailyrecords
go
select*from zonetracks
go
select Dr.[Date],a.areaid,a.areaname,z.zoneid,zt.zonetrackid,zt.lastupdate,z.zonename,
a.currentzone,Dr.newcase,Dr.deathcase,Dr.curedcase
from Areas a
inner join zonetracks zt on a.areaid=zt.areaid
inner join Zones z on z.zoneid=zt.zoneid
inner join Areas a1 on a1.currentzone=z.zoneid
inner join Dailyrecords Dr on a1.areaid=Dr.areaid
GO
-- test view
select * from todaysrecords
go
select * from vCaseRecord
go
--test procedures

EXEC spInsertZone 4, 'Blue'
GO
SELECT * FROM Zones
GO
EXEC spUpdateZone @ZoneID = 3 , @ZoneName = 'White'
GO 
SELECT * FROM Zones
GO
EXEC spUpdateZone @ZoneID = 3 , @ZoneName = 'Red'
GO 
SELECT * FROM Zones
GO
EXEC spDeleteZone 4
GO
SELECT * FROM Zones
GO

Exec spInsertAreas 3,'Mohammadpur',1
Exec spInsertAreas 4, 'Uttara',1
-- 
Exec spInsertAreas 5, 'Gulshan',2
Exec spInsertAreas 6, 'Dhanmondi',2

Exec spInsertAreas 7,'Sutrapur',3
Exec spInsertAreas 8,'Nobabgonj',3
Exec spInsertAreas 9, 'Keranigonj',3
Exec spInsertAreas 10,'Narayangonj',3
GO
--
SELECT * FROM Areas
go
EXEC spUpdateAreas @AreaID = 10, @AreaName = 'Khilkhet', @CurrentZone = 3
GO
SELECT * FROM Areas
GO
Exec spDeleteArea 10
GO
SELECT * FROM Areas
GO
EXEC spInsertDailyRecords '2022-01-06',1,123,23,63
EXEC spInsertDailyRecords '2022-01-06',2,65,20,25
DECLARE @d DATE = GETDATE()
EXEC spInsertDailyRecords @d,2,65,20,25
GO
SELECT * FROM Dailyrecords
GO
Exec spUpdateDailyRecords '2022-01-06', 1,120,6,9
GO
SELECT * FROM DailyRecords
GO
Exec spDeleteFromDailyRecords 1, '2022-01-06'
GO
SELECT * FROM DailyRecords
go
--test function
SELECT * FROM fnCaseRecord(1, '2022-01-01', GETDATE())
GO
select * from fnAreaSummary(1)
go
select * from areainzone(3)
go
select dbo.totalCases(1)
go
select dbo.totalDeaths(1)
go
--test trigger

EXEC spInsertDailyRecords '2022-01-09',2,65,20,25

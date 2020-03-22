#------------------------------------------------------Schema Creation------------------------------------------------------#
create schema assignment;

/* Created below tables using 'Table Data Import Wizard' after create the schema 'Assignment'
1. bajaj_auto
2. eicher_motors
3. hero_motocorp
4. infosys
5. tcs
6. tvs_motors*/

#------------------------------ Converting 'Date' Column Datatype from Text to Date------------------------------------------#
SET SQL_SAFE_UPDATES = 0;
UPDATE `bajaj_auto`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table bajaj_auto modify column `Date` date; -- Data Type Conversion
 
UPDATE `eicher_motors`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table eicher_motors modify column `Date` date; -- Data Type Conversion

UPDATE `hero_motocorp`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table hero_motocorp modify column `Date` date; -- Data Type Conversion

UPDATE `infosys`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table infosys modify column `Date` date; -- Data Type Conversion

UPDATE `tcs`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table tcs modify column `Date` date; -- Data Type Conversion

UPDATE `tvs_motors`
SET `date` = str_to_date(`date`, '%d-%M-%Y');  -- set the column format 
alter table tvs_motors modify column `Date` date; -- Data Type Conversion



#------- 1. Create a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA  (This has to do for all 6 stocks)----------------------#

#-----------------------------------------Bajaj1------------------------------------------------#

CREATE TABLE bajaj1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert bajaj1 
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from bajaj_auto;

#------------------------------------------Eicher1----------------------------------------------#
CREATE TABLE eicher1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert eicher1 
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from eicher_motors;
#-------------------------------------------Heromotocorp1-----------------------------------------#
CREATE TABLE heromotocorp1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert heromotocorp1 
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from hero_motocorp;

#-----------------------------------------------Infosys1--------------------------------------------#
CREATE TABLE infosys1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert infosys1
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from infosys;


#---------------------------------------------------Tcs1-----------------------------------------------#
CREATE TABLE tcs1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert tcs1
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from tcs;
#--------------------------------------------------Tvs_motors1-------------------------------------------#
CREATE TABLE tvs_motors1 (
    Date DATE,
    `Close Price` DOUBLE,
    `20 Day MA` DOUBLE,
    `50 Day MA` DOUBLE
);

insert tvs_motors1
select Date, `Close Price`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA` from tvs_motors;


#-------------------------------------------------------------------------------------------------------------------------------------------#

# 2. Create a master table containing the date and close price of all the six stocks. (Column header for the price is the name of the stock)#

CREATE TABLE Master_Table (
    Date DATE,
    `Bajaj` DOUBLE,
    `TCS` DOUBLE,
    `TVS` DOUBLE,
    `Infosys` DOUBLE,
    `Eicher` DOUBLE,
    `Hero` DOUBLE
);

insert into master_table(Date, Bajaj, TCS, TVS, Infosys, Eicher, Hero) 
 select b.Date,
 b.`Close Price`,
     t.`Close Price`,
    tv.`Close Price`,
    i.`Close Price`,
    e.`Close Price`,
    h.`Close Price`
FROM
    bajaj1 b
        LEFT JOIN
    tcs1 t ON t.Date = b.Date
        LEFT JOIN
    tvs_motors1 tv ON tv.Date = b.Date
        LEFT JOIN
    infosys1 i ON i.Date = b.Date
        LEFT JOIN
    eicher1 e ON e.Date = b.Date
        LEFT JOIN
    heromotocorp1 h ON h.Date = b.Date
ORDER BY b.Date;

#-------------------------------------------------------------------------------------------------------------------------------------------------------#
#3. Use the table created in Part(1) to generate buy and sell signal. Store this in another table named 'bajaj2'. Perform this operation for all stocks.#

#--------------------------------------------------bajaj2-------------------------------------------#
CREATE TABLE bajaj2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into bajaj2 (Date,`Close Price`,`Signal`) 
WITH CTE_Bajaj2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   bajaj1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_Bajaj2
ORDER BY Date;
 #--------------------------------------------------eicher2-------------------------------------------#
CREATE TABLE eicher2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into eicher2 (Date,`Close Price`,`Signal`) 
WITH CTE_eicher2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   eicher1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_eicher2
ORDER BY Date;

 #--------------------------------------------------heromotocorp2--------------------------------------#
CREATE TABLE heromotocorp2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into heromotocorp2 (Date,`Close Price`,`Signal`) 
WITH CTE_heromotocorp2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   heromotocorp1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_heromotocorp2
ORDER BY Date;
 #--------------------------------------------------infosys2-------------------------------------------#
CREATE TABLE infosys2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into infosys2 (Date,`Close Price`,`Signal`) 
WITH CTE_infosys2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   infosys1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_infosys2
ORDER BY Date;

 #--------------------------------------------------tcs2-----------------------------------------------#
 CREATE TABLE tcs2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into tcs2 (Date,`Close Price`,`Signal`) 
WITH CTE_tcs2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   tcs1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_tcs2
ORDER BY Date;

 #--------------------------------------------------tvs_motors2-------------------------------------------#
   CREATE TABLE tvs_motors2 (
    Date DATE,
    `Close Price` DOUBLE,
    `Signal` Text
 );
 
 insert into tvs_motors2 (Date,`Close Price`,`Signal`) 
WITH CTE_tvsmotors2 (Date,`Close Price`,RowNumber,`20 Day MA`,`50 Day MA`)
AS
(
SELECT Date,
		`Close Price`,
       ROW_NUMBER() OVER (ORDER BY Date ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   tvs_motors1
)
SELECT Date,
       `Close Price`,
       CASE
          WHEN RowNumber > 49 AND `20 Day MA` > `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) < lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Buy'
          WHEN RowNumber > 49 AND `20 Day MA` < `50 Day MA` and lag(`20 Day MA`,1,Null) over (order by Date asc) > lag(`50 Day MA`,1,Null) over (order by Date asc) THEN 'Sell'
          ELSE 'Hold'
       END as `Signal`
FROM   CTE_tvsmotors2
ORDER BY Date;



#------------------------------------------------------------------User defined function------------------------------------------------------------------------#

# 4. Create a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock

CREATE FUNCTION BAJAJ_SIGNAL (DT date)
	returns char(50) deterministic
	return (SELECT 
    `Signal`
FROM
    bajaj2
WHERE
    Date = DT);

SELECT BAJAJ_SIGNAL('2015-05-18') AS `Signal`;

#--------------------------------------------------------------- The End ----------------------------------------------------------------------------#













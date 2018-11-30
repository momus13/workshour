/*USE [yourdatabase];*/

/*
 * Table for works calendar
 */

CREATE TABLE work_hours
(
    id INT IDENTITY PRIMARY KEY,
    dateTest SMALLDATETIME NOT NULL,
    idCalendar SMALLINT NOT NULL,
    workHour SMALLINT DEFAULT 0 NOT NULL
);
CREATE INDEX work_hours_uindex ON work_hours (idCalendar, dateTest);
GO

/*
 * Table for works schedule
 */

create table lunch_hours
(
    id SMALLINT IDENTITY PRIMARY KEY,
    beginWork SMALLINT NOT NULL,
    endWork SMALLINT NOT NULL,
    beginLunch SMALLINT NOT NULL,
    endLunch SMALLINT NOT NULL
);
GO

/*
 * Insert work hours for you standard calendar
 * week - hour for weekday, week first day - sunday, default sunday & saturday - weekend
 */

CREATE PROCEDURE insert_works_hour @start DATE, @stop DATE, @calendar SMALLINT, @week CHAR(7) ='0888880'
AS
DECLARE @rows INT;
  BEGIN
    SET @rows = 0;
    WHILE (@start < @stop)
      BEGIN
        INSERT INTO work_hours (idCalendar,dateTest,workHour) VALUES (@calendar,@start,CAST(SUBSTRING(@week, datepart(weekday, @start)+1,1) as smallint));
        SET @start = DATEADD(DAY, 1, @start);
        SET @rows = @rows + 1;
      END
    RETURN @rows;
  END
GO

/*
 * Insert work hours for you custom calendar
 * days - array hour, for loop insertion. One day - two numeral, include zero, without separator (0001020304 e.t.c.)
 */

CREATE PROCEDURE insert_custom_works_hour @start DATE, @stop DATE, @calendar SMALLINT, @days VARCHAR(100) = '12120000'
AS
 DECLARE @rows INTEGER;
 DECLARE @cnt INTEGER;
 DECLARE @i INTEGER;
 BEGIN
  SET @rows = 0;
  SET @i = 1;
  SET @cnt = LEN(@days);
  WHILE @start < @stop
   BEGIN
    INSERT INTO work_hours (idCalendar,dateTest,workHour) VALUES (@calendar,@start,CAST(SUBSTRING(@days,@i,2) as SMALLINT));
    SET @start = DATEADD(DAY,1,@start);
    SET @rows = @rows + 1;
    SET @i = @i + 2;
    IF @i > @cnt
     SET @i = 1;
   END;
 RETURN @rows;
 END;
GO

/*
 * Calculate work hours
 */

CREATE FUNCTION take_works_hour (@start DATETIME, @stop DATETIME, @calendar INTEGER, @schedule INTEGER)
 RETURNS INTEGER
 AS
BEGIN
 DECLARE @hours INTEGER;
 DECLARE @bw SMALLINT;
 DECLARE @ew SMALLINT;
 DECLARE @w1 SMALLINT;
 DECLARE @w2 SMALLINT;
 DECLARE @w3 SMALLINT;
 DECLARE @w4 SMALLINT;
 IF @schedule > 0
  BEGIN
   SELECT @w1 = beginWork, @w2 = endWork, @w3 = beginLunch, @w4 = endLunch from lunch_hours where id = @schedule;
   SET @hours = @w1 - @w3 + @w4;
   SELECT @w2 = @hours + workHour from work_hours where dateTest = cast(@start as DATE) and idCalendar = @calendar;
    SET @bw = DATEPART(HOUR,@start);
    IF @bw < @w1
     SET @bw = 0;
     ELSE
      IF @bw > @w2
       SET @bw = @w2 - @hours;
       ELSE
        IF @bw > @w3
        SET @bw = @w3 - @w4 + (case when @bw > @w4 then @bw else @w4 end) - @w1;
        ELSE
         SET @bw = @bw - @w1;
   SELECT @w2 = @hours + workHour from work_hours where dateTest = cast(@stop as DATE) and idCalendar = @calendar;
    SET @ew = DATEPART(HOUR,@stop);
    IF @ew < @w1
     SET @ew = @w2 - @hours;
     ELSE
      IF @ew > @w2
       SET @ew = 0;
       ELSE
        IF @ew > @w4
         SET @ew = @w2 - @ew;
         ELSE
          SET @ew = @w2 - (case when @ew > @w3 then @w4 else @ew - @w3 + @w4 end);
   END
  ELSE
   BEGIN
    SET @bw = 0;
    SET @ew = 0;
   END
  SELECT @hours = sum(workHour) from work_hours where dateTest >= cast(@start as DATE) and dateTest <= cast(@stop as DATE) and idCalendar = @calendar;
 RETURN @hours-@bw-@ew;
END;

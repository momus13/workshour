/*USE `yourschema`;*/

/*
 * Table for works calendar
 */

CREATE TABLE work_hours
(
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    dateTest DATE NOT NULL,
    idCalendar SMALLINT NOT NULL,
    workHour SMALLINT DEFAULT 0 NOT NULL
);
CREATE UNIQUE INDEX work_hours_uindex ON work_hours (idCalendar, dateTest);

/*
 * Table for works schedule
 */

create table lunch_hours
(
	id SMALLINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
	beginWork SMALLINT NOT NULL,
	endWork SMALLINT NOT NULL,
	beginLunch SMALLINT NOT NULL,
	endLunch SMALLINT NOT NULL
);

/*
 * Insert work hours for you standard calendar
 * week - hour for weekday, week first day - monday, for null - default saturday & sunday - weekend
 */

DELIMITER $$
CREATE PROCEDURE insert_works_hour(start DATE, stop DATE, calendar SMALLINT, week CHAR(7), OUT rows INT)
  BEGIN
    SET rows = 0;
    IF week IS NULL THEN
      SET week = '8888800';
    END IF;
    WHILE start < stop DO
      INSERT INTO work_hours (idCalendar,dateTest,workHour) VALUES (calendar,start,CAST(SUBSTRING(week, WEEKDAY(start)+1,1) as SIGNED));
      SET start = DATE_ADD(start, INTERVAL 1 DAY);
      SET rows = rows + 1;
    END WHILE;
END$$

/*
 * Insert work hours for you custom calendar
 * days - array hour, for loop insertion. One day - two numeral, include zero, without separator (0001020304 e.t.c.)
 */

DELIMITER $$
CREATE FUNCTION insert_custom_works_hour (start DATE, stop DATE, calendar INTEGER, days VARCHAR(100))
	RETURNS INTEGER
BEGIN
	DECLARE rows INTEGER;
	DECLARE cnt INTEGER;
	DECLARE i INTEGER;
	SET rows = 0;
	SET i := 1;
	SET cnt =	LENGTH(days);
  WHILE (start < stop) DO
      INSERT INTO work_hours (idCalendar,dateTest,workHour) VALUES (calendar,start,CAST(SUBSTRING(days,i,2) as SIGNED));
      SET start = DATE_ADD(start, INTERVAL 1 DAY);
			SET rows = rows + 1;
			SET i = i + 2;
		IF i > cnt THEN
			SET i = 1;
		END IF;
    END WHILE;
	RETURN rows;
END$$
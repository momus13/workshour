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
 * week - hour for weekday, week first day - monday, for null - default sunday & saturday - weekend
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
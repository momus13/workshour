-- SET search_path TO yourschema;

/*
 * Table for works calendar
 */

create table work_hours
(
	id serial not null constraint work_hours_pkey primary key,
	"dateTest" date not null,
	"idCalendar" smallint not null,
	"workHour" smallint default 0 not null
);

create unique index work_hours_uindex on work_hours ("idCalendar", "dateTest");

/*
 * Table for works schedule
 */

create table lunch_hours
(
	id smallserial not null constraint lunch_hours_pkey primary key,
	"beginWork" smallint not null,
	"endWork" smallint not null,
	"beginLunch" smallint not null,
	"endLunch" smallint not null
);

/*
 * Insert work hours for you standard calendar
 * week - hour for weekday, week first day - sunday, default sunday & saturday - weekend
 */

CREATE FUNCTION insert_works_hour (start DATE, stop DATE, calendar INTEGER, week CHAR(7) DEFAULT '0888880')
	RETURNS INTEGER
AS $$
DECLARE rows INTEGER;
BEGIN
	rows := 0;
  WHILE (start < stop) LOOP
      INSERT INTO work_hours ("idCalendar","dateTest","workHour") VALUES (calendar,start,cast(substring(week, cast(EXTRACT(dow FROM start) as INT)+1,1) as smallint));
      start := start + interval '1 day';
			rows := rows + 1;
    END LOOP;
	RETURN rows;
END;
$$ LANGUAGE plpgsql;

/*
 * Insert work hours for you custom calendar
 * days - array hour, for loop insertion
 */

CREATE FUNCTION insert_custom_works_hour (start DATE, stop DATE, calendar INTEGER, days SMALLINT[])
	RETURNS INTEGER
AS $$
	DECLARE rows INTEGER;
	DECLARE cnt INTEGER;
	DECLARE i INTEGER;
BEGIN
	rows := 0;
	i := 1;
	cnt :=	array_length(days,1);
  WHILE (start < stop) LOOP
      INSERT INTO work_hours ("idCalendar","dateTest","workHour") VALUES (calendar,start,cast(days[i] as smallint));
      start := start + interval '1 day';
			rows := rows + 1;
			i := i +1;
		IF i > cnt THEN
			i := 1;
		END IF;
    END LOOP;
	RETURN rows;
END;
$$ LANGUAGE plpgsql;

/*
 * Calculate work hours
 */

CREATE FUNCTION take_works_hour (start TIMESTAMP, stop TIMESTAMP, calendar INTEGER, schedule INTEGER)
	RETURNS INTEGER
AS $$
	DECLARE hours INTEGER;
	DECLARE bw SMALLINT;
	DECLARE ew SMALLINT;
	DECLARE w1 SMALLINT;
	DECLARE w2 SMALLINT;
	DECLARE w3 SMALLINT;
	DECLARE w4 SMALLINT;
BEGIN
	IF schedule > 0 THEN
		SELECT "beginWork", "endWork", "beginLunch", "endLunch" INTO w1,w2,w3,w4 from lunch_hours where id = schedule;
		hours := w1 - w3 + w4;
		SELECT hours + "workHour" INTO w2 from work_hours where "dateTest" = cast(start as date) and "idCalendar" = calendar;
			bw := EXTRACT(HOUR FROM start);
			IF bw < w1 THEN
				bw := 0;
				ELSEIF bw > w2 THEN
					bw := w2 - hours;
					ELSEIF bw > w3 THEN
						bw := w3 - w4 + (case when bw > w4 then bw else w4 end) - w1;
						ELSE
							bw := bw - w1;
			END IF;
		SELECT hours + "workHour" INTO w2 from work_hours where "dateTest" = cast(stop as date) and "idCalendar" = calendar;
			ew := EXTRACT(HOUR FROM stop);
			IF ew < w1 THEN
				ew := w2 - hours;
				ELSEIF ew > w2 THEN
					ew := 0;
					ELSEIF ew > w4 THEN
						ew := w2 - ew;
						ELSE
							ew := w2 - (case when ew > w3 then w4 else ew - w3 + w4 end);
			END IF;
		ELSE
			bw := 0;
			ew := 0;
		END IF;
		SELECT sum("workHour") INTO hours from work_hours where "dateTest" >= cast(start as date) and "dateTest" <= cast(stop as date) and "idCalendar" = calendar;
	RETURN hours-bw-ew;
END;
$$ LANGUAGE plpgsql;

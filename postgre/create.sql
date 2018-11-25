-- SET search_path TO yourschema;

/*
 * Table for works calendar
 */

create table work_hours
(
	id smallserial not null constraint work_hours_pkey primary key,
	"dateTest" date not null,
	"idCountry" smallint not null,
	"workHour" smallint default 0 not null
);

create unique index work_hours_uindex on work_hours ("idCountry", "dateTest");

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
 * Insert work hours for you country
 * week - hour for weekday, week first day - sunday, default sunday & saturday - weekend
 */

CREATE FUNCTION insert_works_hour (start DATE, stop DATE, country INTEGER, week CHAR(7) DEFAULT '0888880')
	RETURNS INTEGER
AS $$
DECLARE rows INTEGER;
BEGIN
	rows = 0;
  WHILE (start < stop) LOOP
      INSERT INTO work_hours ("idCountry","dateTest","workHour") VALUES (country,start,cast(substring(week, cast(EXTRACT(dow FROM start) as INT)+1,1) as smallint));
      start := start + interval '1 day';
			rows := rows + 1;
    END LOOP;
	RETURN rows;
END;
$$ LANGUAGE plpgsql;

/*
 * Calculate work hours
 */

CREATE FUNCTION take_works_hour (start TIMESTAMP, stop TIMESTAMP, country INTEGER, schedule INTEGER)
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
	SELECT sum("workHour") INTO hours from work_hours where "dateTest" >= start and "dateTest" < stop + interval '1 day' and "idCountry" = country;
	SELECT "beginWork", "endWork", "beginLunch", "endLunch" INTO w1,w2,w3,w4 from lunch_hours where id = schedule;
		bw := EXTRACT(HOUR FROM start);
		ew := EXTRACT(HOUR FROM stop);
		IF bw < w1 THEN
			bw := 0;
			ELSEIF bw > w2 THEN
				bw := w2 - w1 + w3 - w4;
				ELSEIF bw > w3 THEN
					bw := w3 - w4 + (case when bw > w4 then bw else w4 end) - w1;
					ELSE
						bw := bw - w1;
		END IF;
		IF ew < w1 THEN
			ew := w2 - w1 + w3 - w4;
			ELSEIF ew > w2 THEN
				ew := 0;
				ELSEIF ew > w4 THEN
					ew := w2 - ew;
					ELSE
						ew := w2 - (case when ew > w3 then w4 else ew - w3 + w4 end);
		END IF;
	RETURN hours-bw-ew;
END;
$$ LANGUAGE plpgsql;




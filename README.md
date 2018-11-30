#### For PostgreSQL:
*min version 9.4*

1. Change you schemas
2. Create tables and function
3. Fill work calendar<br />
    SELECT * FROM insert_works_hour(begin date include,end date not include,your calendar id);<br />
    *for the sample:*<br />
        `SELECT * FROM insert_works_hour('2018-01-01','2020-01-01',1);`<br />
        or<br />
        `SELECT * FROM insert_custom_works_hour('2018-01-01','2020-01-01',2,'{12,12,0,0}');`
4. Update table work_hours for personale holidays and short days for you country<br />
    for the sample:<br />
        `update work_hours set "workHour"=0 where "dateTest"='2019-01-01' and "idCalendar"=1;`<br />
    make an automatic data parser for your country
5. Fill schedule calendar
    INSERT INTO lunch_hours ("beginWork","endWork","beginLunch","endLunch") VALUES (hour begin work,hour end work,hour begin lunch,hour end lunch);<br />
    for the sample:<br />
        `INSERT INTO lunch_hours ("beginWork","endWork","beginLunch","endLunch") VALUES (9,18,13,14);`
6. Use<br />
    select take_works_hour(datetime begin period,datetime end period,your calendar id,your scheduler id);<br />
    if scheduler id = 0 calculated for full day<br />
    for the sample:<br />
        `select take_works_hour('2018-07-01 15:05:22','2018-10-01 19:00:05',1,1);`
        
#### For MySQL:
*min version 5.6*

1. Change you database
2. Create tables and function
3. Fill work calendar<br />
    call insert_works_hour(begin date include,end date not include,your calendar id,you week work hours);<br />
    for the sample:<br />
        `call insert_works_hour('2018-01-01','2020-01-01',1,null,@a);
        select @a;`<br />
        or<br />
        `select insert_custom_works_hour('2018-01-01','2020-01-01',1,'12120000');`
4. Update table work_hours for personale holidays and short days for you country<br />
    for the sample:<br />
        `update work_hours set workHour=0 where dateTest='2019-01-01' and idCalendar=1;`<br />
    make an automatic data parser for your country
5. Fill schedule calendar<br />
    INSERT INTO lunch_hours (beginWork,endWork,beginLunch,endLunch) VALUES (hour begin work,hour end work,hour begin lunch,hour end lunch);<br />
    for the sample:<br />
        `INSERT INTO lunch_hours (beginWork,endWork,beginLunch,endLunch) VALUES (9,18,13,14);`
6. Use<br />
    select take_works_hour(datetime begin period,datetime end period,your calendar id,your scheduler id);<br />
    if scheduler id = 0 calculated for full day<br />
    for the sample:<br />
        `select take_works_hour('2018-07-01 15:05:22','2018-10-01 19:00:05',1,1);`
        
#### For MS SQL:
*min version 2008*

1. Change you database
2. Create tables and function
3. Fill work calendar<br />
    execute insert_works_hour(begin date include,end date not include,your calendar id,you week work hours);<br />
    for the sample:<br />
        `execute insert_works_hour @start='2018-01-01',@stop='2020-01-01',@calendar = 1;`<br />
        or<br />
        `execute insert_custom_works_hour @start='2020-01-02',@stop='2020-10-01',@calendar = 1, @schedule = '12120000'';`
4. Update table work_hours for personale holidays and short days for you country<br />
    for the sample:<br />
        `update work_hours set workHour=0 where dateTest='2019-01-01' and idCalendar=1;`<br />
    make an automatic data parser for your country
5. Fill schedule calendar<br />
    INSERT INTO lunch_hours (beginWork,endWork,beginLunch,endLunch) VALUES (hour begin work,hour end work,hour begin lunch,hour end lunch);<br />
    for the sample:<br />
        `INSERT INTO lunch_hours (beginWork,endWork,beginLunch,endLunch) VALUES (9,18,13,14);`
6. Use<br />
    select take_works_hour(datetime begin period,datetime end period,your calendar id,your scheduler id);<br />
    if scheduler id = 0 calculated for full day<br />
    for the sample:<br />
        `select dbo.take_works_hour('2018-11-21 1:02:41','2018-12-01 15:00:14',1,1);`
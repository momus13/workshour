For PostgreSQL:

1. Change you schemas
2. Create tables and function
3. Fill work calendar
    SELECT * FROM insert_works_hour(begin date include,end date not include,your calendar id);
    for the sample:
        SELECT * FROM insert_works_hour('2018-01-01','2020-01-01',1);
        or
        SELECT * FROM insert_custom_works_hour('2018-01-01','2020-01-01',2,'{12,12,0,0}');
4. Update table work_hours for personale holidays and short days for you country
    for the sample:
        update work_hours set "workHour"=0 where "dateTest"='2019-01-01' and "idCalendar"=1;
    make an automatic data parser for your country
5. Fill schedule calendar
    INSERT INTO lunch_hours ("beginWork","endWork","beginLunch","endLunch") VALUES (hour begin work,hour end work,hour begin lunch,hour end lunch);
    for the sample:
        INSERT INTO lunch_hours ("beginWork","endWork","beginLunch","endLunch") VALUES (9,18,13,14);
6. Use
    select take_works_hour(datetime begin period,datetime end period,your calendar id,your scheduler id);
    if scheduler id = 0 calculated for full day
    for the sample:
        select take_works_hour('2018-07-01 15:05:22','2018-10-01 19:00:05',1,1);
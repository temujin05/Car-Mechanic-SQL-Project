--1.List car models (with brand name and model name ) to which at least one car evaluated belongs.
--Each model should appear only once in the result.Sort the list by brand then by 
--model name.

select cm_name,make
from carmechanic.m_car_model
left join carmechanic.m_car on model_id = cm_id
left join carmechanic.m_car_evaluation on c_id = car_id
group by cm_id,cm_name,make
having count(car_id) >= 1
order by make,cm_name;


--2.List the license plate number of cars having a repair with a cost greater than all
--repair cost of Toyota cars.Each license plate number should appear only once in the 
--result.

select distinct license_plate_number
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
where repair_cost >all 
(select repair_cost
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
join carmechanic.m_car_model on cm_id = model_id
where make = 'Toyota');

--3.List the license plate number of cars having a repair cost less than any repair cost 
--of a Suzuki car.Each license plate number should appear only once in the result.

select distinct license_plate_number
from carmechanic.m_car
join carmechanic.m_repair
on c_id = car_id
where repair_cost <any 
(select repair_cost
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
join carmechanic.m_car_model on model_id = cm_id
where make = 'Suzuki');


--4.List the name , address and tax number of mechanics who ever had a salary less than
--that of all mechanics who ever worked for the workshop name 'Harmat Kft'.Each mechanic
--should appear only once in the result.*

select m_name,m.address,tax_number
from carmechanic.m_mechanic m
join carmechanic.m_works_for on m_id = mechanic_id
where salary < all
(select  salary
from carmechanic.m_mechanic
join carmechanic.m_works_for on m_id = mechanic_id
join carmechanic.m_workshop on w_id = workshop_id
where w_name = 'Harmat Kft.')
group by m_name,m.address,tax_number;

--5.List the name of owner who has never owned an Opel car.

select o.o_name
from carmechanic.m_owner o
minus
select distinct o.o_name
from carmechanic.m_owns ow
inner join carmechanic.m_owner o on o.o_id = ow.owner_id
inner join carmechanic.m_car c on ow.car_id = c.c_id
inner join carmechanic.m_car_model m on c.model_id = m.cm_id
where m.make = 'Opel';





--6.List all data of cars that have never been evaluated?

select *
from carmechanic.m_car
where c_id not in (select car_id
from carmechanic.m_car_evaluation);

--7.List all data of cars that were first sold in 2006 or Opel make.

select * 
from carmechanic.m_car
where extract(year from first_sell_date) = 2006
union
select a.*
from carmechanic.m_car a
join carmechanic.m_car_model on cm_id = model_id
where make = 'Opel';

-- 8.List the name and identifier of workshop where no mechanics from Eger have 
--ever worked.The address of mechanic from Eger starts with 'Eger'.

select w_id,w_name
from carmechanic.m_workshop
where w_id not in (select distinct workshop_id
from carmechanic.m_works_for
join carmechanic.m_mechanic on m_id = mechanic_id
where address like 'Eger%');

--9.List all data of cars that have been owned someone living in Eger (i.e. someone whose
--address begin with 'Eger') and have been repaired in a workshop in Eger(i.e. in a 
--workshop where address starting with 'Eger').Each car should appear only once in the 
--result.

select *
from carmechanic.m_car
where c_id in (select car_id
from carmechanic.m_owner
join carmechanic.m_owns on o_id = owner_id
where address like 'Eger%')
and c_id in (select car_id
from carmechanic.m_repair
join carmechanic.m_workshop on w_id = workshop_id
where address like 'Eger%');



--10.List the license plate number of cars participating in the evaluations with the 
--5 highest evaluation prices.Also give the evaluation price along with license plate 
--numbers.Sort the list descending by the evaluation price.

select * from
(select license_plate_number, price
from carmechanic.m_car
join carmechanic.m_car_evaluation on c_id = car_id
where price is not null
order by price desc
fetch first 5 rows with ties)
order by price desc;

--11. List the license plate number of cars participating in the evaluations 
--with the 10 lowest evaluation price. Also give the evaluation prices along  with 
--the license plate numbers. Sort the list descending by evaluation price.

select * from
(select license_plate_number,price
from carmechanic.m_car
join carmechanic.m_car_evaluation on c_id = car_id
where price is not null
order by  price
fetch first 10 rows with ties)
order by price desc;


--12.List the average evaluation price of cars of each model where this average is 
--one of the lowest three. The models should be represented in the result by 
--their identifiers.

select model_id,avg(price)
from  carmechanic.m_car 
join carmechanic.m_car_evaluation on car_id = c_id
group by model_id
having avg(price) is not null
order by avg(price)
fetch first 3 rows with ties;


--13.List the total repair cost of cars of each model where this total cost is one of the 
--lowest five.The models should be represented in the result by their identifiers also 
--by their make and model names.

select cm_id,cm_name,make,sum(repair_cost)
from carmechanic.m_car 
join carmechanic.m_car_model on cm_id = model_id
join carmechanic.m_repair on c_id = car_id
group by cm_id,make,cm_name
having sum(repair_cost) is not null
order by sum(repair_cost)
fetch first 5 row with ties;

--14.List the mechanics with the two highest salaries who are currently working for 
--'Kobela Bt.' (i.e for whom the end of employment is not given). List only the mechanics 
--name and salary ,sorted descending by salary.

select * from
(select m_name,salary
from carmechanic.m_mechanic
join carmechanic.m_works_for on m_id = mechanic_id
join carmechanic.m_workshop on w_id = workshop_id
where w_name = 'Kobela Bt.'
and end_of_employment is null
and salary is not null
order by salary desc
fetch first 2 rows with ties)
order by salary desc;

--15.Create a table named 'relative' where the relatives of mechanics are stored.The table 
--should include the following columns (with arbitrary names):identifier(a string of exactly
--10 charcters;this is the primary key),name(a string of at most 40 chracters;must not be
--unknown),gender(a string at most 10 chracters), date of birth (date) and the mechanic 
--connected to this person (an integer of at most 5 digits) with a reference to 'm_mechanic' 
--table.Assign a name to each constraint.

CREATE TABLE relative (
  id CHAR(10 CHAR) CONSTRAINT pk_relative PRIMARY KEY,
  name VARCHAR2(40 CHAR) NOT NULL,
  gender VARCHAR2(10 CHAR),
  date_of_birth DATE,
  mechanic NUMBER(5) CONSTRAINT fk_relative  REFERENCES m_mechanic
);
--
--17.Create a table name 'insurance' including the following columns(with arbitrary names):
--insurance number (a string exactly 8 chracters;this is the primary key),
--a car identifier (an integer of at most 5 digits);
--the owner id (an integer of at most 5 digits);
--the owner's email address (a string of at most 40 chracters,must not be unknown),
--start and end date of insurance (date) and the monthly cost (an integer at most 5 
--digits and must be greater than 10000).The table should reference to the 'm_car' and 
--'m_owner' table.Assign a name to each constraint.


CREATE TABLE insurance (
  insurance_number CHAR(8 CHAR),
  car_id NUMBER(5),
  owner_id NUMBER(5),
  email VARCHAR2(40 CHAR) NOT NULL,
  start_date DATE,
  end_date DATE,
  monthly_cost NUMBER(5) CONSTRAINT check_cost CHECK(monthly_cost > 10000),
  CONSTRAINT fk_1 FOREIGN KEY(car_id) REFERENCES m_car,
  CONSTRAINT fk_2 FOREIGN KEY(owner_id) REFERENCES m_owner,
  CONSTRAINT pk_insurance PRIMARY KEY(insurance_number));

--18.Some mechanics took part in a refresher training.Create a table named 'training'
--including the following columns(with arbitrary names): identifier (a string of exactly
--10 chracters), names (a string of at most 20 chracters), description (a string of at most 
--50 chracters), the start and end dates of training(dates),cost (an integer of at most 5 
--digits), and the mechanic who took part in this training (an integer of at most 5 digits)
--with a reference to 'm_mechanic' table.The primary key consists of the training identifier 
--and mechanic identifier . Assign a name to each constraint.

CREATE TABLE training (
  id CHAR(10 CHAR),
  name VARCHAR2(20 CHAR),
  description VARCHAR2(50 CHAR),
  start_date DATE,
  end_date DATE,
  cost NUMBER(5),
  mechanic_id NUMBER(5) CONSTRAINT fk_training REFERENCES m_mechanic,
  CONSTRAINT pk_training PRIMARY KEY(id,mechanic_id)
);




--19. The mechanics decided to create a work plan specifying the assignment of mechanics to 
--workshops for each workday. Create a table named 'work_plan' including the following 
--columns(with arbitrary names) workday(date; with a default value of the current date),
--mechanic(an integer of at most 5 digits) with a reference to the 'm_mechanic' table,
--workshop(an integer of at most 5 digits) with a reference to the 'm_workshop' table and
--primary key of the table consists of the workday and the mechanic's identifier. Assign a name to each constraint.

CREATE TABLE work_plan (
    workday DATE DEFAULT SYSDATE,
    mechanic NUMBER(5),
    workshop NUMBER(5),
    CONSTRAINT ref_work_plan FOREIGN KEY (mechanic) REFERENCES m_mechanic,
    CONSTRAINT w_rf_work_plan FOREIGN KEY(workshop) REFERENCES m_workshop,
    CONSTRAINT pk_work_plan PRIMARY KEY (workday, mechanic)
);

--20.Add a new column to your 'm_mechanic' table.The new column should be named 'bonus', an 
--integer of at most 6 digits, and its value must be at least 2000.

ALTER TABLE m_mechanic
  ADD bonus NUMBER(6) CHECK(bonus >= 2000);

--21.Phone numbers of mechanics are no longer needed, so delete the 'phone' column from the 
--'m_mechanic' table.

alter table m_mechanic drop column phone;


--22. Delete the table 'm_owner' and m_owns'. Take into account the foreign keys referencing 
--these tables. You may use multiple statements to solve this take.

drop table m_owner cascade constraints purge;

drop table m_owns cascade constraints purge;

--23.Delete primary key constraint from 'm_owns' table.

ALTER TABLE m_owns
DROP PRIMARY KEY;



--
--24. Delete the tables 'm_works_for', 'm_workshop', and 'm_mechanic'. Take into account 
--the foreign keys referencing these tables. You may use multiple statements to 
--solve this task.

drop table m_works_for cascade constraints;
drop table m_workshop cascade constraints;
drop table m_mechanic cascade constraints;

--25.Insert cars from the 'carmechanic' schema into your 'm_car' table that ever had an owner
--with a last name of 'Jakab'(i.e. a name starting with Jakab and a space) and whose color is
--either 'gray' or 'blue'.

insert into m_car
select * 
from carmechanic.m_car
where c_id in(select car_id
from carmechanic.m_owns
join carmechanic.m_owner on o_id = owner_id
where o_name like 'Jakab %')
and color in ('gray','blue');

--26.Insert owners from 'carmechanic' schema into your 'm_owner' table who ever had a toyota 
--car.

insert into m_owner
select  o_id,o_name,address
from carmechanic.m_owner
join carmechanic.m_owns on o_id = owner_id
where car_id in(select c_id 
from carmechanic.m_car 
join carmechanic.m_car_model on model_id = cm_id
where make = 'Toyota');


--27.Insert car models with no cars from the 'carmechanic' schema into your 'm_car_model'
--table.

insert into m_car_model
select b.*
from carmechanic.m_car_model b
left join carmechanic.m_car on cm_id = model_id
where c_id is null;

--28.Insert car models with the string 'airbag' in their details from the carmechanic schema 
--into your 'm_car_model' table.

insert into m_car_model
select *
from carmechanic.m_car_model
where details like '%airbag%';

--29.Delete repairs of black cars that were finished in 2018

delete from m_repair 
where extract(year from end_date)=2018 and 
car_id in (select c_id from carmechanic.m_car
 where color = 'black');

--30.The workshop named 'Kerekes Alex Szervize' is closing down (you may assume that there 
--is only one workshop with that name). Delete the employment of all mechanics currently 
--working there.More specifically: delete rows from the 'm_works_for' table that represent
-- an employment at this workshop with an unspecified end of employment.

 delete from m_works_for 
 where end_of_employment is null 
 and workshop_id = (select w_id from carmechanic.m_workshop
  where w_name = 'Kerekes Alex Szervize');

--31.Delete car brands with no models in our database.

DELETE FROM m_car_make
WHERE brand in (
  select brand from carmechanic.m_car_make
  minus
  select make from carmechanic.m_car_model
);

--32.Increase by 10% the cost of repairs that were finished between January 1,2018 and March
-- 31, 2019 in the workshop named 'Kobela Bt.'(you may assume that there is only one workshop
-- with that name).

UPDATE m_repair
SET repair_cost = repair_cost * 1.1  
WHERE car_id in(select car_id
from carmechanic.m_repair
join carmechanic.m_workshop on w_id = workshop_id
where w_name = 'Kobela Bt.'
and end_date >= date'2018-01-01'
and end_date <= date'2019-03-31');



--33. Decrease the repair cost of the red and the black cars by 10% of the car's first-sell
-- price.If the first-sell price is unknown, then the repair cost should be unchanged.

update m_repair
set repair_cost = repair_cost - (0.1 * (select first_sell_price
from m_car where c_id = car_id and first_sell_price is not null))
where car_id in (select c_id from m_car 
where color in ('red','black'));

--34.The workshop named 'Kerekes Alex Szervize' is closing down.(ypu may assume that there is 
--only one workshop with this name) due to this all started repairs must be finished.Set the 
--end date of each unfinished repair to current date and set the repair cost to number of 
--days since the start of the repair multiplied by 10% of the first sell price.

update m_repair
 set end_date =  sysdate ,
  repair_cost =  .1 * (select first_sell_price
 from m_car where c_id = car_id) * (sysdate - start_date)
 where end_date is null and repair_cost is null  and workshop_id in(select w_id 
 from m_workshop where w_name = 'Kerekes Alex Szervize');



--35.The youngest mechanic moves in to the oldest. Update the address of the youngest
-- mechanic accordingly.(you may assume that there is only one youngest and one oldest 
-- mechanic).

 update m_mechanic 
set address = (select address from carmechanic.m_mechanic
where birth_date is not null
order by birth_date 
fetch first row only)
where birth_date = (select max(birth_date) from carmechanic.m_mechanic);



--36.Increase the price of car evaluations that took place after 2011 and involved a
--Hyundai or Suzuki car by 20% of the car's first-sell price.

update m_car_evaluation 
set price = price + (0.2 * (select first_sell_price from carmechanic.m_car
where c_id = car_id)) 
where extract(year from  evaluation_date) > 2011
and car_id in (select c_id from m_car
join m_car_model on model_id = cm_id
where make in ('Hyundai','Suzuki'));


--37.Create a view that shows the license plate number of the gray car(s) with 
--the highest first_sell price.

create view view1 as
select license_plate_number
from carmechanic.m_car
where color = 'gray'
and first_sell_price = (select max(first_sell_price)
from carmechanic.m_car
where color = 'gray');

--38.Create a view that lists the name of car brands and model with no cars.

create view view1 as
select cm_name , make
from carmechanic.m_car_model
left join carmechanic.m_car on cm_id = model_id
group by cm_id,make,cm_name
having count(c_id) = 0;
--
--39.Create a view that lists the name and address of workshops in Debrecen, 
--with the  name and address of the workshop's manager if this manager does not
--live in Debrecen. Addresses in Debrecen start with 'Debrecen'.

create view view1 as 
select w_name,a,m_name,b from (select w_name,w.address a ,manager_id
from carmechanic.m_workshop w
where w.address like 'Debrecen%') left join 
(select m_name, m.address b,m_id
from carmechanic.m_workshop w
join carmechanic.m_mechanic m on m_id = manager_id
where w.address like 'Debrecen%'
and m.address not like 'Debrecen%') on m_id = manager_id;

--40.Create a view that lists the name of workshop managers ,the name of workshop they 
--manage and the name of workshop they ever worked for if these workshops are different 
--from the workshop they manage.

create view view1 as
select b.m_name,b.w_name as_manager,a.w_name as_mechanic from
(select m_name,w_name,manager_id
from carmechanic.m_workshop
join carmechanic.m_mechanic on m_id = manager_id) b left join
(select m_name,w_name,m_id
from carmechanic.m_mechanic
join carmechanic.m_works_for on m_id = mechanic_id
join carmechanic.m_workshop on w_id = workshop_id
where m_id in (select manager_id from carmechanic.m_workshop)) a on m_id = manager_id
and a.w_name != b.w_name ;


--41.Create a view that shows the name of the workshop where the longest 
--(finished) repair took place,together with the duration of this repair in days.

create view view1 as 
select w_name,end_date - start_date
from carmechanic.m_repair
join carmechanic.m_workshop on w_id = workshop_id
where end_date - start_date = (select max(end_date - start_date)
from carmechanic.m_repair);


--42.Create a view that lists the license plate number of all cars together with the 
--name of their latest owners.If a car has no owner the string 'no owner' should appear 
-- next to thier license plate number.

create view view2 as 
select a2,nvl(o_name,'no name') from
(select license_plate_number a1,o_name,date_of_buy b1
from carmechanic.m_car
left join carmechanic.m_owns on c_id = car_id
left join carmechanic.m_owner on o_id = owner_id
order by 1)
 right join 
(select license_plate_number a2,max(date_of_buy) b2
from carmechanic.m_car
left join carmechanic.m_owns on c_id = car_id
left join carmechanic.m_owner on o_id = owner_id
group by license_plate_number)
on a1 = a2 and b1 = b2;


--43.Create a view that,for each color, list the license plate number and first sell 
--price of the car(s) with that color having the highest first sell price.

create view view2 as 
select distinct a2,c1,b2 from
(select color a2 ,max(first_sell_price) b2
from carmechanic.m_car
group by color ) car
join
(select color a1,license_plate_number c1,first_sell_price b1
from carmechanic.m_car)
on a1 = a2 and b1=b2
or a2 is null and b2 = (select max(first_sell_price) b2
from carmechanic.m_car
where color is null) ;

--44.Create a view that lists the name of car makes and models with most cars in our
--database.

select make,cm_name,count(c_id)
from carmechanic.m_car
join carmechanic.m_car_model on model_id = cm_id
group by cm_id, make ,cm_name
having count(c_id) is not null
order by 3 desc
fetch first 1 row with ties;

--45.Create a view that shows the year(s) for which the most evaluations of cars 
--with this first sell year took place.


select extract(year from first_sell_date),count(*)
from carmechanic.m_car
join carmechanic.m_car_evaluation on c_id = car_id
group by extract(year from first_sell_date)
having count(*) is not null
order by 2 desc
fetch first 1 row with ties;
--
--46.Create a view for each workshops shows the car model(s) involved in the most 
--repair in that workshop Both the workshops and the car models should be represented 
--by identifiers in the view .

create view view2 as
select distinct a1,model_id from 
(select workshop_id a1,max(cnt) b1
from (select workshop_id,model_id,count(*) cnt
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
group by workshop_id)
join
 (select workshop_id a2,model_id,count(*) b2
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
on a1 = a2 and b1 = b2
or a1 is null and b1= (select max(cnt) 
from (select workshop_id,model_id,count(*) cnt
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
group by workshop_id);

--47.Grant select privilege to the user named 'dzsoni' on your 'm_mechanic' table.

GRANT SELECT ON m_mechanic TO dzsoni;

--48.Grant INSERT and UPDATE privileges to the user names 'dszoni' on your 'm_owner' table.

GRANT INSERT, UPDATE ON m_owner TO dszoni;




--49.Grant all privileges to all users on your 'm_car' table.

GRANT ALL PRIVILEGES ON m_car TO PUBLIC;

--50.Revoke the SELECT priviledge from the user named 'dzsoni' on your 'm_mechanic' table.

REVOKE SELECT ON m_mechanic FROM dzsoni;

--51.Revoke all privileges from all users on your 'm_car' table.

REVOKE ALL PRIVILEGES ON m_car FROM PUBLIC;
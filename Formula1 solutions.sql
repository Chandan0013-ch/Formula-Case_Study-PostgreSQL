create table if not exists seasons
(
	year		int primary key,
	url 		varchar(500)
); 


create table if not exists status
(
	statusId	int primary key,	
	status 		varchar(200)
); 


create table if not exists circuits
(
	circuitid		int primary key,
	circuitref		varchar(500),
	name			varchar(500),
	location		varchar(500),
	country			varchar(500),
	latitude		decimal,
	longitude		decimal,
	altitude		int,
	url				varchar(500)
);


create table if not exists races
(
	raceId			int primary key,
	year			int references seasons(year),
	round			int,
	circuitId		int references circuits(circuitid),
	name			varchar(500),
	date			date,
	time			time,
	url				varchar(500),
	fp1_date		date,
	fp1_time		time,
	fp2_date		date,
	fp2_time		time,
	fp3_date		date,
	fp3_time		time,
	quali_date		date,
	quali_time		time,
	sprint_date		date,
	sprint_time		time
); 


create table if not exists drivers
(
	driverId		int primary key,
	driverRef		varchar(500),
	number			int,
	code			varchar(500),
	forename		varchar(500),
	surname			varchar(500),
	dob				date,
	nationality		varchar(500),
	url				varchar(500)
);


create table if not exists constructors
(
	constructorId		int primary key,
	constructorRef		varchar(500),
	name				varchar(500),
	nationality			varchar(500),
	url					varchar(500)
);


create table if not exists constructor_results
(
	constructorResultsId		int primary key,
	raceId						int references races(raceid),
	constructorId				int references constructors(constructorId),
	points						decimal,
	status						varchar(20)
);


create table if not exists constructor_standings
(
	
	constructorStandingsId		int primary key,
	raceId						int references races(raceid),
	constructorId				int references constructors(constructorId),
	points						decimal,
	position					int,
	positionText				varchar(100),
	wins						int
);


create table if not exists driver_standings
(
	
	driverStandingsId		int primary key,
	raceId					int references races(raceid),
	driverId				int references drivers(driverId),
	points					decimal,
	position				int,
	positionText			varchar(100),
	wins					int
);


create table if not exists lap_times
(
	raceId			int references races(raceid),
	driverId		int references drivers(driverId),
	lap				int,
	position		int,
	time			time,
	milliseconds	int
);

create index if not exists idx01_lap_times on lap_times(raceId,driverId);


create table if not exists pit_stops
(
	
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	stop				int,
	lap					int,
	time				time,
	duration			interval,
	milliseconds		int
);


create table if not exists qualifying
(
	qualifyId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	position			int,
	q1					time,
	q2					time,
	q3					time
); 



create table if not exists results
(
	
	resultId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	grid				int,
	position			int,
	positionText		varchar(100),
	positionOrder		int,
	points				decimal,
	laps				int,
	time				varchar(30),
	milliseconds		int,
	fastestLap			int,
	rank				int,
	fastestLapTime		time,
	fastestLapSpeed		decimal ,
	statusId			int references status(statusId)
); 



create table if not exists sprint_results
(
	resultId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	grid				int,
	position			int,
	positionText		varchar(100),
	positionOrder		int,
	points				decimal,
	laps				int,
	time				varchar(100),
	milliseconds		int,
	fastestLap			int,
	fastestLapTime		time,
	statusId			int references status(statusId)
); 

select * from seasons; -- 74
select * from status; -- 139	
select * from circuits; -- 77
select * from races; -- 1102
select * from drivers; -- 857
select * from constructors; -- 211
select * from constructor_results; -- 12170
select * from constructor_standings; -- 12941
select * from driver_standings; -- 33902
select * from lap_times; -- 538121
select * from pit_stops; -- 9634
select * from qualifying; -- 9575
select * from results; -- 25840
select * from sprint_results; -- 120

Here are only the questions extracted from your list:


--Identify the country which has produced the most F1 drivers.
select nationality,count(*) from drivers 
group by 1
order by 2 desc
limit 1

--Which country has produced the most no of F1 circuits?
select country,count(*) from circuits
group by 1
order by 2 desc
limit 1

--Which countries have produced exactly 5 constructors?
select nationality,count(*) from constructors
group by 1
having count(*)=5

--List down the no of races that have taken place each year.
select year,count(*)
from races
group by 1

--Who is the youngest and oldest F1 driver?
with cte as(
select concat(forename, ' ', surname) as fullname, dob,
	rank() over(order by dob) ornk,
	rank() over(order by dob desc) yrnk
from drivers
)
select fullname, dob,
	case when yrnk = 1 then 'Youngest'
		 when ornk = 1 then 'Oldest' end as category
from cte
where yrnk =1 or ornk =1


--List down the no of races that have taken place each year and 
--mention which was the first and the last race of each season.
select distinct year,
	first_value(name) over(partition by year order by date) as firstrace,
	last_value(name) 
		over(partition by year order by date range between unbounded preceding and unbounded following) as lastrace,
	count(1) over(partition by year) as noofraces
from races
order by 1

--Which circuit has hosted the most no of races? Display the circuit name, no of races, city and country.
select * from circuits
select * from races

with cte as (
select c.name, count(*) as total, c.location, c.country,
	rank() over(order by count(*) desc) rnk
	from circuits c
	join races r on r.circuitid = c.circuitid
	group by 1,3,4
)
select * 
from cte 
where rnk = 1


--For the 2022 season, display: year, race no, circuit name, driver name, driver race position, 
--driver race points, flag to indicate if winner, constructor name, constructor position, constructor points, 
--flag to indicate if constructor is winner, race status of each driver, 
--flag to indicate fastest lap for which driver, total no of pit stops by each driver.
--List the names of all F1 champions and the number of times they have won it.
with cte as 
(select r.year, concat(d.forename,' ',d.surname) as driver_name, sum(res.points) as tot_points, 
rank() over(partition by r.year order by sum(res.points) desc) as rnk
 from races r
join driver_standings ds on ds.raceid=r.raceid
join drivers d on d.driverid=ds.driverid
join results res on res.raceid=r.raceid and res.driverid=ds.driverid
group by r.year,  res.driverid, concat(d.forename,' ',d.surname) ),
cte_rnk as
(select * from cte where rnk=1)
select driver_name, count(1) as no_of_championships
from cte_rnk
group by driver_name
order by 2 desc;
		
--Who has won the most constructor championships?
with cte as
(select r.year, c.name as constructor_name, sum(res.points) as tot_points, 
rank() over(partition by r.year order by sum(res.points) desc) as rnk
from races r
join constructor_standings cs on cs.raceid=r.raceid
join constructors c on c.constructorid = cs.constructorid
join constructor_results res on res.raceid=r.raceid and res.constructorid=cs.constructorid 
and res.constructorid=cs.constructorid 
where r.year>=2022
group by r.year,  res.constructorid, c.name),
cte_rnk as
(select * from cte where rnk=1)
select constructor_name, count(1) as no_of_championships
from cte_rnk
group by constructor_name
order by 2 desc;

11. How many races has India hosted?
select c.name as circuit_name,c.country, count(1) no_of_races
from races r
join circuits c on c.circuitid=r.circuitid
where c.country='India'
group by c.name,c.country;


-- 12. Identify the driver who won the championship or was a runner-up. Also display the team they belonged to. 
with cte as 
(select r.year, concat(d.forename,' ',d.surname) as driver_name, c.name as constructor_name, 
sum(res.points) as tot_points, 
rank() over(partition by r.year order by sum(res.points) desc) as rnk
	from races r
	join driver_standings ds on ds.raceid=r.raceid
	join drivers d on d.driverid=ds.driverid
    join results res on res.raceid=r.raceid and res.driverid=ds.driverid 
	join constructors c on c.constructorid=res.constructorid 
	where r.year>=2020
    group by r.year,  res.driverid, concat(d.forename,' ',d.surname), c.name)
	select year, driver_name, case when rnk=1 then 'Winner' else 'Runner-up' end as flag 
	from cte 
	where rnk<=2;


-- 13. Display the top 10 drivers with most wins.
select driver_name, race_wins
from (select ds.driverid, concat(d.forename,' ',d.surname) as driver_name, count(1) as race_wins, 
rank() over(order by count(1) desc) as rnk
from driver_standings ds
join drivers d on ds.driverid=d.driverid
where position=1
group by ds.driverid, concat(d.forename,' ',d.surname)
order by race_wins desc, driver_name) x
where rnk <= 10;


-- 14. Display the top 3 constructors of all time.
select constructor_name, race_wins
from (select cs.constructorid, c.name as constructor_name, count(1) as race_wins, 
rank() over(order by count(1) desc) as rnk
from constructor_standings cs
join constructors c on c.constructorid=cs.constructorid
where position = 1
group by cs.constructorid, c.name
order by race_wins desc) x
where rnk <= 3;


-- 15. Identify the drivers who have won races with multiple teams.
select driverid, driver_name, string_agg(constructor_name,', ')
from (select distinct r.driverid,concat(d.forename,' ',d.surname) as driver_name, c.name as constructor_name
from results r
join drivers d on d.driverid=r.driverid
join constructors c on c.constructorid=r.constructorid
where r.position=1) x
group by driverid, driver_name
having count(1) > 1
order by driverid, driver_name;


-- 16. How many drivers have never won any race.
select d.driverid,concat(d.forename,' ',d.surname) as driver_name,nationality
from drivers d 
where driverid not in 
(select distinct driverid from driver_standings ds 
where position=1)
order by driver_name;


-- 17. Are there any constructors who never scored a point? 
-- if so mention their name and how many races they participated in?
select cs.constructorid, c.name as constructor_name,sum(cs.points) as total_points,
count(1) as no_of_races
from constructor_results cs
join constructors c on c.constructorid=cs.constructorid
group by cs.constructorid, c.name
having sum(cs.points) = 0
order by no_of_races desc, constructor_name ;


-- 18. Mention the drivers who have won more than 50 races.
select concat(d.forename,' ',d.surname) as driver_name, count(1) as race_wins
from driver_standings ds
join drivers d on ds.driverid=d.driverid
where position=1
group by concat(d.forename,' ',d.surname)
having count(1) > 50
order by race_wins desc, driver_name;


-- 19. Identify the podium finishers of each race in 2022 season
select r.name as race, concat(d.forename,' ',d.surname) as driver_name, ds.position
from driver_standings ds 
join races r on r.raceid=ds.raceid
join drivers d on d.driverid=ds.driverid
where r.year = 2022 and ds.position <= 3
order by r.raceid;


-- 20. For 2022 season, mention the points structure for each position. 
-- i.e. how many points are awarded to each race finished position. 
with cte as (select min(res.raceid) as raceid from races r
join results res on res.raceid=r.raceid
where year=2022)
select r.position, r.points
from results r
join cte on cte.raceid=r.raceid
where r.points > 0;


-- 21. How many drivers participated in 2022 season?
select count(distinct driverid) as no_of_drivers_in_2022
from driver_standings
where raceid in (select raceid from races r where year=2022);


-- 22. How many races has each of the top 5 constructors won in the last 10 years.
with top_5_teams as(select constructorid, constructor_name
from (select cs.constructorid, c.name as constructor_name, count(1) as race_wins, 
rank() over(order by count(1) desc) as rnk
	from constructor_standings cs
	join constructors c on c.constructorid=cs.constructorid
	where position = 1
	group by cs.constructorid, c.name
    order by race_wins desc) x
	where rnk <= 5)
	select cte.constructorid, cte.constructor_name, coalesce(cs.wins,0) as wins
	from top_5_teams cte 
	left join 
( select cs.constructorid, count(1) as wins from constructor_standings cs 
join races r on r.raceid=cs.raceid
where cs.position = 1 and r.year >= (extract(year from current_date) - 10)
group by cs.constructorid) cs 
on cte.constructorid = cs.constructorid
order by wins desc;


-- 23. Display the winners of every sprint so far in F1
select r.year, r.name, concat(d.forename,' ',d.surname) as driver_name
from sprint_results sr
	join drivers d on d.driverid=sr.driverid
	join races r on r.raceid=sr.raceid
	where sr.position=1
	order by 1,2;


-- 24. Find the driver who has the most no of Did Not Qualify during the race.
select driver_name, cnt
from (select r.driverid,concat(d.forename,' ',d.surname) as driver_name,count(1) as cnt,rank() over(order by count(1) desc) as rnk
from status s
join results r on r.statusid=s.statusid
join drivers d on d.driverid=r.driverid
where s.status='Did not qualify'
group by r.driverid, concat(d.forename,' ',d.surname)
order by cnt desc) 
where rnk=1;


-- 25. During the last race of 2022 season, identify the drivers who did not finish the race and the reason for it.
select concat(d.forename,' ',d.surname) as driver_name,s.status
from results r
join status s on s.statusid=r.statusid
join drivers d on d.driverid=r.driverid
where r.raceid = (select max(raceid) from races where year=2022)and r.statusid<>1;


-- 26. What is the average lap time for each F1 circuit. Sort based on least lap time.
select cr.circuitid, cr.name as circuit_name,cr.location, cr.country,avg(lt.time) as avg_lap_time
from circuits cr
left join races r on cr.circuitid=r.circuitid
left join lap_times lt on r.raceid=lt.raceid
group by cr.circuitid, cr.name, cr.location, cr.country
order by avg_lap_time ;


-- 27. Who won the drivers championship when India hosted F1 for the first time?
with driver_champ_points as 
(select r.year, concat(d.forename,' ',d.surname) as driver_name,sum(res.points) as tot_points, 
rank() over(partition by r.year order by sum(res.points) desc) as rnk
from races r
join driver_standings ds on ds.raceid=r.raceid
join drivers d on d.driverid=ds.driverid
join results res on res.raceid=r.raceid and res.driverid=ds.driverid
where r.year in (2011,2012,2013)
group by r.year,  res.driverid, concat(d.forename,' ',d.surname) ),

driver_champ as
(select * from driver_champ_points where rnk=1),india_first_year as
(select min(year) as first_yr from races 
where circuitid in (select circuitid from circuits 
where country='India'))

select year, driver_name
from driver_champ
where year = (select first_yr from india_first_year);


-- 28. Which driver has done the most lap time in F1 history?
select driver_name, total_lap_time
from (select lt.driverid, concat(d.forename,' ',d.surname) as driver_name, sum(time) as total_lap_time, 
rank() over(order by sum(time) desc) as rnk
		from lap_times lt
		join drivers d on d.driverid=lt.driverid
		group by lt.driverid, concat(d.forename,' ',d.surname)) x
	where rnk=1;


-- 29. Name the top 3 drivers who have got the most podium finishes in F1 (Top 3 race finishes)
select driver_name, no_of_podiums
from (select ds.driverid, concat(d.forename,' ',d.surname) as driver_name, count(1) as no_of_podiums, 
rank() over(order by count(1) desc) as rnk
from driver_standings ds 
join drivers d on d.driverid=ds.driverid
where ds.position <= 3
group by ds.driverid, concat(d.forename,' ',d.surname)) x
where rnk<=3;


-- 30. Which driver has the most pole position (no 1 in qualifying)
select driver_name, pole_positions
from (select q.driverid, concat(d.forename,' ',d.surname) as driver_name, count(1) as pole_positions, 
rank() over(order by count(1) desc) as rnk
		from qualifying q
		join drivers d on d.driverid=q.driverid
		where position=1
		group by q.driverid, concat(d.forename,' ',d.surname)
		order by pole_positions desc)
	    where rnk=1;
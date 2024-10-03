use TEST;
drop table if exists friends;
create table friends
	(
	user1 int,
	user2 int
	);
insert into friends values (1,2),(1,3),(1,4),(2,3);
select * from friends

select 
	user1,
	count(*) sl
from
	( 
		select user1, user2
		from friends
		union all
		select user2, user1
		from friends
	) a
group by user1
order by 2 desc


-- 2. Tính lương 3 tháng liên tiếp, nếu không đủ thì bỏ qua

drop table if exists salaries;
create table salaries
	(
		monthid int,
		salary float
	)

insert into salaries values
	(1,2000), (2,3000), (3,5000), (4,4000), (5,2000), (6,1000), (7,2000), (8,4000), (9,5000)

-- Tính lương lũy kế 

select * from salaries;

select *,
	sum(salary) over(order by monthid rows between current row and 2 following) as luyke
from salaries

select a.monthid, sum(b.salary) as salary
from salaries a
left join salaries b on a.monthid >= b.monthid
group by a.monthid

SELECT 
    s1.monthid,
    SUM(s3.salary) AS accumulated_salary
FROM 
    salaries s1
JOIN 
    salaries s3 ON s1.monthid BETWEEN s3.monthid - 2 AND s3.monthid
GROUP BY 
    s1.monthid
HAVING 
    COUNT(*) = 3;



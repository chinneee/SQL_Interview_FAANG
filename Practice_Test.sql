-- Query 1: Write a SQL query to fetch all the duplicate records from a table.

Select *
From
	(select 
		*,
		ROW_NUMBER() Over (Partition by user_name order by user_id) as rnk_user
	from users) as detect_dups
where rnk_user <> 1;

-- Query 2: Write a SQL query to fetch the second last record from a employee table.
select
	emp_ID,
	emp_NAME,
	DEPT_NAME,
	SALARY
from 
	(select *, 
		ROW_NUMBER() Over (order by emp_ID DESC) as rnk
	from employee) as detect_emp
where rnk = 2;

-- Query 3: Write a SQL query to display only the details of employees who either earn the highest salary or the lowest salary in each department from the employee table.
Select *
from 
	(select *,
		Max(SALARY) OVER (Partition by DEPT_NAME) as max_salary,
		Min(SALARY) OVER (Partition by DEPT_NAME) as min_salary
	from employee) as salary_comparation
where 
	SALARY = max_salary 
	OR SALARY = min_salary;

-- Query 4: From the doctors table, fetch the details of doctors who work in the same hospital but in different speciality.
select *
from
	(select *,
		case 
			when count(*) Over (partition by hospital) <> 1 then 'pass'
		else 'no'
		END as category_1, 
		case 
			when count(*) Over (partition by speciality) = 1 then 'pass'
		else 'no'
		END as category_2 
	from doctors) as count_hos
where category_1 = 'pass'; 

select d1.name, d1.speciality,d1.hospital
from doctors d1
join doctors d2  -- Self Join
on d1.hospital = d2.hospital and d1.speciality <> d2.speciality
and d1.id <> d2.id;
	
-- Query 5: From the login_details table, fetch the users who logged in consecutively 3 or more times.
SELECT DISTINCT
	user_name
FROM	
	(SELECT *,
		CASE 
			WHEN user_name = LAG(user_name, 1) OVER (ORDER BY login_date) 
			AND user_name = LAG(user_name, 2) OVER (ORDER BY login_date) 
			THEN 'pass'
			ELSE 'fail'
		END as category
	FROM login_details) as detect_consecutive
WHERE category = 'pass';

-- Query 6: From the students table, write a SQL query to interchange the adjacent student names.
-- Note: If there are no adjacent student then the student name should stay the same.
SELECT
	id,
	student_name,
	CASE 
		WHEN previous_student is null THEN student_name
		ELSE previous_student
	END as previous_name
FROM	
	(select *,
		Lead(student_name, 1) OVER (ORDER BY id) as previous_student
	from students) AS detect_adjacent;

-- Query 7: From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
-- Note: Weather is considered to be extremely cold then its temperature is less than zero.
Select *
from	
	(select *,
		Case 
			when temperature < 0
			and (lead(temperature, 1) over (order by day) < 0
			and lead(temperature, 2) over (order by day) < 0) Then 'Cold'
			when temperature < 0
			and (lead(temperature, 1) over (order by day) < 0
			and LAG(temperature, 1) over (order by day) < 0) Then 'Cold'
			when temperature < 0
			and (LAG(temperature, 1) over (order by day) < 0
			and LAG(temperature, 2) over (order by day) < 0) Then 'Cold'
		else 'Not Cold'
		End as category
	from weather) as detect_cold
where category = 'Cold';

/* Query 8: From the following 3 tables (event_category, physician_speciality, patient_treatment),
write a SQL query to get the histogram of specialities of the unique physicians
who have done the procedures but never did prescribe anything */
select * from event_category;
select * from physician_speciality;
select * from patient_treatment;
------------------------------------
select 
	ps.speciality,
	Count(pt.physician_id) as count
from patient_treatment pt 
join event_category ec
on pt.event_name = ec.event_name
join physician_speciality ps
on pt.physician_id = ps.physician_id
where ec.category = 'Procedure'
and pt.physician_id not in 
	(select pt.physician_id 
	from patient_treatment pt 
	join event_category ec
	on pt.event_name = ec.event_name
	where ec.category = 'Prescription')
group by ps.speciality;

-- Query 9: Find the top 2 accounts with the maximum number of unique patients on a monthly basis.
--Note: Prefer the account if with the least value in case of same number of unique patients
select * from patient_logs;
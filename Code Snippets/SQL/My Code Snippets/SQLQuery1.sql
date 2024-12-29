select * from HR


EXEC sp_rename 'HR.id',  'emplyee_id', 'COLUMN';

exec sp_columns HR

UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN CONVERT(date, birthdate, 101)
    WHEN birthdate LIKE '%-%' THEN CONVERT(date, birthdate, 103)
    ELSE NULL
END;
alter table HR
alter column birthdate Date
 
UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN CONVERT(date, hire_date, 101)
    WHEN hire_date LIKE '%-%' THEN CONVERT(date, hire_date, 103)
    ELSE NULL
END;
alter table HR
alter column hire_date Date




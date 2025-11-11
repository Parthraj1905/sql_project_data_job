CREATE TABLE employees(
    employee_id INT primary key,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    salary INT,
    department_id INT
);

INSERT INTO employees(employee_id,
    first_name,
    last_name,
    hire_date,
    salary,
    department_id)
VALUES
(1,'Parmar','Parth','2025-02-14',60000,101),
(2,'Solanki','Smit','2025-08-21',45000,101),
(3,'Shah','Karan','2024-11-30',70000,102),
(4,'Patel','Nisha','2025-05-10',55000,103),
(5,'Mehta','Ravi','2024-12-15',80000,102);

ALTER TABLE employees
ADD COLUMN contact_number VARCHAR(15);

UPDATE employees
SET contact_number = '8278658299'
WHERE employee_id = 1;

UPDATE employees
SET contact_number = '9123456780'
WHERE employee_id = 2;

UPDATE employees
SET contact_number = '9988776655'
WHERE employee_id = 3;

UPDATE employees
SET contact_number = '8877665544'
WHERE employee_id = 4;

UPDATE employees
SET contact_number = '7766554433'
WHERE employee_id = 5;

SELECT * FROM employees;

ALTER TABLE employees
DROP COLUMN department_id;
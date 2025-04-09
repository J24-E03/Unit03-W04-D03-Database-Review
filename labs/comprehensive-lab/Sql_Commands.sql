-- Part 1: DDL – Define Schema
-- Create the following tables with appropriate constraints:
-- Create table departments
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Create table students
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    dob DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table courses
CREATE TABLE courses (
id SERIAL PRIMARY KEY,
name VARCHAR(255),
credits INT CHECK (credits BETWEEN 1 AND 5),
department_id INT,
FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Create table enrollments
CREATE TABLE enrollments (
student_id INT,
course_id INT,
enrollment_date DATE,
grade DECIMAL(5, 2) NULL,
PRIMARY KEY (student_id, course_id),
FOREIGN KEY (student_id) REFERENCES students(id),
FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 2. ALTER and RENAME
ALTER TABLE students ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE courses RENAME COLUMN name TO course_title;

-- 3. TRUNCATE and DROP
TRUNCATE TABLE enrollments;
ALTER TABLE students DROP COLUMN phone_number;

-- Part 2: DML – Populate Tables
-- 4. INSERT
-- inserting into departments
INSERT INTO departments (name) VALUES
('Computer Science'),
('Mathematics'),
('Physics');

-- inserting into students
INSERT INTO students (full_name, email, dob, registration_date) VALUES
('Alice Smith', 'alice@example.com', '2000-04-15', '2022-12-20'),
('Bob Johnson', 'bob@example.com', '1999-11-22', '2023-02-10'),
('Charlie Lee', 'charlie@example.com', '2001-07-30', '2023-06-05'),
('Diana King', 'diana@example.com', '1998-01-05', '2022-11-30'),
('Ethan Clark', 'ethan@example.com', '2002-03-12', '2023-08-15');

-- inserting into courses
INSERT INTO courses (course_title, credits, department_id) VALUES
('Algorithms', 4, 1),
('Databases', 3, 1),
('Calculus', 5, 2),
('Linear Algebra', 4, 2),
('Quantum Mechanics', 5, 3);

-- 5. UPDATE
-- Change a student's name and update a course credit:
UPDATE students SET full_name = 'Alice M. Smith'
WHERE full_name = 'Alice Smith';

UPDATE courses SET credits = 5 
WHERE course_title = 'Databases';

-- 6. DELETE
-- Delete a course from a department that has no enrollments:
DELETE FROM courses
WHERE id = 5 AND id NOT IN (SELECT course_id FROM enrollments);

-- Part 3: DQL – Queries & Filtering
-- 7. SELECT with WHERE
-- List all students registered after 2023-01-01:
SELECT * FROM students
WHERE registration_date > '2023-01-01'::DATE;

-- List all courses with credits more than 3:
SELECT * FROM courses
WHERE credits > 3;

-- 8. Use Aggregation Functions
-- Count number of students per department:
SELECT c.department_id, count (DISTINCT e.student_id) AS number_of_students
FROM enrollments e
JOIN courses c ON c.id = e.course_id
GROUP BY c.department_id;

-- Find average credits of all courses:
SELECT ROUND(AVG (credits),1) AS average_credits
FROM courses;

-- Show the max and min grades in enrollments:
SELECT MAX(grade) AS max_grade, MIN(grade) AS min_grade
FROM enrollments;

-- Part 4: Relationships & JOINs
-- 9. Insert Enrollments
-- One-to-Many relationship:
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2023-01-10', 100),
(1, 2, '2023-01-10', 85),
(1, 3, '2023-01-10', 100),
(1, 4, '2023-01-10', 70);  

-- Many-to-Many relationship:
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(2, 4, '2023-02-05', 92),
(3, 4, '2023-03-20', 80),
(4, 2, '2023-04-15', 88),
(4, 3, '2023-04-15', 75);

-- 10. Perform JOINs
-- INNER JOIN to show student names and their enrolled course titles:
SELECT s.full_name AS student_name , c.course_title
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses c ON c.id = e.course_id;

-- LEFT JOIN to show all students and any enrollments they have:
SELECT s.full_name AS student_name, e.*
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id;

-- RIGHT JOIN to show all courses and enrolled students:
INSERT INTO courses (course_title, credits, department_id)
VALUES ('Intro to Philosophy', 3, 1); 

SELECT s.full_name AS student_name, s.id AS student_id,
       c.id AS course_id, c.course_title,
       e.enrollment_date, e.grade
FROM enrollments e
JOIN students s ON s.id = e.student_id
RIGHT JOIN courses c ON c.id = e.course_id;

-- FULL OUTER JOIN between students and enrollments.
SELECT s.*, e.course_id, e.enrollment_date, e.grade
FROM students s
FULL OUTER JOIN enrollments e ON e.student_id = s.id;

-- Bonus Challenges
-- 11. DISTINCT and ORDER BY
-- Get a list of unique departments a student is enrolled in:
CREATE OR REPLACE FUNCTION find_departments(id_of_student INT) 
RETURNS SETOF TEXT AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT d.name::TEXT
    FROM departments d
    JOIN courses c ON c.department_id = d.id
    JOIN enrollments e ON c.id = e.course_id
    WHERE e.student_id = id_of_student;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_departments(1);

-- Order students by registration_date descending:
SELECT * FROM students
ORDER BY registration_date DESC;

-- 12. LIMIT and OFFSET
-- Get the 2 most recent student registration:
SELECT * FROM students
ORDER BY registration_date DESC
LIMIT 2;

-- Skip the first 3 oldest students and show the next 2:
SELECT * FROM students
ORDER BY registration_date
OFFSET 3
LIMIT 2;

-- 13. Use IN and COALESCE
-- List all students with ids in (1, 3, 5):
SELECT * FROM students
WHERE id IN (1, 3, 5);

-- Replace null grades in enrollments with 'Pending':
-- since my grades are decimal, I will update them to -1 instead
UPDATE enrollments
SET grade = -1
WHERE grade IS NULL;

-- 14. Working with DATE/TIME/INTERVAL'
-- Find students older than 21 years:
SELECT * FROM students
WHERE EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM dob) >= 21;
-- another way:
SELECT * FROM students
WHERE AGE(CURRENT_DATE, dob) > INTERVAL '21 years';

-- Show how long each student has been registered using AGE():
SELECT *, AGE(CURRENT_DATE, registration_date) AS age_of_registration
FROM students;

-- Add 6 months to all course enrollments:
UPDATE enrollments
SET enrollment_date = enrollment_date + INTERVAL '6 months';

-- 15. ON CONFLICT (UPSERT)
-- On conflict, DO NOTHING:
INSERT INTO students (full_name, email, dob)
VALUES ('New Student', 'existing_email@example.com', '2000-01-01')
ON CONFLICT (email) DO NOTHING;

-- On conflict, DO UPDATE to change the name:
INSERT INTO students (full_name, email, dob)
VALUES ('New Student1', 'existing_email@example.com', '2000-01-01')
ON CONFLICT (email) DO UPDATE
SET full_name = EXCLUDED.full_name;

-- 16. NULLS LAST
-- Show list of students ordered by grade, nulls last:
SELECT s.*
FROM students s
JOIN enrollments e ON e.student_id = s.id
ORDER BY e.grade NULLS LAST;

-- 17. GROUP BY and HAVING
-- Show number of enrollments per course with more than 1 enrollment:
SELECT e.course_id, c.course_title, COUNT(e.student_id) AS number_of_students
FROM enrollments e
JOIN courses c ON c.id = e.course_id
GROUP BY e.course_id, c.course_title
HAVING COUNT(e.student_id) > 1;

-- 18. CASE statements
-- Select students and categorize their grades: A (90-100), B (80–89), C (70–79), F (below 70)
SELECT s.id, s.full_name, c.course_title, e.grade,
       CASE
           WHEN e.grade >= 90 THEN 'A'
           WHEN e.grade >= 80 THEN 'B'
           WHEN e.grade >= 70 THEN 'C'
           ELSE 'F'
       END AS grade_category
FROM students s
JOIN enrollments e ON e.student_id = s.id
JOIN courses c ON c.id = e.course_id;

-- 19. Views
-- Create a view student_enrollments that shows student name, course title, and grade:
CREATE VIEW student_enrollments AS
SELECT s.full_name AS student_name, 
       c.course_title, 
       e.grade
FROM students s
JOIN enrollments e ON e.student_id = s.id
JOIN courses c ON c.id = e.course_id;

SELECT * FROM student_enrollments;

-- 20. Functions
-- Write a Postgres function get_student_age(student_id INT) that returns the student's age in years:
CREATE OR REPLACE FUNCTION get_student_age(student_id INT) 
RETURNS INT AS $$
DECLARE
    student_age INT;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, dob))::INT INTO student_age
    FROM students
    WHERE id = student_id;

    RETURN student_age;
END;
$$ LANGUAGE plpgsql;

SELECT get_student_age(1);

-- 21. Triggers
-- Create a trigger that automatically sets the enrollment_date to current date when a new row is added to enrollments:
CREATE OR REPLACE FUNCTION set_enrollment_date() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.enrollment_date := CURRENT_DATE;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_enrollment_date_trigger
BEFORE INSERT ON enrollments
FOR EACH ROW
EXECUTE FUNCTION set_enrollment_date();

-- test the trigger
INSERT INTO enrollments (student_id, course_id, grade)
VALUES (2, 3, 85);
SELECT * FROM enrollments WHERE student_id = 2 AND course_id = 3;




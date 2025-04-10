-- Students Table
CREATE TABLE students (
                          id SERIAL PRIMARY KEY,
                          full_name VARCHAR(100) NOT NULL,
                          email VARCHAR(200) UNIQUE NOT NULL,
                          dob DATE,
                          registration_date DATE DEFAULT CURRENT_DATE
);
-- Departments Table
CREATE TABLE departments (
                             id SERIAL PRIMARY KEY,
                             name VARCHAR(100) NOT NULL UNIQUE
);
--Courses
CREATE TABLE courses (
                         id SERIAL PRIMARY KEY,
                         course_title VARCHAR(100),
                         credits INT CHECK (credits BETWEEN 1 AND 5),
                         department_id INT REFERENCES departments(id)
);

-- Enrollments Table
CREATE TABLE enrollments (
                             student_id INT REFERENCES students(id),
                             course_id INT REFERENCES courses(id),
                             enrollment_date DATE,
                             grade INT,PRIMARY KEY (student_id, course_id)
);

-->ALTER AND RENAME
ALTER TABLE students ADD COLUMN phone_number VARCHAR(200);
ALTER TABLE courses RENAME COLUMN name TO course_title;

-->TRUNCATE and DROP
TRUNCATE TABLE enrollments;
ALTER TABLE students DROP COLUMN phone_number;

-->Part 2:  DML – Populate Tables
-->INSERT
INSERT INTO students(full_name,email,dob) VALUES
                                              ('Rob Reith','reith@example.com', '2000-05-20'),
                                              ('Bob Smith', 'bob1@example.com', '2002-09-10'),
                                              ('Cara Lee', 'cara1@example.com', '1999-12-01'),
                                              ('David Kim', 'david1@example.com', '2001-06-15'),
                                              ('Eva Turner', 'eva1@example.com', '2003-03-30');

-->
INSERT INTO departments(name) VALUES
                                  ('Computer Science'), ('Mathematics'), ('History');
-->
INSERT INTO courses (course_title, credits, department_id) VALUES
                                                               ('Intro to CS', 3, 1),
                                                               ('Data Structures', 4, 1),
                                                               ('Calculus I', 5, 2),
                                                               ('Linear Algebra', 4, 2),
                                                               ('World History', 2, 3);

-->UPDATE
UPDATE students SET full_name = 'Bob John' WHERE id = 2;
UPDATE courses SET credits = 5 WHERE course_title = 'Data Structures';

-->DELETE
DELETE FROM courses
WHERE id NOT IN (SELECT DISTINCT course_id FROM enrollments);

-->Part 3: DQL – Queries & Filtering
-->SELECT WITH WHERE
SELECT * FROM students WHERE registration_date > '2023-01-01';
SELECT * FROM courses WHERE credits > 3;

--> Use Aggregation Functions
SELECT d.name, COUNT(s.id) AS student_count FROM students s JOIN departments d ON d.id =(
    SELECT department_id FROM courses c JOIN enrollments e ON c.id = e.course_id WHERE e.student_id = s.id LIMIT 1) GROUP BY d.name;

--> Average credits
SELECT AVG(credits) FROM courses;
--> Max and min grades
SELECT MAX(grade) AS max_grade, MIN(grade) AS min_grade FROM enrollments;

-->Part 4: Relationships & JOINs
-->9. Insert Enrollments
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade)
VALUES
    (1, 6, CURRENT_DATE, 88),
    (1, 7, CURRENT_DATE, NULL),
    (2, 8, CURRENT_DATE, 90),
    (3, 9, CURRENT_DATE, 75),
    (4, 10, CURRENT_DATE, NULL);

-->10. Perform JOINs
-->INNER JOIN
SELECT s.full_name, c.course_title FROM students s JOIN enrollments e ON s.id = e.student_id JOIN courses c ON c.id = e.course_id;

-->LEFTJOIN
SELECT s.full_name, c.course_title FROM students s RIGHT JOIN enrollments e ON s.id = e.student_id LEFT JOIN courses c ON e.course_id = c.id;
-->RIGHT JOIN
SELECT s.full_name, c.course_title FROM students s RIGHT JOIN enrollments e ON s.id = e.student_id RIGHT JOIN courses c ON c.id = e.course_id;
-- FULL OUTER JOIN
SELECT s.full_name, c.course_title FROM students s FULL OUTER JOIN enrollments e ON s.id = e.student_id FULL OUTER JOIN courses c ON e.course_id = c.id;

-->BONUS
-->DISTINCT and ORDER BY
SELECT DISTINCT d.name FROM departments d JOIN courses c ON d.id = c.department_id JOIN enrollments e ON c.id = e.course_id;

SELECT * FROM students ORDER BY registration_date DESC;

-->12. LIMIT and OFFSET
SELECT * FROM students ORDER BY registration_date DESC LIMIT 2;
SELECT * FROM students ORDER BY registration_date ASC OFFSET 3 LIMIT 2;

-->13. IN and COALESCE
SELECT * FROM students WHERE id IN (1, 3, 5);
SELECT student_id, course_id, COALESCE(grade, 'Pending') AS grade_status FROM enrollments;

-->14. Working with DATE
-- Older than 21
SELECT * FROM students WHERE AGE(dob) > INTERVAL '21 years';

-- Registration age
SELECT id, full_name, AGE(registration_date) AS registered_for FROM students;

-- Add 6 months to enrollment
UPDATE enrollments SET enrollment_date = enrollment_date + INTERVAL '6 months';

-->15. ON CONFLICT (UPSERT)
-- Do nothing
INSERT INTO students (full_name, email, dob)
VALUES ('Alice Johnson Again', 'alice@example.com', '2000-05-20')
    ON CONFLICT (email) DO NOTHING;

-- Do update
INSERT INTO students (full_name, email, dob)
VALUES ('Alice Updated', 'alice@example.com', '2000-05-20')
    ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name;

INSERT INTO students (full_name, email, dob)
VALUES ('Alice Updated', 'alice@example.com', '2000-05-20')
    ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name;

-->16. NULLS LAST
SELECT s.full_name, e.grade FROM students s JOIN enrollments e ON s.id = e.student_id ORDER BY grade NULLS LAST;

-->17. GROUP BY & HAVING
SELECT c.course_title, COUNT(*) AS enrollment_count
FROM enrollments e
         JOIN courses c ON c.id = e.course_id
GROUP BY c.course_title
HAVING COUNT(*) > 1;

-->18. CASE Statements
SELECT s.full_name,
       CASE
           WHEN e.grade >= 90 THEN 'A'
           WHEN e.grade >= 80 THEN 'B'
           WHEN e.grade >= 70 THEN 'C'
           ELSE 'F'
           END AS grade_category
FROM students s
         JOIN enrollments e ON s.id = e.student_id;

-->19. VIEWS
CREATE VIEW student_enrollments AS
SELECT s.full_name, c.course_title, e.grade
FROM students s
         JOIN enrollments e ON s.id = e.student_id
         JOIN courses c ON c.id = e.course_id;

-->20. Functions
CREATE OR REPLACE FUNCTION get_student_age(student_id INT)
RETURNS INT AS $$
DECLARE
student_age INT;
BEGIN
SELECT EXTRACT(YEAR FROM AGE(dob)) INTO student_age FROM students WHERE id = student_id; RETURN student_age;
END;
$$ LANGUAGE plpgsql;

-->21. Triggers
-- Trigger function
CREATE OR REPLACE FUNCTION set_enrollment_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.enrollment_date := CURRENT_DATE;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trg_set_enrollment_date
    BEFORE INSERT ON enrollments
    FOR EACH ROW
    EXECUTE FUNCTION set_enrollment_date();


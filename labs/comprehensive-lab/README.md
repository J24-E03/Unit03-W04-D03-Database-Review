## 🔧 **Lab Overview: "Student Portal Management System"**

The goal is to create and manipulate a database for a fictional university's student portal. Students will:

- Create tables for `students`, `courses`, `enrollments`, and `departments`
- Apply various constraints
- Insert and update data
- Perform data retrieval using joins and filters
- Use aggregation functions
- Explore table relationships
- Handle real-world data scenarios

---

### Part 1: 📐 DDL – Define Schema

**1. Create the following tables with appropriate constraints:**

- **students**
  - id (Primary Key)
  - full_name (Not Null)
  - email (Unique)
  - dob (Date)
  - registration_date (Default to current date)

- **departments**
  - id (Primary Key)
  - name (Unique, Not Null)

- **courses**
  - id (Primary Key)
  - name
  - credits (Check that credits are between 1 and 5)
  - department_id (Foreign Key references departments)

- **enrollments**
  - student_id (FK)
  - course_id (FK)
  - enrollment_date
  - grade (Can be null)

> Make sure to apply:
- `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `DEFAULT`, `CHECK`
- Use appropriate **data types**: `VARCHAR`, `INT`, `DATE`, `TIMESTAMP`, etc.

**2. ALTER and RENAME**
- Add a column `phone_number` to `students`.
- Rename the column `name` in `courses` to `course_title`.

**3. TRUNCATE and DROP**
- TRUNCATE the enrollments table (but keep structure).
- DROP the phone_number column from students.

---

### Part 2: ✍️ DML – Populate Tables

**4. INSERT**
- Add 5 students, 3 departments, and 5 courses.

**5. UPDATE**
- Change a student's name and update a course credit.

**6. DELETE**
- Delete a course from a department that has no enrollments.

---

### Part 3: 🔍 DQL – Queries & Filtering

**7. SELECT with WHERE**
- List all students registered after `2023-01-01`.
- List all courses with credits more than 3.

**8. Use Aggregation Functions**
- Count number of students per department.
- Find average credits of all courses.
- Show the max and min grades in enrollments.

---

### Part 4: 🔗 Relationships & JOINs

**9. Insert Enrollments**  
Enroll students in different courses (simulate One-to-Many and Many-to-Many).

**10. Perform JOINs**
- INNER JOIN to show student names and their enrolled course titles.
- LEFT JOIN to show all students and any enrollments they have.
- RIGHT JOIN to show all courses and enrolled students.
- FULL OUTER JOIN between students and enrollments.

---

## 🌟 Bonus Challenges

**11. DISTINCT and ORDER BY**
- Get a list of unique departments a student is enrolled in.
- Order students by registration_date descending.

**12. LIMIT and OFFSET**
- Get the 2 most recent student registrations.
- Skip the first 3 oldest students and show the next 2.

**13. Use IN and COALESCE**
- List all students with ids in (1, 3, 5).
- Replace null grades in enrollments with 'Pending'.

**14. Working with DATE/TIME/INTERVAL**
- Find students older than 21 years.
- Show how long each student has been registered using `AGE()`.
- Add 6 months to all course enrollments.

**15. ON CONFLICT (UPSERT)**
- Try inserting a student with an existing email.
  - On conflict, DO NOTHING.
  - On conflict, DO UPDATE to change the name.

**16. NULLS LAST**
- Show list of students ordered by grade, nulls last.

**17. GROUP BY and HAVING**
- Show number of enrollments per course with more than 1 enrollment.

**18. CASE statements**
- Select students and categorize their grades:
  - A (90-100), B (80–89), C (70–79), F (below 70)

**19. Views**
- Create a view `student_enrollments` that shows student name, course title, and grade.

**20. Functions**
- Write a Postgres function `get_student_age(student_id INT)` that returns the student's age in years.

**21. Triggers**
- Create a trigger that automatically sets the `enrollment_date` to current date when a new row is added to enrollments.


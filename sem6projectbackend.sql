
use sem6projectbackend;
-- Users table to store common user attributes
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20),
    role VARCHAR(20) CHECK (role IN ('student', 'teacher', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students table with academic details
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    roll_number VARCHAR(20) UNIQUE NOT NULL,
    pid VARCHAR(20) UNIQUE NOT NULL,
    current_semester INTEGER CHECK (current_semester BETWEEN 1 AND 8),
    current_year VARCHAR(2) CHECK (current_year IN ('FE', 'SE', 'TE', 'BE')),
    division VARCHAR(10) NOT NULL,
    academic_year VARCHAR(9) NOT NULL -- Format: 2024-2025
);

-- Teachers table
CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    department VARCHAR(50) NOT NULL
);

-- Subjects table
CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    semester INTEGER CHECK (semester BETWEEN 1 AND 8),
    year VARCHAR(2) CHECK (year IN ('FE', 'SE', 'TE', 'BE'))
);

-- Teacher-Subject assignments
CREATE TABLE teacher_subjects (
    teacher_subject_id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES teachers(teacher_id),
    subject_id INTEGER REFERENCES subjects(subject_id),
    division VARCHAR(10) NOT NULL,
    academic_year VARCHAR(9) NOT NULL,
    UNIQUE(teacher_id, subject_id, division, academic_year)
);

-- Tasks/Assignments table
CREATE TABLE tasks (
    task_id SERIAL PRIMARY KEY,
    teacher_subject_id INTEGER REFERENCES teacher_subjects(teacher_subject_id),
    task_type VARCHAR(10) CHECK (task_type IN ('ISE1', 'ISE2', 'MSE')),
    title VARCHAR(255) NOT NULL,
    due_date DATE NOT NULL,
    total_marks INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student submissions
CREATE TABLE submissions (
    submission_id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES tasks(task_id),
    student_id INTEGER REFERENCES students(student_id),
    submission_file_path VARCHAR(255) NOT NULL,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('pending', 'submitted', 'graded')),
    UNIQUE(task_id, student_id)
);

-- Marks distribution
CREATE TABLE marks (
    marks_id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(submission_id),
    question_number INTEGER NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    comments TEXT,
    marked_by INTEGER REFERENCES teachers(teacher_id),
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(submission_id, question_number)
);

-- Create indexes for better query performance
CREATE INDEX idx_student_roll ON students(roll_number);
CREATE INDEX idx_student_pid ON students(pid);
CREATE INDEX idx_submission_task ON submissions(task_id);
CREATE INDEX idx_submission_student ON submissions(student_id);
CREATE INDEX idx_marks_submission ON marks(submission_id);
CREATE INDEX idx_teacher_subjects_composite ON teacher_subjects(teacher_id, subject_id, academic_year);



-- dummy data
-- Insert dummy users first (both teachers and students)
INSERT INTO users (email, password_hash, full_name, contact_number, role) VALUES
-- Teachers
('smith.john@college.edu', 'hashed_password_123', 'John Smith', '+1-555-0101', 'teacher'),
('garcia.maria@college.edu', 'hashed_password_124', 'Maria Garcia', '+1-555-0102', 'teacher'),
('patel.priya@college.edu', 'hashed_password_125', 'Priya Patel', '+1-555-0103', 'teacher'),
-- Students
('john.doe@student.edu', 'hashed_password_126', 'John Doe', '+1-555-0201', 'student'),
('jane.smith@student.edu', 'hashed_password_127', 'Jane Smith', '+1-555-0202', 'student'),
('bob.wilson@student.edu', 'hashed_password_128', 'Bob Wilson', '+1-555-0203', 'student'),
('alice.brown@student.edu', 'hashed_password_129', 'Alice Brown', '+1-555-0204', 'student'),
('charlie.davis@student.edu', 'hashed_password_130', 'Charlie Davis', '+1-555-0205', 'student');

-- Insert teachers
INSERT INTO teachers (user_id, department) VALUES
(1, 'Computer Science'),
(2, 'Information Technology'),
(3, 'Computer Engineering');

-- Insert students
INSERT INTO students (user_id, roll_number, pid, current_semester, current_year, division, academic_year) VALUES
(4, '101', 'PID001', 6, 'TE', 'B', '2024-2025'),
(5, '102', 'PID002', 6, 'TE', 'B', '2024-2025'),
(6, '103', 'PID003', 6, 'TE', 'B', '2024-2025'),
(7, '104', 'PID004', 6, 'TE', 'B', '2024-2025'),
(8, '105', 'PID005', 6, 'TE', 'B', '2024-2025');

-- Insert subjects
INSERT INTO subjects (subject_code, subject_name, semester, year) VALUES
('CSS101', 'Cryptography and System Security', 6, 'TE'),
('MC101', 'Mobile Computing', 6, 'TE'),
('SPCC101', 'System Programming and Compiler Construction', 6, 'TE'),
('AI101', 'Artificial Intelligence', 6, 'TE'),
('CC101', 'Cloud Computing', 6, 'TE');

-- Assign teachers to subjects
INSERT INTO teacher_subjects (teacher_id, subject_id, division, academic_year) VALUES
(1, 1, 'B', '2024-2025'),  -- John Smith teaches CSS
(2, 2, 'B', '2024-2025'),  -- Maria Garcia teaches MC
(3, 3, 'B', '2024-2025');  -- Priya Patel teaches SPCC

-- Create some tasks
INSERT INTO tasks (teacher_subject_id, task_type, title, due_date, total_marks) VALUES
(1, 'ISE1', 'CSS Mid-Term Assignment', '2024-03-15', 20),
(1, 'ISE2', 'CSS Final Assignment', '2024-04-15', 20),
(2, 'MSE', 'MC Semester Project', '2024-04-30', 40);

-- Insert some student submissions
INSERT INTO submissions (task_id, student_id, submission_file_path, status) VALUES
(1, 1, '/uploads/CSS_ISE1_PID001.pdf', 'submitted'),
(1, 2, '/uploads/CSS_ISE1_PID002.pdf', 'graded'),
(1, 3, '/uploads/CSS_ISE1_PID003.pdf', 'pending'),
(2, 1, '/uploads/CSS_ISE2_PID001.pdf', 'submitted'),
(3, 1, '/uploads/MC_MSE_PID001.pdf', 'graded');

-- Insert marks for graded submissions
INSERT INTO marks (submission_id, question_number, marks_obtained, comments, marked_by) VALUES
-- Marks for Jane Smith's CSS ISE1
(2, 1, 8.5, 'Good understanding of concepts', 1),
(2, 2, 7.0, 'Could improve implementation', 1),
(2, 3, 3.5, 'Incomplete solution', 1),
-- Marks for John Doe's MC MSE
(5, 1, 9.0, 'Excellent analysis', 2),
(5, 2, 8.5, 'Well-structured solution', 2),
(5, 3, 7.5, 'Good implementation', 2),
(5, 4, 8.0, 'Clear documentation', 2);

-- Example queries to demonstrate functionality

-- 1. Get all students in TE-B with their details
SELECT s.roll_number, s.pid, u.full_name, u.email, u.contact_number
FROM students s
JOIN users u ON s.user_id = u.user_id
WHERE s.current_year = 'TE' AND s.division = 'B'
ORDER BY s.roll_number;

-- 2. Get all subjects taught by a specific teacher
SELECT s.subject_name, ts.division, ts.academic_year
FROM teacher_subjects ts
JOIN subjects s ON ts.subject_id = s.subject_id
JOIN teachers t ON ts.teacher_id = t.teacher_id
JOIN users u ON t.user_id = u.user_id
WHERE u.full_name = 'John Smith';

-- 3. Get submission status and marks for a specific student in a subject
SELECT 
    t.title,
    t.task_type,
    s.status,
    COALESCE(SUM(m.marks_obtained), 0) as total_marks,
    t.total_marks as maximum_marks
FROM tasks t
LEFT JOIN submissions s ON t.task_id = s.task_id
LEFT JOIN marks m ON s.submission_id = m.submission_id
WHERE s.student_id = 1  -- John Doe
AND t.teacher_subject_id IN (
    SELECT teacher_subject_id 
    FROM teacher_subjects 
    WHERE subject_id = 1  -- CSS
)
GROUP BY t.task_id, t.title, t.task_type, s.status, t.total_marks;



DELIMITER //

CREATE PROCEDURE GetStudentSubmissionsByTask(
    IN p_subject_name VARCHAR(100),    -- e.g., 'Cryptography and System Security'
    IN p_division VARCHAR(10),         -- e.g., 'B'
    IN p_task_title VARCHAR(255)       -- e.g., 'CSS Mid-Term Assignment'
)
BEGIN
    SELECT 
        s.roll_number,
        s.pid,
        u.full_name AS student_name,
        u.email AS student_email,
        u.contact_number,
        COALESCE(sub.status, 'not_submitted') AS submission_status,
        COALESCE(sub.submission_file_path, 'No submission') AS pdf_path,
        sub.submission_date,
        t.task_type,                   -- Shows if it's ISE1, ISE2, or MSE
        t.total_marks AS maximum_marks,
        COALESCE((
            SELECT SUM(marks_obtained)
            FROM marks m
            WHERE m.submission_id = sub.submission_id
        ), 0) AS obtained_marks
    FROM students s
    JOIN users u ON s.user_id = u.user_id
    JOIN subjects subj ON s.current_semester = subj.semester
    JOIN teacher_subjects ts ON subj.subject_id = ts.subject_id 
        AND s.division = ts.division 
        AND s.academic_year = ts.academic_year
    JOIN tasks t ON ts.teacher_subject_id = t.teacher_subject_id
    LEFT JOIN submissions sub ON t.task_id = sub.task_id 
        AND s.student_id = sub.student_id
    WHERE subj.subject_name = p_subject_name
    AND s.division = p_division
    AND t.title = p_task_title
    ORDER BY s.roll_number;
END //

DELIMITER ;

-- Example usage:
CALL GetStudentSubmissionsByTask('Cryptography and System Security', 'B', 'CSS Mid-Term Assignment');

-- Additional helper procedure to see available tasks for a subject
DELIMITER //

CREATE PROCEDURE GetAvailableTasks(
    IN p_subject_name VARCHAR(100),
    IN p_division VARCHAR(10)
)
BEGIN
    SELECT 
        t.title AS task_name,
        t.task_type,
        t.due_date,
        t.total_marks,
        COUNT(sub.submission_id) AS total_submissions,
        SUM(CASE WHEN sub.status = 'graded' THEN 1 ELSE 0 END) AS graded_submissions
    FROM subjects subj
    JOIN teacher_subjects ts ON subj.subject_id = ts.subject_id
    JOIN tasks t ON ts.teacher_subject_id = t.teacher_subject_id
    LEFT JOIN submissions sub ON t.task_id = sub.task_id
    WHERE subj.subject_name = p_subject_name
    AND ts.division = p_division
    GROUP BY t.task_id, t.title, t.task_type, t.due_date, t.total_marks
    ORDER BY t.due_date;
END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE GetStudentTasksBySemesterSubject(
    IN p_pid VARCHAR(20),
    IN p_semester INTEGER,
    IN p_subject_name VARCHAR(100),
    IN p_status VARCHAR(20) -- New parameter: can be 'pending', 'submitted', or NULL for all tasks
)
BEGIN
    SELECT 
        t.title AS task_name,
        t.task_type,
        t.due_date,
        t.total_marks AS maximum_marks,
        COALESCE(sub.status, 'not_submitted') AS submission_status,
        COALESCE(sub.submission_file_path, 'No submission') AS file_path,
        sub.submission_date,
        COALESCE(SUM(m.marks_obtained), 0) AS obtained_marks,
        GROUP_CONCAT(DISTINCT m.comments SEPARATOR '; ') AS comments
    FROM students s
    JOIN subjects subj ON s.current_semester = subj.semester
    JOIN teacher_subjects ts ON subj.subject_id = ts.subject_id 
        AND s.division = ts.division 
        AND s.academic_year = ts.academic_year
    JOIN tasks t ON ts.teacher_subject_id = t.teacher_subject_id
    LEFT JOIN submissions sub ON t.task_id = sub.task_id 
        AND s.student_id = sub.student_id
    LEFT JOIN marks m ON sub.submission_id = m.submission_id
    WHERE s.pid = p_pid
    AND subj.semester = p_semester
    AND subj.subject_name = p_subject_name
    AND (
        -- If p_status is NULL, show all tasks
        p_status IS NULL
        -- If p_status is 'pending', show tasks with no submission or pending status
        OR (p_status = 'pending' AND (sub.status IS NULL OR sub.status = 'pending'))
        -- If p_status is 'submitted', show only submitted tasks
        OR (p_status = 'submitted' AND sub.status IN ('submitted', 'graded'))
    )
    GROUP BY 
        t.title,
        t.task_type,
        t.due_date,
        t.total_marks,
        sub.status,
        sub.submission_file_path,
        sub.submission_date
    ORDER BY t.due_date;
END //
DELIMITER ;

DELIMITER //

-- Procedure 2: Get Student Details by PID
CREATE PROCEDURE GetStudentDetailsByPID(
    IN p_pid VARCHAR(20)
)
BEGIN
    SELECT 
        u.full_name,
        s.roll_number,
        u.email,
        u.contact_number,
        s.academic_year,
        s.current_year AS class,
        s.current_semester,
        s.division,
        s.pid
    FROM students s
    JOIN users u ON s.user_id = u.user_id
    WHERE s.pid = p_pid;
END //

DELIMITER ;

-- Example usage:
-- To get tasks for a student in a specific semester and subject
CALL GetStudentTasksBySemesterSubject('PID001', 6, 'Mobile Computing','submitted');

-- To get student details
CALL GetStudentDetailsByPID('PID001');
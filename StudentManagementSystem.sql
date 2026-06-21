-- =====================================================
-- COMPLETE REBUILD SCRIPT WITH IC COLUMN
-- =====================================================

USE master;
GO

-- Forcefully close all connections and drop the database
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'StudentManagementSystem')
BEGIN
    DECLARE @kill VARCHAR(8000) = '';
    SELECT @kill = @kill + 'KILL ' + CAST(session_id AS VARCHAR(10)) + ';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID('StudentManagementSystem');
    EXEC(@kill);
    
    DROP DATABASE StudentManagementSystem;
END
GO

-- Create new database
CREATE DATABASE StudentManagementSystem;
GO

USE StudentManagementSystem;
GO

-- ============================================
-- Table: HeadofProgramme
-- ============================================
CREATE TABLE HeadofProgramme (
    HopID       INT IDENTITY(1,1) PRIMARY KEY,
    HopName     NVARCHAR(100) NOT NULL,
    HopEmail    NVARCHAR(100) NOT NULL UNIQUE,
    Password    NVARCHAR(255) NOT NULL,
    ContactNo   NVARCHAR(20),
    UserRole    NVARCHAR(20) NOT NULL DEFAULT 'Admin'
    CONSTRAINT CHK_HopRole CHECK (UserRole = 'Admin')
);

-- ============================================
-- Table: Lecturer
-- ============================================
CREATE TABLE Lecturer (
    LecturerID   INT IDENTITY(1,1) PRIMARY KEY,
    LecturerName NVARCHAR(100) NOT NULL,
    LecturerEmail NVARCHAR(100) NOT NULL UNIQUE,
    Password     NVARCHAR(255) NOT NULL,
    ContactNo    NVARCHAR(20),
    Department   NVARCHAR(100),
    UserRole     NVARCHAR(20) NOT NULL DEFAULT 'Lecturer'
    CONSTRAINT CHK_LecturerRole CHECK (UserRole = 'Lecturer')
);

-- ============================================
-- Table: Programme
-- ============================================
CREATE TABLE Programme (
    ProgrammeCode   NVARCHAR(20) PRIMARY KEY,
    ProgrammeName   NVARCHAR(100) NOT NULL,
    Level           NVARCHAR(20) CHECK (Level IN ('Foundation', 'Certificate', 'Diploma', 'Degree')),
    TotalCreditHours INT NOT NULL,
    Description     NVARCHAR(500)
);

-- ============================================
-- Table: Semester
-- ============================================
CREATE TABLE Semester (
    SemesterID     INT IDENTITY(1,1) PRIMARY KEY,
    Semester       NVARCHAR(10) NOT NULL CHECK (Semester IN ('Jan', 'April', 'August')),
    StartMonthDay  CHAR(5) NOT NULL,
    EndMonthDay    CHAR(5) NOT NULL,
    EnrolStartDate CHAR(5) NULL,
    EnrolEndDate   CHAR(5) NULL,
    CONSTRAINT CHK_StartMonthDay CHECK (StartMonthDay LIKE '[0-9][0-9]-[0-9][0-9]'),
    CONSTRAINT CHK_EndMonthDay   CHECK (EndMonthDay   LIKE '[0-9][0-9]-[0-9][0-9]')
);

-- ============================================
-- Table: Student (with IC column)
-- ============================================
CREATE TABLE Student (
    StudentID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentName    NVARCHAR(100) NOT NULL,
    StudentEmail   NVARCHAR(100) NOT NULL UNIQUE,
    Password       NVARCHAR(255) NOT NULL,
    PersonalEmail  NVARCHAR(100),
    ContactNo      NVARCHAR(20),
    IC             NVARCHAR(20) NOT NULL UNIQUE,          -- IC column added
    SemesterID     INT NOT NULL,
    IntakeYear     INT NOT NULL,
    ProgrammeCode  NVARCHAR(20),
    UserRole       NVARCHAR(20) NOT NULL DEFAULT 'Student',
    ProfilePhotoPath NVARCHAR(500) NULL,
    CONSTRAINT CHK_StudentRole CHECK (UserRole = 'Student'),
    CONSTRAINT FK_Student_Programme FOREIGN KEY (ProgrammeCode) REFERENCES Programme(ProgrammeCode),
    CONSTRAINT FK_Student_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID)
);

-- ============================================
-- Table: Course
-- ============================================
CREATE TABLE Course (
    CourseCode     NVARCHAR(20) PRIMARY KEY,
    CourseName     NVARCHAR(100) NOT NULL,
    CreditHours    INT NOT NULL,
    Description    NVARCHAR(500),
    ProgrammeCode  NVARCHAR(20),
    CONSTRAINT FK_Course_Programme FOREIGN KEY (ProgrammeCode) REFERENCES Programme(ProgrammeCode)
);

-- ============================================
-- Table: CourseOffer
-- ============================================
CREATE TABLE CourseOffer (
    CourseOfferID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode    NVARCHAR(20),
    SemesterID    INT,
    Year          INT NOT NULL,
    OfferStatus   NVARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (OfferStatus IN ('Available', 'Not Available')),
    LecturerID    INT,
    CONSTRAINT FK_CourseOffer_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode),
    CONSTRAINT FK_CourseOffer_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),
    CONSTRAINT FK_CourseOffer_Lecturer FOREIGN KEY (LecturerID) REFERENCES Lecturer(LecturerID)
);

-- ============================================
-- Table: CourseMaterial
-- ============================================
CREATE TABLE CourseMaterial (
    MaterialID         INT IDENTITY(1,1) PRIMARY KEY,
    CourseOfferID      INT NOT NULL,
    MaterialTitle      NVARCHAR(200) NOT NULL,
    Description        NVARCHAR(500),
    FileURL            NVARCHAR(500) NOT NULL,
    ScheduleDate       DATETIME NOT NULL,
    UploadDate         DATETIME NOT NULL DEFAULT GETDATE(),
    UploadByLecturerID INT NULL,
    CONSTRAINT FK_CourseMaterial_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT FK_CourseMaterial_Lecturer FOREIGN KEY (UploadByLecturerID) REFERENCES Lecturer(LecturerID)
);

-- ============================================
-- Table: Enrolment
-- ============================================
CREATE TABLE Enrolment (
    EnrolmentID   INT IDENTITY(1,1) PRIMARY KEY,
    StudentID     INT,
    CourseOfferID INT,
    EnrolStatus   NVARCHAR(20) NOT NULL DEFAULT 'Enrolled' CHECK (EnrolStatus IN ('Enrolled', 'Dropped')),
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Enrolment_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Enrolment_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT UQ_Enrolment UNIQUE (StudentID, CourseOfferID)
);

-- ============================================
-- Table: Assessment
-- ============================================
CREATE TABLE Assessment (
    AssessmentID   INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentName NVARCHAR(50) NOT NULL,
    MaxMarks       DECIMAL(5,2) NOT NULL CHECK (MaxMarks > 0),
    Weightage      DECIMAL(5,2) NOT NULL CHECK (Weightage >= 0 AND Weightage <= 100),
    CourseOfferID  INT,
    CONSTRAINT FK_Assessment_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID)
);

-- ============================================
-- Table: StudentAssessment
-- ============================================
CREATE TABLE StudentAssessment (
    StudentAssessmentID INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentID        INT,
    StudentID           INT,
    ObtainedMark        DECIMAL(5,2) CHECK (ObtainedMark >= 0),
    CONSTRAINT FK_StudentAssessment_Assessment FOREIGN KEY (AssessmentID) REFERENCES Assessment(AssessmentID),
    CONSTRAINT FK_StudentAssessment_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT UQ_StudentAssessment UNIQUE (AssessmentID, StudentID)
);

-- ============================================
-- Table: GradeScale
-- ============================================
CREATE TABLE GradeScale (
    GradeScaleID INT IDENTITY(1,1) PRIMARY KEY,
    MinMarks     DECIMAL(5,2) NOT NULL,
    MaxMarks     DECIMAL(5,2) NOT NULL,
    Grade        NVARCHAR(5) NOT NULL,
    GradePoint   DECIMAL(3,2) NOT NULL,
    CONSTRAINT CHK_GradeRange CHECK (MinMarks <= MaxMarks),
    CONSTRAINT CHK_GradePoint CHECK (GradePoint BETWEEN 0 AND 4.0)
);

-- ============================================
-- Table: AttendanceRecord
-- ============================================
CREATE TABLE AttendanceRecord (
    AttendanceID     INT IDENTITY(1,1) PRIMARY KEY,
    StudentID        INT,
    AttendanceDate   DATE NOT NULL,
    AttendanceStatus NVARCHAR(10) NOT NULL CHECK (AttendanceStatus IN ('Present', 'Late', 'Absent')),
    CourseOfferID    INT,
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Attendance_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT UQ_Attendance UNIQUE (StudentID, CourseOfferID, AttendanceDate)
);

-- ============================================
-- Table: Announcement
-- ============================================
CREATE TABLE Announcement (
    AnnouncementID INT IDENTITY(1,1) PRIMARY KEY,
    Title          NVARCHAR(200) NOT NULL,
    Description    NVARCHAR(MAX),
    TargetType     NVARCHAR(50) NOT NULL,
    TargetValue    NVARCHAR(50) NULL,
    CreatedDate    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CHK_TargetType CHECK (TargetType IN ('CourseCode', 'CourseOfferID', 'ProgrammeCode', 'All'))
);

-- ============================================
-- Table: AcademicCalendar
-- ============================================
CREATE TABLE AcademicCalendar (
    EventID          INT IDENTITY(1,1) PRIMARY KEY,
    EventName        NVARCHAR(100) NOT NULL,
    EventDescription NVARCHAR(500),
    EventDate        DATE NOT NULL,
    CreatedAT        DATETIME NOT NULL DEFAULT GETDATE(),
    TargetRole       NVARCHAR(20) NOT NULL CHECK (TargetRole IN ('Lecturer', 'Student', 'All'))
);

-- ============================================
-- Table: NotificationReadStatus
-- ============================================
CREATE TABLE NotificationReadStatus (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    AnnouncementID INT NOT NULL,
    IsRead BIT NOT NULL DEFAULT 0,
    ReadDate DATETIME NULL,
    CONSTRAINT FK_NotifRead_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_NotifRead_Announcement FOREIGN KEY (AnnouncementID) REFERENCES Announcement(AnnouncementID),
    CONSTRAINT UQ_StudentAnnouncement UNIQUE (StudentID, AnnouncementID)
);

-- ============================================
-- Table: DashboardPreferences
-- ============================================
CREATE TABLE DashboardPreferences (
    PreferenceID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL UNIQUE,
    ShowCurrentCourses BIT NOT NULL DEFAULT 1,
    ShowAcademicSnapshot BIT NOT NULL DEFAULT 1,
    ShowAttendance BIT NOT NULL DEFAULT 1,
    ShowNotifications BIT NOT NULL DEFAULT 1,
    ShowQuickActions BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_DashPref_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- GradeScale
INSERT INTO GradeScale (MinMarks, MaxMarks, Grade, GradePoint)
VALUES
    (0,    39.9, 'F',  0.00),
    (40,   44.9, 'D',  1.00),
    (45,   49.9, 'C-', 1.50),
    (50,   54.9, 'C',  2.00),
    (55,   59.9, 'C+', 2.33),
    (60,   64.9, 'B-', 2.67),
    (65,   69.9, 'B',  3.00),
    (70,   74.9, 'B+', 3.33),
    (75,   79.9, 'A-', 3.67),
    (80,   89.9, 'A',  4.00),
    (90,  100.0, 'A+', 4.00);

-- Semester
INSERT INTO Semester (Semester, StartMonthDay, EndMonthDay, EnrolStartDate, EnrolEndDate)
VALUES 
    ('Jan',    '01-01', '03-31', '01-01', '01-14'),
    ('April',  '04-01', '07-31', '04-01', '04-14'),
    ('August', '08-01', '12-31', '08-01', '08-14');

-- Programme
INSERT INTO Programme (ProgrammeCode, ProgrammeName, Level, TotalCreditHours)
VALUES ('BSECS', 'Bachelor of Software Engineering in Computer Science', 'Degree', 135);

-- HeadofProgramme
INSERT INTO HeadofProgramme (HopName, HopEmail, Password, ContactNo, UserRole)
VALUES ('Dr. Sarah Tan', 'sarah.tan@hop.unitrack', 'Admin@123', '0123456789', 'Admin');

-- Lecturers
INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, ContactNo, Department, UserRole)
VALUES 
('Prof. Ahmad Faiz', 'ahmad.faiz@lecturer.unitrack', 'Lecturer@123', '0198765432', 'Computer Science', 'Lecturer'),
('Dr. Wong Mei Ling', 'meiling.wong@lecturer.unitrack', 'Lecturer@456', '0123456780', 'Software Engineering', 'Lecturer'),
('Mr. Rajesh Kumar', 'rajesh.kumar@lecturer.unitrack', 'Lecturer@789', '0176543210', 'Information Systems', 'Lecturer');

-- Courses
INSERT INTO Course (CourseCode, CourseName, CreditHours, Description, ProgrammeCode)
VALUES 
('CS101', 'Programming Fundamentals', 4, 'Introduction to programming using Python', 'BSECS'),
('CS102', 'Object-Oriented Programming', 4, 'OOP concepts using Java', 'BSECS'),
('CS201', 'Data Structures & Algorithms', 4, 'Essential data structures and algorithm analysis', 'BSECS'),
('CS202', 'Database Management Systems', 3, 'SQL, database design, and normalization', 'BSECS'),
('CS301', 'Software Engineering', 3, 'Software development lifecycle and methodologies', 'BSECS'),
('CS401', 'Final Year Project', 6, 'Capstone project', 'BSECS');

-- CourseOffer (only 2026 offers)
INSERT INTO CourseOffer (CourseCode, SemesterID, Year, OfferStatus, LecturerID)
VALUES 
-- Jan 2026
('CS101', 1, 2026, 'Available', 1),
('CS102', 1, 2026, 'Available', 2),
-- April 2026
('CS201', 2, 2026, 'Available', 1),
('CS202', 2, 2026, 'Available', 2),
-- August 2026
('CS301', 3, 2026, 'Available', 3);

-- Student (with IC)
INSERT INTO Student (StudentName, StudentEmail, Password, PersonalEmail, ContactNo, IC, SemesterID, ProgrammeCode, IntakeYear)
VALUES ('Jonsen', 'jonsen@unitrack.edu.my', '12345', 'sxmen07@gmail.com', '0164099038', 'S1234567A', 1, 'BSECS', 2026);

-- Enrolments for Jan 2026 (CS101, CS102)
DECLARE @CS101_Offer INT = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1);
DECLARE @CS102_Offer INT = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1);

INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus)
VALUES (1, @CS101_Offer, 'Enrolled'),
       (1, @CS102_Offer, 'Enrolled');

-- Assessments for CS101
INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
VALUES 
('Quiz 1', 20, 10, @CS101_Offer),
('Quiz 2', 20, 10, @CS101_Offer),
('Assignment', 100, 20, @CS101_Offer),
('Midterm Exam', 100, 30, @CS101_Offer),
('Final Exam', 100, 30, @CS101_Offer);

-- Assessments for CS102
INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
VALUES 
('Quiz 1', 15, 10, @CS102_Offer),
('Quiz 2', 15, 10, @CS102_Offer),
('Group Project', 100, 30, @CS102_Offer),
('Midterm', 100, 25, @CS102_Offer),
('Final Exam', 100, 25, @CS102_Offer);

-- StudentAssessment (marks)
-- CS101 marks
INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
SELECT AssessmentID, 1, 
    CASE AssessmentName 
        WHEN 'Quiz 1' THEN 18.5
        WHEN 'Quiz 2' THEN 19.0
        WHEN 'Assignment' THEN 85.0
        WHEN 'Midterm Exam' THEN 78.0
        WHEN 'Final Exam' THEN 82.0
    END
FROM Assessment WHERE CourseOfferID = @CS101_Offer;

-- CS102 marks
INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
SELECT AssessmentID, 1,
    CASE AssessmentName 
        WHEN 'Quiz 1' THEN 14.0
        WHEN 'Quiz 2' THEN 13.5
        WHEN 'Group Project' THEN 88.0
        WHEN 'Midterm' THEN 72.0
        WHEN 'Final Exam' THEN 79.0
    END
FROM Assessment WHERE CourseOfferID = @CS102_Offer;

-- Attendance for CS101 (Jan 2026)
INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
VALUES 
(1, '2026-01-05', 'Present', @CS101_Offer),
(1, '2026-01-07', 'Present', @CS101_Offer),
(1, '2026-01-12', 'Late',   @CS101_Offer),
(1, '2026-01-14', 'Absent', @CS101_Offer),
(1, '2026-01-19', 'Present', @CS101_Offer);

-- Attendance for CS102 (Jan 2026)
INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
VALUES 
(1, '2026-01-06', 'Present', @CS102_Offer),
(1, '2026-01-08', 'Present', @CS102_Offer),
(1, '2026-01-13', 'Late',   @CS102_Offer),
(1, '2026-01-15', 'Present', @CS102_Offer),
(1, '2026-01-20', 'Present', @CS102_Offer);

-- Announcements
INSERT INTO Announcement (Title, Description, TargetType, TargetValue, CreatedDate)
VALUES 
('Welcome to New Semester', 'Jan 2026 semester starts on 1st Jan. Please check your timetable.', 'All', NULL, GETDATE()),
('CS101 Quiz 1 Reminder', 'Quiz 1 will be held on 15th Jan during lecture.', 'CourseCode', 'CS101', GETDATE()),
('CS201 Midterm Preparation', 'Midterm exam on 20th March. Review lectures 1-5.', 'CourseCode', 'CS201', GETDATE()),
('BSECS Programme Meeting', 'All BSECS students attend a meeting on 10th Jan at 2pm.', 'ProgrammeCode', 'BSECS', GETDATE());

-- Academic Calendar
INSERT INTO AcademicCalendar (EventName, EventDescription, EventDate, TargetRole)
VALUES 
('Semester Begins', 'Start of Jan 2026 semester', '2026-01-01', 'All'),
('Add/Drop Period Ends', 'Last day to add or drop courses', '2026-01-14', 'Student'),
('Midterm Exams Week', 'Midterm examinations for all courses', '2026-02-20', 'All'),
('Final Exams Week', 'Final examinations for Jan semester', '2026-03-20', 'All'),
('Semester Break', 'Holiday between semesters', '2026-04-01', 'All'),
('Lecturer Workshop', 'Workshop on new teaching methods', '2026-02-10', 'Lecturer');

-- ============================================
-- Enrol Student 1 in CS201 & CS202 (April 2026)
-- ============================================

DECLARE @StudentID INT = 1;
DECLARE @SemesterID INT = 2;   -- April
DECLARE @Year INT = 2026;

-- Get CourseOfferIDs for CS201 and CS202 in April 2026
DECLARE @CS201_OfferID INT = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS201' AND SemesterID = @SemesterID AND Year = @Year);
DECLARE @CS202_OfferID INT = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS202' AND SemesterID = @SemesterID AND Year = @Year);

-- Insert enrolments if they don't already exist
IF @CS201_OfferID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CS201_OfferID)
BEGIN
    INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate)
    VALUES (@StudentID, @CS201_OfferID, 'Enrolled', GETDATE());
    PRINT 'Enrolled Student 1 in CS201 (April 2026)';
END
ELSE
    PRINT 'CS201 enrolment already exists or CourseOffer not found.';

IF @CS202_OfferID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CS202_OfferID)
BEGIN
    INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate)
    VALUES (@StudentID, @CS202_OfferID, 'Enrolled', GETDATE());
    PRINT 'Enrolled Student 1 in CS202 (April 2026)';
END
ELSE
    PRINT 'CS202 enrolment already exists or CourseOffer not found.';

-- ============================================
-- Add assessments and marks for CS201
-- ============================================
IF @CS201_OfferID IS NOT NULL
BEGIN
    -- Insert assessments for CS201 if not already present
    IF NOT EXISTS (SELECT 1 FROM Assessment WHERE CourseOfferID = @CS201_OfferID)
    BEGIN
        INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
        VALUES 
            ('Quiz 1', 20, 10, @CS201_OfferID),
            ('Quiz 2', 20, 10, @CS201_OfferID),
            ('Assignment', 100, 20, @CS201_OfferID),
            ('Midterm Exam', 100, 30, @CS201_OfferID),
            ('Final Exam', 100, 30, @CS201_OfferID);
        PRINT 'Added assessments for CS201 (April 2026)';
    END

    -- Insert sample marks for Student 1
    DECLARE @AssessID INT;
    DECLARE @AssessName NVARCHAR(50);
    DECLARE cur CURSOR FOR 
        SELECT AssessmentID, AssessmentName FROM Assessment WHERE CourseOfferID = @CS201_OfferID;
    OPEN cur;
    FETCH NEXT FROM cur INTO @AssessID, @AssessName;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM StudentAssessment WHERE AssessmentID = @AssessID AND StudentID = @StudentID)
        BEGIN
            INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
            VALUES (@AssessID, @StudentID,
                CASE @AssessName
                    WHEN 'Quiz 1' THEN 17.5
                    WHEN 'Quiz 2' THEN 18.0
                    WHEN 'Assignment' THEN 82.0
                    WHEN 'Midterm Exam' THEN 74.0
                    WHEN 'Final Exam' THEN 80.0
                    ELSE 0
                END);
        END
        FETCH NEXT FROM cur INTO @AssessID, @AssessName;
    END
    CLOSE cur;
    DEALLOCATE cur;
    PRINT 'Added student marks for CS201';
END

-- ============================================
-- Add assessments and marks for CS202
-- ============================================
IF @CS202_OfferID IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Assessment WHERE CourseOfferID = @CS202_OfferID)
    BEGIN
        INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
        VALUES 
            ('Quiz 1', 15, 10, @CS202_OfferID),
            ('Quiz 2', 15, 10, @CS202_OfferID),
            ('Group Project', 100, 30, @CS202_OfferID),
            ('Midterm', 100, 25, @CS202_OfferID),
            ('Final Exam', 100, 25, @CS202_OfferID);
        PRINT 'Added assessments for CS202 (April 2026)';
    END

    DECLARE @AssessID2 INT;
    DECLARE @AssessName2 NVARCHAR(50);
    DECLARE cur2 CURSOR FOR 
        SELECT AssessmentID, AssessmentName FROM Assessment WHERE CourseOfferID = @CS202_OfferID;
    OPEN cur2;
    FETCH NEXT FROM cur2 INTO @AssessID2, @AssessName2;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM StudentAssessment WHERE AssessmentID = @AssessID2 AND StudentID = @StudentID)
        BEGIN
            INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
            VALUES (@AssessID2, @StudentID,
                CASE @AssessName2
                    WHEN 'Quiz 1' THEN 13.0
                    WHEN 'Quiz 2' THEN 14.5
                    WHEN 'Group Project' THEN 86.0
                    WHEN 'Midterm' THEN 70.0
                    WHEN 'Final Exam' THEN 77.0
                    ELSE 0
                END);
        END
        FETCH NEXT FROM cur2 INTO @AssessID2, @AssessName2;
    END
    CLOSE cur2;
    DEALLOCATE cur2;
    PRINT 'Added student marks for CS202';
END

-- ============================================
-- Add attendance records for April 2026
-- ============================================
-- For CS201
IF @CS201_OfferID IS NOT NULL
BEGIN
    DELETE FROM AttendanceRecord WHERE CourseOfferID = @CS201_OfferID AND StudentID = @StudentID;
    INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
    VALUES 
        (1, '2026-04-06', 'Present', @CS201_OfferID),
        (1, '2026-04-08', 'Present', @CS201_OfferID),
        (1, '2026-04-13', 'Late',    @CS201_OfferID),
        (1, '2026-04-15', 'Absent',  @CS201_OfferID),
        (1, '2026-04-20', 'Present', @CS201_OfferID);
    PRINT 'Added attendance for CS201';
END

-- For CS202
IF @CS202_OfferID IS NOT NULL
BEGIN
    DELETE FROM AttendanceRecord WHERE CourseOfferID = @CS202_OfferID AND StudentID = @StudentID;
    INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
    VALUES 
        (1, '2026-04-07', 'Present', @CS202_OfferID),
        (1, '2026-04-09', 'Present', @CS202_OfferID),
        (1, '2026-04-14', 'Present', @CS202_OfferID),
        (1, '2026-04-16', 'Late',    @CS202_OfferID),
        (1, '2026-04-21', 'Absent',  @CS202_OfferID);
    PRINT 'Added attendance for CS202';
END

PRINT 'All operations completed.';

-- ============================================
-- Table: StudentCourseStatus
-- Tracks student progression through each course
-- ============================================
CREATE TABLE StudentCourseStatus (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseOfferID INT NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Enrolled', 'In Progress', 'Completed', 'Failed', 'Dropped')),
    ProgressPercentage DECIMAL(5,2) NULL DEFAULT 0,
    FinalMark DECIMAL(5,2) NULL,
    FinalGrade NVARCHAR(5) NULL,
    GradePoint DECIMAL(3,2) NULL,
    StartedDate DATETIME NULL DEFAULT GETDATE(),
    CompletedDate DATETIME NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_SCS_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_SCS_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT UQ_SCS UNIQUE (StudentID, CourseOfferID)
);
GO


-- Final verification
PRINT 'Database successfully created with IC column in Student table.';
SELECT * FROM Student;
SELECT * FROM CourseOffer;
SELECT * FROM Enrolment;

-- List all user tables and fetch all rows
SELECT '=== HeadofProgramme ===' AS TableName;
SELECT * FROM HeadofProgramme;

SELECT '=== Lecturer ===' AS TableName;
SELECT * FROM Lecturer;

SELECT '=== Programme ===' AS TableName;
SELECT * FROM Programme;

SELECT '=== Semester ===' AS TableName;
SELECT * FROM Semester;

SELECT '=== Student ===' AS TableName;
SELECT * FROM Student;

SELECT '=== Course ===' AS TableName;
SELECT * FROM Course;

SELECT '=== CourseOffer ===' AS TableName;
SELECT * FROM CourseOffer;

SELECT '=== CourseMaterial ===' AS TableName;
SELECT * FROM CourseMaterial;

SELECT '=== Enrolment ===' AS TableName;
SELECT * FROM Enrolment;

SELECT '=== Assessment ===' AS TableName;
SELECT * FROM Assessment;

SELECT '=== StudentAssessment ===' AS TableName;
SELECT * FROM StudentAssessment;

SELECT '=== GradeScale ===' AS TableName;
SELECT * FROM GradeScale;

SELECT '=== AttendanceRecord ===' AS TableName;
SELECT * FROM AttendanceRecord;

SELECT '=== Announcement ===' AS TableName;
SELECT * FROM Announcement;

SELECT '=== AcademicCalendar ===' AS TableName;
SELECT * FROM AcademicCalendar;

SELECT '=== NotificationReadStatus ===' AS TableName;
SELECT * FROM NotificationReadStatus;

SELECT '=== DashboardPreferences ===' AS TableName;
SELECT * FROM DashboardPreferences;

-- Check which CourseOffer records exist for CS201 and CS202
SELECT co.CourseOfferID, co.CourseCode, co.Year, co.SemesterID, s.Semester
FROM CourseOffer co
INNER JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE co.CourseCode IN ('CS201', 'CS202');

-- Check which CourseOffer the student is actually enrolled in
SELECT e.CourseOfferID, co.CourseCode, co.Year, s.Semester
FROM Enrolment e
INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
INNER JOIN Semester s ON co.SemesterID = s.SemesterID
WHERE e.StudentID = 1;

SELECT CourseOfferID, CourseCode, SemesterID, Year FROM CourseOffer WHERE CourseCode IN ('CS101', 'CS102', 'CS201', 'CS202');

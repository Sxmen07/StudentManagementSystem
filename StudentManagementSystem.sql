-- =====================================================
-- COMPLETE REBUILD SCRIPT – StudentManagementSystem
-- Fixed: batch separators, foreign keys, ID references
-- =====================================================

USE master;
GO

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

CREATE DATABASE StudentManagementSystem;
GO

USE StudentManagementSystem;
GO

-- ============================================
-- 1. TABLES
-- ============================================

CREATE TABLE HeadofProgramme (
    HopID              INT IDENTITY(1,1) PRIMARY KEY,
    HopName            NVARCHAR(100) NOT NULL,
    HopEmail           NVARCHAR(100) NOT NULL UNIQUE,
    Password           NVARCHAR(255) NOT NULL,
    ContactNo          NVARCHAR(20),
    UserRole           NVARCHAR(20) NOT NULL DEFAULT 'Admin',
    ProfilePictureUrl  NVARCHAR(MAX) NULL,
    BannerPictureUrl   VARCHAR(MAX) NULL,
    IdentityNumber     NVARCHAR(50) NULL,
    ResetToken         VARCHAR(50) NULL,
    ResetTokenExpiresAt DATETIME NULL,
    CONSTRAINT CHK_HopRole CHECK (UserRole = 'Admin')
);
GO

CREATE TABLE Lecturer (
    LecturerID         INT IDENTITY(1,1) PRIMARY KEY,
    LecturerName       NVARCHAR(100) NOT NULL,
    LecturerEmail      NVARCHAR(100) NOT NULL UNIQUE,
    Password           NVARCHAR(255) NOT NULL,
    ContactNo          NVARCHAR(20),
    Department         NVARCHAR(100),
    UserRole           NVARCHAR(20) NOT NULL DEFAULT 'Lecturer',
    ProfilePictureUrl  NVARCHAR(MAX) NULL,
    BannerPictureUrl   VARCHAR(MAX) NULL,
    IdentityNumber     NVARCHAR(50) NULL,
    ResetToken         VARCHAR(50) NULL,
    ResetTokenExpiresAt DATETIME NULL,
    CONSTRAINT CHK_LecturerRole CHECK (UserRole = 'Lecturer')
);
GO

CREATE TABLE Faculty (
    FacultyID   INT IDENTITY(1,1) PRIMARY KEY,
    FacultyName NVARCHAR(150) NOT NULL UNIQUE
);
GO

CREATE TABLE Programme (
    ProgrammeCode    NVARCHAR(20) PRIMARY KEY,
    ProgrammeName    NVARCHAR(100) NOT NULL,
    Level            NVARCHAR(20) CHECK (Level IN ('Foundation', 'Certificate', 'Diploma', 'Degree')),
    TotalCreditHours INT NOT NULL,
    Description      NVARCHAR(500),
    FacultyID        INT NULL,
    PricePerCourse   DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    CONSTRAINT FK_Programme_Faculty FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
GO

CREATE TABLE Semester (
    SemesterID     INT IDENTITY(1,1) PRIMARY KEY,
    Semester       NVARCHAR(10) NOT NULL CHECK (Semester IN ('Jan', 'April', 'August')),
    StartMonthDay  CHAR(5) NOT NULL,
    EndMonthDay    CHAR(5) NOT NULL,
    EnrolStartDate CHAR(5) NULL,
    EnrolEndDate   CHAR(5) NULL,
    AcademicYear   INT NOT NULL DEFAULT 2026,
    CONSTRAINT CHK_StartMonthDay CHECK (StartMonthDay LIKE '[0-9][0-9]-[0-9][0-9]'),
    CONSTRAINT CHK_EndMonthDay   CHECK (EndMonthDay   LIKE '[0-9][0-9]-[0-9][0-9]')
);
GO

CREATE TABLE Student (
    StudentID         INT IDENTITY(1,1) PRIMARY KEY,
    StudentName       NVARCHAR(100) NOT NULL,
    StudentEmail      NVARCHAR(100) NOT NULL UNIQUE,
    Password          NVARCHAR(255) NOT NULL,
    PersonalEmail     NVARCHAR(100),
    ContactNo         NVARCHAR(20),
    IC                NVARCHAR(20) NOT NULL UNIQUE,
    SemesterID        INT NOT NULL,
    IntakeYear        INT NOT NULL,
    ProgrammeCode     NVARCHAR(20),
    UserRole          NVARCHAR(20) NOT NULL DEFAULT 'Student',
    ProfilePhotoPath  NVARCHAR(500) NULL,
    ProfilePictureUrl NVARCHAR(MAX) NULL,
    BannerPictureUrl  VARCHAR(MAX) NULL,
    IdentityNumber    NVARCHAR(50) NULL,
    ResetToken        VARCHAR(50) NULL,
    ResetTokenExpiresAt DATETIME NULL,
    CONSTRAINT CHK_StudentRole CHECK (UserRole = 'Student'),
    CONSTRAINT FK_Student_Programme FOREIGN KEY (ProgrammeCode) REFERENCES Programme(ProgrammeCode),
    CONSTRAINT FK_Student_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID)
);
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Student') AND name = 'ProgrammeCode')
BEGIN
    ALTER TABLE Student ADD ProgrammeCode VARCHAR(20) NULL;
END
GO

CREATE TABLE Course (
    CourseCode     NVARCHAR(20) PRIMARY KEY,
    CourseName     NVARCHAR(100) NOT NULL,
    CreditHours    INT NOT NULL,
    Description    NVARCHAR(500),
    ProgrammeCode  NVARCHAR(20),
    CONSTRAINT FK_Course_Programme FOREIGN KEY (ProgrammeCode) REFERENCES Programme(ProgrammeCode)
);
GO

CREATE TABLE CourseOffer (
    CourseOfferID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode    NVARCHAR(20),
    SemesterID    INT,
    Year          INT NOT NULL,
    OfferStatus   NVARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (OfferStatus IN ('Available', 'Not Available')),
    LecturerID    INT,
    MaxCapacity   INT NOT NULL DEFAULT 40,
    CONSTRAINT FK_CourseOffer_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode),
    CONSTRAINT FK_CourseOffer_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),
    CONSTRAINT FK_CourseOffer_Lecturer FOREIGN KEY (LecturerID) REFERENCES Lecturer(LecturerID)
);
GO

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
GO

ALTER TABLE CourseMaterial ADD MaterialCategory NVARCHAR(50);

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
GO

CREATE TABLE Assessment (
    AssessmentID   INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentName NVARCHAR(50) NOT NULL,
    MaxMarks       DECIMAL(5,2) NOT NULL CHECK (MaxMarks > 0),
    Weightage      DECIMAL(5,2) NOT NULL CHECK (Weightage >= 0 AND Weightage <= 100),
    CourseOfferID  INT,
    CONSTRAINT FK_Assessment_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID)
);
GO

CREATE TABLE StudentAssessment (
    StudentAssessmentID INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentID        INT,
    StudentID           INT,
    ObtainedMark        DECIMAL(5,2) CHECK (ObtainedMark >= 0),
    CONSTRAINT FK_StudentAssessment_Assessment FOREIGN KEY (AssessmentID) REFERENCES Assessment(AssessmentID),
    CONSTRAINT FK_StudentAssessment_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT UQ_StudentAssessment UNIQUE (AssessmentID, StudentID)
);
GO

CREATE TABLE GradeScale (
    GradeScaleID INT IDENTITY(1,1) PRIMARY KEY,
    MinMarks     DECIMAL(5,2) NOT NULL,
    MaxMarks     DECIMAL(5,2) NOT NULL,
    Grade        NVARCHAR(5) NOT NULL,
    GradePoint   DECIMAL(3,2) NOT NULL,
    CONSTRAINT CHK_GradeRange CHECK (MinMarks <= MaxMarks),
    CONSTRAINT CHK_GradePoint CHECK (GradePoint BETWEEN 0 AND 4.0)
);
GO

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
GO

CREATE TABLE Announcement (
    AnnouncementID INT IDENTITY(1,1) PRIMARY KEY,
    Title          NVARCHAR(200) NOT NULL,
    Description    NVARCHAR(MAX),
    TargetType     NVARCHAR(50) NOT NULL,
    TargetValue    NVARCHAR(50) NULL,
    CreatedDate    DATETIME NOT NULL DEFAULT GETDATE(),
    AttachmentPath NVARCHAR(255) NULL,
    CONSTRAINT CHK_TargetType CHECK (TargetType IN ('CourseCode', 'CourseOfferID', 'ProgrammeCode', 'All'))
);
GO

CREATE TABLE EmailLog (
    EmailLogID     INT IDENTITY(1,1) PRIMARY KEY,
    AnnouncementID INT NULL,
    ToEmail        NVARCHAR(255) NULL,
    Subject        NVARCHAR(255) NULL,
    Body           NVARCHAR(MAX) NULL,
    SentDate       DATETIME DEFAULT GETDATE(),
    Status         NVARCHAR(50) NULL
);
GO

CREATE TABLE AcademicCalendar (
    EventID          INT IDENTITY(1,1) PRIMARY KEY,
    EventName        NVARCHAR(150) NOT NULL,
    EventDescription NVARCHAR(500) NULL,
    EventDate        DATE NOT NULL,
    SemesterID       INT NOT NULL,
    HexColor         NVARCHAR(20) NOT NULL DEFAULT '#3B82F6',
    TargetRole       NVARCHAR(20) NOT NULL DEFAULT 'All',
    CreatedAT        DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Calendar_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),
    CONSTRAINT CHK_TargetRole_Calendar CHECK (TargetRole IN ('Lecturer', 'Student', 'All'))
);
GO

CREATE TABLE NotificationReadStatus (
    StatusID       INT IDENTITY(1,1) PRIMARY KEY,
    StudentID      INT NOT NULL,
    AnnouncementID INT NOT NULL,
    IsRead         BIT NOT NULL DEFAULT 0,
    ReadDate       DATETIME NULL,
    CONSTRAINT FK_NotifRead_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_NotifRead_Announcement FOREIGN KEY (AnnouncementID) REFERENCES Announcement(AnnouncementID),
    CONSTRAINT UQ_StudentAnnouncement UNIQUE (StudentID, AnnouncementID)
);
GO

CREATE TABLE DashboardPreferences (
    PreferenceID        INT IDENTITY(1,1) PRIMARY KEY,
    StudentID           INT NOT NULL UNIQUE,
    ShowCurrentCourses  BIT NOT NULL DEFAULT 1,
    ShowAcademicSnapshot BIT NOT NULL DEFAULT 1,
    ShowAttendance      BIT NOT NULL DEFAULT 1,
    ShowNotifications   BIT NOT NULL DEFAULT 1,
    ShowQuickActions    BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_DashPref_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);
GO

CREATE TABLE StudentCourseStatus (
    StatusID            INT IDENTITY(1,1) PRIMARY KEY,
    StudentID           INT NOT NULL,
    CourseOfferID       INT NOT NULL,
    Status              NVARCHAR(20) NOT NULL CHECK (Status IN ('Enrolled', 'In Progress', 'Completed', 'Failed', 'Dropped')),
    ProgressPercentage  DECIMAL(5,2) NULL DEFAULT 0,
    FinalMark           DECIMAL(5,2) NULL,
    FinalGrade          NVARCHAR(5) NULL,
    GradePoint          DECIMAL(3,2) NULL,
    StartedDate         DATETIME NULL DEFAULT GETDATE(),
    CompletedDate       DATETIME NULL,
    IsCurrent           BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_SCS_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_SCS_CourseOffer FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT UQ_SCS UNIQUE (StudentID, CourseOfferID)
);
GO

CREATE TABLE InvoiceReceipt (
    InvoiceID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentID      INT NOT NULL,
    SemesterID     INT NOT NULL,
    TotalAmount    DECIMAL(10,2) NOT NULL,
    IssueDate      DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentStatus  VARCHAR(20) NOT NULL DEFAULT 'PENDING'
);
GO

CREATE TABLE AdminMessage (
    MessageID      INT IDENTITY(1,1) PRIMARY KEY,
    SenderEmail    VARCHAR(100) NOT NULL,
    Subject        VARCHAR(150) NOT NULL,
    MessageText    NVARCHAR(MAX) NOT NULL,
    SubmissionDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE AdminAnnouncement (
    AnnouncementID  INT IDENTITY(1,1) PRIMARY KEY,
    Title           NVARCHAR(150) NOT NULL,
    ContentText     NVARCHAR(MAX) NOT NULL,
    TargetAdmin     BIT NOT NULL DEFAULT 0,
    TargetLecturer  BIT NOT NULL DEFAULT 0,
    TargetStudent   BIT NOT NULL DEFAULT 0,
    CreatedDate     DATETIME DEFAULT GETDATE(),
    SenderAdminID   INT NULL
);
GO

CREATE TABLE PaymentRecord (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    StudentID       INT NOT NULL,
    InvoiceID       INT NULL,                    -- Optional: link to InvoiceReceipt
    SemesterID      INT NOT NULL,                -- Which semester this payment is for
    ReferenceID     NVARCHAR(50) NOT NULL UNIQUE, -- e.g., "PAY-2026-001"
    Amount          DECIMAL(10,2) NOT NULL,
    PaymentDate     DATETIME NULL,               -- Date student made the payment (actual)
    UploadDate      DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentProof    NVARCHAR(500) NULL,           -- File path to uploaded receipt/image
    StudentStatus   NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Student's view: Pending, Success, Failed
    VerifiedStatus  NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Finance: Pending, Verified, Rejected
    VerifiedBy      INT NULL,                    -- Admin/Finance staff ID
    VerifiedDate    DATETIME NULL,
    Comments        NVARCHAR(500) NULL,          -- Finance rejection reason or notes
    CONSTRAINT FK_Payment_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Payment_Semester FOREIGN KEY (SemesterID) REFERENCES Semester(SemesterID),
    CONSTRAINT CHK_StudentStatus CHECK (StudentStatus IN ('Pending', 'Success', 'Failed')),
    CONSTRAINT CHK_VerifiedStatus CHECK (VerifiedStatus IN ('Pending', 'Verified', 'Rejected'))
);

-- ============================================
-- 2. COMPUTED COLUMNS
-- ============================================

ALTER TABLE HeadofProgramme ADD CustomRoleID AS ('A' + CAST(HopID AS VARCHAR(10)));
ALTER TABLE HeadofProgramme ADD DisplayID AS ('A' + CAST(HopID + 1000 AS VARCHAR(20))) PERSISTED;
GO

ALTER TABLE Lecturer ADD CustomRoleID AS ('L' + CAST(LecturerID AS VARCHAR(10)));
ALTER TABLE Lecturer ADD DisplayID AS ('L' + CAST(LecturerID + 1000 AS VARCHAR(20))) PERSISTED;
GO

ALTER TABLE Student ADD CustomRoleID AS ('S' + CAST(StudentID AS VARCHAR(10)));
ALTER TABLE Student ADD DisplayID AS ('S' + CAST(StudentID + 1000 AS VARCHAR(20))) PERSISTED;
GO

-- ============================================
-- 3. VIEWS
-- ============================================

CREATE OR ALTER VIEW Vw_AdminAttendanceRegistry AS
SELECT 
    f.FacultyID,
    f.FacultyName AS SchoolName,
    p.ProgrammeCode,
    p.ProgrammeName,
    c.CourseCode,
    c.CourseName,
    l.LecturerID,
    l.LecturerName,
    att.AttendanceDate,
    s.CustomRoleID AS StudentRoleID,
    s.StudentID,
    s.StudentName,
    s.ProfilePictureUrl,
    att.AttendanceStatus
FROM AttendanceRecord att
INNER JOIN Student s ON att.StudentID = s.StudentID
INNER JOIN CourseOffer co ON att.CourseOfferID = co.CourseOfferID
INNER JOIN Course c ON co.CourseCode = c.CourseCode
INNER JOIN Lecturer l ON co.LecturerID = l.LecturerID
INNER JOIN Programme p ON s.ProgrammeCode = p.ProgrammeCode
INNER JOIN Faculty f ON p.FacultyID = f.FacultyID;
GO

CREATE OR ALTER VIEW Vw_EnrollmentCapacityRegistry AS
SELECT 
    co.CourseOfferID,
    co.CourseCode,
    c.CourseName,
    p.ProgrammeCode,
    p.ProgrammeName,
    f.FacultyID,
    f.FacultyName AS SchoolName,
    s.SemesterID,
    s.Semester,
    co.LecturerID,
    l.LecturerName,
    co.MaxCapacity,
    (SELECT COUNT(1) FROM Enrolment e WHERE e.CourseOfferID = co.CourseOfferID AND e.EnrolStatus = 'Enrolled') AS TotalEnrolled
FROM CourseOffer co
INNER JOIN Course c ON co.CourseCode = c.CourseCode
INNER JOIN Programme p ON c.ProgrammeCode = p.ProgrammeCode
INNER JOIN Faculty f ON p.FacultyID = f.FacultyID
INNER JOIN Semester s ON co.SemesterID = s.SemesterID
INNER JOIN Lecturer l ON co.LecturerID = l.LecturerID;
GO

-- ============================================
-- 4. RESEED IDENTITIES TO START FROM 1000
-- ============================================

DBCC CHECKIDENT ('HeadofProgramme', RESEED, 999);
DBCC CHECKIDENT ('Lecturer', RESEED, 999);
DBCC CHECKIDENT ('Student', RESEED, 999);
GO

-- ============================================
-- 5. SAMPLE DATA INSERTS
-- ============================================

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
GO

INSERT INTO Semester (Semester, StartMonthDay, EndMonthDay, EnrolStartDate, EnrolEndDate, AcademicYear)
VALUES 
    ('Jan',    '01-01', '03-31', '01-01', '01-14', 2026),
    ('April',  '04-01', '07-31', '04-01', '04-14', 2026),
    ('August', '08-01', '12-31', '08-01', '08-14', 2026);
GO

UPDATE Semester SET EnrolEndDate = '04-14' WHERE Semester = 'April'

INSERT INTO Faculty (FacultyName) VALUES ('Faculty of Computing and Informatics'), ('Faculty of Business');
GO

INSERT INTO Programme (ProgrammeCode, ProgrammeName, Level, TotalCreditHours, FacultyID, PricePerCourse)
VALUES ('BSECS', 'Bachelor of Software Engineering in Computer Science', 'Degree', 135, 1, 500.00);
GO

INSERT INTO HeadofProgramme (HopName, HopEmail, Password, ContactNo, UserRole)
VALUES ('Dr. Sarah Tan', 'sarah.tan@hop.unitrack', 'Admin@123', '0123456789', 'Admin');
GO

INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, ContactNo, Department, UserRole)
VALUES 
    ('Prof. Ahmad Faiz', 'ahmad.faiz@lecturer.unitrack', 'Lecturer@123', '0198765432', 'Computer Science', 'Lecturer'),
    ('Dr. Wong Mei Ling', 'meiling.wong@lecturer.unitrack', 'Lecturer@456', '0123456780', 'Software Engineering', 'Lecturer'),
    ('Mr. Rajesh Kumar', 'rajesh.kumar@lecturer.unitrack', 'Lecturer@789', '0176543210', 'Information Systems', 'Lecturer');
GO

INSERT INTO Course (CourseCode, CourseName, CreditHours, Description, ProgrammeCode)
VALUES 
    ('CS101', 'Programming Fundamentals', 4, 'Introduction to programming using Python', 'BSECS'),
    ('CS102', 'Object-Oriented Programming', 4, 'OOP concepts using Java', 'BSECS'),
    ('CS201', 'Data Structures & Algorithms', 4, 'Essential data structures and algorithm analysis', 'BSECS'),
    ('CS202', 'Database Management Systems', 3, 'SQL, database design, and normalization', 'BSECS'),
    ('CS301', 'Software Engineering', 3, 'Software development lifecycle and methodologies', 'BSECS'),
    ('CS401', 'Final Year Project', 6, 'Capstone project', 'BSECS');
GO

-- Insert CourseOffer – using subqueries for LecturerID based on email
INSERT INTO CourseOffer (CourseCode, SemesterID, Year, OfferStatus, LecturerID, MaxCapacity)
VALUES 
    ('CS101', 1, 2026, 'Available', (SELECT LecturerID FROM Lecturer WHERE LecturerEmail = 'ahmad.faiz@lecturer.unitrack'), 30),
    ('CS102', 1, 2026, 'Available', (SELECT LecturerID FROM Lecturer WHERE LecturerEmail = 'meiling.wong@lecturer.unitrack'), 30),
    ('CS201', 2, 2026, 'Available', (SELECT LecturerID FROM Lecturer WHERE LecturerEmail = 'ahmad.faiz@lecturer.unitrack'), 25),
    ('CS202', 2, 2026, 'Available', (SELECT LecturerID FROM Lecturer WHERE LecturerEmail = 'meiling.wong@lecturer.unitrack'), 25),
    ('CS301', 3, 2026, 'Available', (SELECT LecturerID FROM Lecturer WHERE LecturerEmail = 'rajesh.kumar@lecturer.unitrack'), 20);
GO

-- Insert Student – we will capture the ID using a variable or later subquery
INSERT INTO Student (StudentName, StudentEmail, Password, PersonalEmail, ContactNo, IC, SemesterID, ProgrammeCode, IntakeYear)
VALUES ('Jonsen', 'jonsen@unitrack.edu.my', '12345', 'sxmen07@gmail.com', '0164099038', 'S1234567A', 1, 'BSECS', 2026);
GO

-- Now use subqueries for StudentID and CourseOfferID in subsequent inserts

-- Enrolment for Jan 2026
INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus)
VALUES 
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'),
     (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1),
     'Enrolled'),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'),
     (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1),
     'Enrolled');
GO

-- Assessments for CS101
INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
SELECT 
    AssessmentName, MaxMarks, Weightage, 
    (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1)
FROM (VALUES 
    ('Quiz 1', 20, 10),
    ('Quiz 2', 20, 10),
    ('Assignment', 100, 20),
    ('Midterm Exam', 100, 30),
    ('Final Exam', 100, 30)
) AS A(AssessmentName, MaxMarks, Weightage);
GO

-- Assessments for CS102
INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
SELECT 
    AssessmentName, MaxMarks, Weightage, 
    (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1)
FROM (VALUES 
    ('Quiz 1', 15, 10),
    ('Quiz 2', 15, 10),
    ('Group Project', 100, 30),
    ('Midterm', 100, 25),
    ('Final Exam', 100, 25)
) AS A(AssessmentName, MaxMarks, Weightage);
GO

-- StudentAssessment for CS101
INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
SELECT 
    AssessmentID, 
    (SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'),
    CASE AssessmentName 
        WHEN 'Quiz 1' THEN 18.5
        WHEN 'Quiz 2' THEN 19.0
        WHEN 'Assignment' THEN 85.0
        WHEN 'Midterm Exam' THEN 78.0
        WHEN 'Final Exam' THEN 82.0
    END
FROM Assessment 
WHERE CourseOfferID = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1);
GO

-- StudentAssessment for CS102
INSERT INTO StudentAssessment (AssessmentID, StudentID, ObtainedMark)
SELECT 
    AssessmentID, 
    (SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'),
    CASE AssessmentName 
        WHEN 'Quiz 1' THEN 14.0
        WHEN 'Quiz 2' THEN 13.5
        WHEN 'Group Project' THEN 88.0
        WHEN 'Midterm' THEN 72.0
        WHEN 'Final Exam' THEN 79.0
    END
FROM Assessment 
WHERE CourseOfferID = (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1);
GO

-- Attendance for CS101
INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
VALUES 
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-05', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-07', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-12', 'Late',    (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-14', 'Absent',  (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-19', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS101' AND Year = 2026 AND SemesterID = 1));
GO

-- Attendance for CS102
INSERT INTO AttendanceRecord (StudentID, AttendanceDate, AttendanceStatus, CourseOfferID)
VALUES 
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-06', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-08', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-13', 'Late',    (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-15', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1)),
    ((SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'), '2026-01-20', 'Present', (SELECT CourseOfferID FROM CourseOffer WHERE CourseCode = 'CS102' AND Year = 2026 AND SemesterID = 1));
GO

-- Announcements
INSERT INTO Announcement (Title, Description, TargetType, TargetValue, CreatedDate, AttachmentPath)
VALUES 
    ('Welcome to New Semester', 'Jan 2026 semester starts on 1st Jan. Please check your timetable.', 'All', NULL, GETDATE(), NULL),
    ('CS101 Quiz 1 Reminder', 'Quiz 1 will be held on 15th Jan during lecture.', 'CourseCode', 'CS101', GETDATE(), NULL),
    ('CS201 Midterm Preparation', 'Midterm exam on 20th March. Review lectures 1-5.', 'CourseCode', 'CS201', GETDATE(), NULL),
    ('BSECS Programme Meeting', 'All BSECS students attend a meeting on 10th Jan at 2pm.', 'ProgrammeCode', 'BSECS', GETDATE(), NULL);
GO

-- AcademicCalendar (enhanced)
INSERT INTO AcademicCalendar (EventName, EventDescription, EventDate, SemesterID, HexColor, TargetRole)
VALUES 
    ('Semester Orientation', 'Welcoming incoming cohorts', '2026-04-06', 2, '#3B82F6', 'All'),
    ('Labour Day Holiday', 'National Statutory Holiday', '2026-05-01', 2, '#EAB308', 'All'),
    ('Mid-Semester Examination', 'Core assessment run', '2026-05-18', 2, '#EF4444', 'All');
GO

-- More enrolments for April 2026
INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate)
SELECT 
    (SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my'),
    CourseOfferID, 
    'Enrolled', 
    GETDATE()
FROM CourseOffer 
WHERE CourseCode IN ('CS201', 'CS202') 
AND SemesterID = 2 AND Year = 2026
AND NOT EXISTS (
    SELECT 1 FROM Enrolment 
    WHERE StudentID = (SELECT StudentID FROM Student WHERE StudentEmail = 'jonsen@unitrack.edu.my')
    AND CourseOfferID = CourseOffer.CourseOfferID
);
GO

-- Optional: AdminMessage sample
INSERT INTO AdminMessage (SenderEmail, Subject, MessageText)
VALUES ('student@example.com', 'Login Issue', 'I cannot log in to the system.');
GO

-- Optional: AdminAnnouncement sample
INSERT INTO AdminAnnouncement (Title, ContentText, TargetAdmin, TargetLecturer, TargetStudent, SenderAdminID)
VALUES ('System Maintenance', 'The system will be down on Sunday for upgrades.', 1, 1, 1, 1);
GO

PRINT 'Database rebuild complete. All tables and sample data ready.';
GO

-- ============================================
-- 6. FINAL VERIFICATION (list all tables)
-- ============================================
SELECT * FROM HeadofProgramme;
SELECT * FROM Lecturer;
SELECT * FROM Faculty;
SELECT * FROM Programme;
SELECT * FROM Semester;
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM CourseOffer;
SELECT * FROM CourseMaterial;
SELECT * FROM Enrolment;
SELECT * FROM Assessment;
SELECT * FROM StudentAssessment;
SELECT * FROM GradeScale;
SELECT * FROM AttendanceRecord;
SELECT * FROM Announcement;
SELECT * FROM EmailLog;
SELECT * FROM AcademicCalendar;
SELECT * FROM NotificationReadStatus;
SELECT * FROM DashboardPreferences;
SELECT * FROM StudentCourseStatus;
SELECT * FROM InvoiceReceipt;
SELECT * FROM AdminMessage;
SELECT * FROM AdminAnnouncement;
SELECT * FROM PaymentRecord;
GO
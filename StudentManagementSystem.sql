-- Create and use the database
CREATE DATABASE StudentManagementSystem;
USE StudentManagementSystem;

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
-- Table: Programme (must be created before Student and Course)
-- ============================================
CREATE TABLE Programme (
    ProgrammeCode   NVARCHAR(20) PRIMARY KEY,
    ProgrammeName   NVARCHAR(100) NOT NULL,
    Level           NVARCHAR(20) CHECK (Level IN ('Foundation', 'Certificate', 'Diploma', 'Degree')),
    TotalCreditHours INT NOT NULL,
    Description     NVARCHAR(500)
);

-- ============================================
-- Table: Semester (must be created before Student)
-- ============================================
CREATE TABLE Semester (
    SemesterID     INT IDENTITY(1,1) PRIMARY KEY,
    Semester       NVARCHAR(10) NOT NULL CHECK (Semester IN ('Jan', 'April', 'August')),
    StartMonthDay  CHAR(5) NOT NULL,  -- '01-01'
    EndMonthDay    CHAR(5) NOT NULL,
    CONSTRAINT CHK_StartMonthDay CHECK (StartMonthDay LIKE '[0-9][0-9]-[0-9][0-9]'),
    CONSTRAINT CHK_EndMonthDay   CHECK (EndMonthDay   LIKE '[0-9][0-9]-[0-9][0-9]')
);

-- ============================================
-- Table: Student (with foreign keys to Programme and Semester)
-- ============================================
CREATE TABLE Student (
    StudentID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentName    NVARCHAR(100) NOT NULL,
    StudentEmail   NVARCHAR(100) NOT NULL UNIQUE,
    Password       NVARCHAR(255) NOT NULL,
    PersonalEmail  NVARCHAR(100),
    ContactNo      NVARCHAR(20),
    SemesterID     INT NOT NULL,
    IntakeYear     INT NOT NULL,
    ProgrammeCode  NVARCHAR(20),
    UserRole       NVARCHAR(20) NOT NULL DEFAULT 'Student'
    CONSTRAINT CHK_StudentRole CHECK (UserRole = 'Student'),
    -- ADD THE MISSING FOREIGN KEYS HERE
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

CREATE TABLE CourseMaterial (
    MaterialID         INT IDENTITY(1,1) PRIMARY KEY,
    CourseOfferID      INT NOT NULL,
    MaterialTitle      NVARCHAR(200) NOT NULL,
    Description        NVARCHAR(500),
    FileURL            NVARCHAR(500) NOT NULL,
    ScheduleDate       DATETIME NOT NULL,
    UploadDate         DATETIME NOT NULL DEFAULT GETDATE(),
    UploadByLecturerID INT NULL,   -- NULL allowed if you ever have system uploads

    CONSTRAINT FK_CourseMaterial_CourseOffer 
        FOREIGN KEY (CourseOfferID) REFERENCES CourseOffer(CourseOfferID),
    CONSTRAINT FK_CourseMaterial_Lecturer 
        FOREIGN KEY (UploadByLecturerID) REFERENCES Lecturer(LecturerID)
);

-- ============================================
-- Table: Enrolment
-- ============================================
CREATE TABLE Enrolment (
    EnrolmentID   INT IDENTITY(1,1) PRIMARY KEY,
    StudentID     INT,
    CourseOfferID INT,
    EnrolStatus   NVARCHAR(20) NOT NULL DEFAULT 'Enrolled' CHECK (EnrolStatus IN ('Enrolled', 'Dropped')),
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

-- Insert grade boundaries
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

INSERT INTO Semester (Semester, StartMonthDay, EndMonthDay)
VALUES 
    ('Jan',    '01-01', '03-31'),
    ('April',  '04-01', '07-31'),
    ('August', '08-01', '12-31');

-- Now insert a sample Programme (fixed the missing quotes)
INSERT INTO Programme (ProgrammeCode, ProgrammeName, Level, TotalCreditHours)
VALUES ('BSECS', 'Bachelor of Software Engineering in Computer Science', 'Degree', 135);

-- Verify
SELECT * FROM GradeScale;
SELECT * FROM Semester;
SELECT * FROM Programme;

-- This works in SQL Server (original DATEFROMPARTS is fine)
SELECT 
    SemesterID,
    Semester,
    DATEFROMPARTS(2025, CAST(LEFT(StartMonthDay,2) AS INT), CAST(RIGHT(StartMonthDay,2) AS INT)) AS StartDate,
    DATEFROMPARTS(2025, CAST(LEFT(EndMonthDay,2) AS INT), CAST(RIGHT(EndMonthDay,2) AS INT)) AS EndDate
FROM Semester;

-- 1. Create the Database
CREATE DATABASE SE_Assignment;
GO

-- Tell SSMS to use the new database for the following commands
USE SE_Assignment;
GO

-- 2. Create Tables (Ordered by dependency)

CREATE TABLE Admin (
    AdminID INT PRIMARY KEY IDENTITY(1,1),
    AdminName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL
);

CREATE TABLE Semester (
    SemesterID INT PRIMARY KEY IDENTITY(1,1),
    SemesterName NVARCHAR(20) CHECK (SemesterName IN ('Jan', 'April', 'August')),
    Year INT NOT NULL,
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE Programme (
    ProgrammeCode NVARCHAR(20) PRIMARY KEY,
    ProgrammeName NVARCHAR(100) NOT NULL,
    Duration INT, 
    Level NVARCHAR(50) CHECK (Level IN ('Foundation', 'Certificate', 'Diploma', 'Degree', 'Master')),
    TotalCredits INT,
    TotalFee DECIMAL(10, 2)
);

CREATE TABLE Course (
    CourseCode NVARCHAR(20) PRIMARY KEY,
    CourseName NVARCHAR(100) NOT NULL,
    CreditHours INT,
    Description NVARCHAR(MAX),
    Fee DECIMAL(10, 2)
);

CREATE TABLE Lecturer (
    LecturerID INT PRIMARY KEY IDENTITY(1,1),
    LecturerName NVARCHAR(100) NOT NULL,
    LecturerEmail NVARCHAR(100) UNIQUE,
    Password NVARCHAR(255),
    ProfilePhoto VARBINARY(MAX), 
    Bio NVARCHAR(MAX),
    PersonalEmail NVARCHAR(100),
    ContactNo NVARCHAR(20),
    Department NVARCHAR(100),
    OfficeLocation NVARCHAR(100),
    ConsulationHours NVARCHAR(100),
    UserRole NVARCHAR(20) DEFAULT 'Lecturer'
);

CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    StudentName NVARCHAR(100) NOT NULL,
    StudentEmail NVARCHAR(100) UNIQUE,
    Password NVARCHAR(255),
    PersonalEmail NVARCHAR(100),
    Nationality NVARCHAR(50),
    Sex CHAR(1) CHECK (Sex IN ('M', 'F')),
    DateofBirth DATE,
    ContactNo NVARCHAR(20),
    ProgrammeCode NVARCHAR(20) FOREIGN KEY REFERENCES Programme(ProgrammeCode),
    IntakeSemester NVARCHAR(20) CHECK (IntakeSemester IN ('January', 'April', 'August')),
    IntakeYear INT,
    CurrentSemester INT,
    UserRole NVARCHAR(20) DEFAULT 'Student'
);

CREATE TABLE CourseOffering (
    OfferID INT PRIMARY KEY IDENTITY(1,1),
    CourseCode NVARCHAR(20) FOREIGN KEY REFERENCES Course(CourseCode),
    Semester NVARCHAR(20),
    Year INT,
    LecturerID INT FOREIGN KEY REFERENCES Lecturer(LecturerID),
    MaxStudents INT
);

CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID),
    OfferingID INT FOREIGN KEY REFERENCES CourseOffering(OfferID),
    EnrollStatus NVARCHAR(20) CHECK (EnrollStatus IN ('Enrolled', 'Dropped', 'Completed'))
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT FOREIGN KEY REFERENCES Enrollment(EnrollmentID),
    Amount DECIMAL(10, 2),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(20) CHECK (PaymentMethod IN ('Cash', 'Paypal')),
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Completed', 'Failed'))
);

CREATE TABLE AttendanceRecord (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID),
    OfferID INT FOREIGN KEY REFERENCES CourseOffering(OfferID),
    Date DATE,
    AttendanceStatus NVARCHAR(20) CHECK (AttendanceStatus IN ('Present', 'Absent', 'Late'))
);

CREATE TABLE Assessment (
    AssessmentID INT PRIMARY KEY IDENTITY(1,1),
    OfferID INT FOREIGN KEY REFERENCES CourseOffering(OfferID),
    AssessmentName NVARCHAR(50) CHECK (AssessmentName IN ('Quiz', 'Test', 'Assignment', 'Report', 'FinalExam')),
    MaxMarks DECIMAL(5, 2),
    Weightage INT 
);

CREATE TABLE StudentAssessment (
    StudentAssessmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID),
    AssessmentID INT FOREIGN KEY REFERENCES Assessment(AssessmentID),
    ObtainedMarks DECIMAL(5, 2)
);

CREATE TABLE GradeScale (
    GradeScaleID INT PRIMARY KEY IDENTITY(1,1),
    MinMarks DECIMAL(5, 2),
    MaxMarks DECIMAL(5, 2),
    GradeLetter NVARCHAR(2),
    GradePoint DECIMAL(3, 2)
);

CREATE TABLE Announcement (
    AnnouncementID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(200),
    Message NVARCHAR(MAX),
    TargetType NVARCHAR(50) CHECK (TargetType IN ('Course', 'Offering', 'Programme', 'All')),
    CourseCode NVARCHAR(20) FOREIGN KEY REFERENCES Course(CourseCode),
    OfferID INT FOREIGN KEY REFERENCES CourseOffering(OfferID),
    ProgrammeCode NVARCHAR(20) FOREIGN KEY REFERENCES Programme(ProgrammeCode),
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE AcademicCalendar (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    EventName NVARCHAR(200),
    EventType NVARCHAR(50) CHECK (EventType IN ('Announcement', 'GradePublished', 'AttendanceWarning')),
    OfferID INT FOREIGN KEY REFERENCES CourseOffering(OfferID),
    ProgrammeCode NVARCHAR(20) FOREIGN KEY REFERENCES Programme(ProgrammeCode),
    EventDate DATETIME,
    CreatedAT DATETIME DEFAULT GETDATE(),
    TargetRole NVARCHAR(20) CHECK (TargetRole IN ('Lecturer', 'Student', 'All'))
);
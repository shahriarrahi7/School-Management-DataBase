CREATE DATABASE SchoolManagementDB;
GO

USE SchoolManagementDB;
GO

CREATE TABLE UserTypes
(
UserTypeID INT IDENTITY(1,1) PRIMARY KEY,
TypeName VARCHAR(50) NOT NULL UNIQUE
);
GO

INSERT INTO UserTypes (TypeName)
VALUES ('Employee'),('Student'),('Guardian');
GO

SELECT * FROM UserTypes;

CREATE TABLE UserRoles
(RoleID INT IDENTITY(1,1) PRIMARY KEY,
RoleName VARCHAR(50) NOT NULL UNIQUE,
Description VARCHAR(200)
);
GO

INSERT INTO UserRoles(RoleName, Description)
VALUES
('Admin', 'System administrator'),
('Principal', 'School Principal'),
('Teacher', 'School Teacher'),
('HR', 'Human Resource Management'),
('Accounts', 'Manage student fees'),
('Finance', 'Manage salary and finance'),
('Student', 'Student Account'),
('Guardian', 'Parants or guardian account');
GO

SELECT * FROM UserRoles;

CREATE TABLE Departments
(
DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
DepartmentName VARCHAR(100) NOT NULL UNIQUE
);
GO

INSERT INTO Departments(DepartmentName)
VALUES
('Administration'),('Academic'),('HR'),('Accounts'), ('Finance');
GO

SELECT * FROM Departments

CREATE TABLE Users
( UserID INT IDENTITY(1,1) PRIMARY KEY,

UserTypeID INT NOT NULL,
RoleID INT NOT NULL,
DepartmentID INT NULL,

FullName VARCHAR(150) NOT NULL,
UserName VARCHAR(100) NOT NULL UNIQUE,
PasswordHash VARCHAR(255) NOT NULL,

Phone VARCHAR(30),
Email VARCHAR(150),

Designation VARCHAR(100),
EmployeeCode VARCHAR(30) UNIQUE,
JoinDate DATE,
BasicSalary DECIMAL (12,2),

ClassID INT NULL,
RollNo VARCHAR(20),
AdmissionDate DATE,
GuardianName VARCHAR(150),
GuardainPhone VARCHAR(30),

IsActive BIT NOT NULL DEFAULT 1,
CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

FOREIGN KEY (UserTypeID)
REFERENCES UserTypes(UserTypeID),

FOREIGN KEY (RoleID)
REFERENCES UserRoles(RoleID),

FOREIGN KEY (DepartmentID)
REFERENCES Departments(DepartmentID),

CHECK (BasicSalary IS NULL OR BasicSalary >= 0)
);
GO

CREATE TABLE Classes
(
ClassID INT IDENTITY(1,1) PRIMARY KEY,
ClassName VARCHAR(50) NOT NULL,
SectionName VARCHAR(20) NOT NULL DEFAULT 'A',
AcademicYear SMALLINT NOT NULL,

UNIQUE (ClassName, SectionName, AcademicYear)
);
GO

INSERT INTO Classes
(ClassName, SectionName, AcademicYear)
VALUES 
('Class 6','A', 2026),
('Class 6', 'B', 2026),
('Class 7', 'A', 2026),
('Class 8', 'B', 2026);
GO

ALTER TABLE Users
ADD CONSTRAINT FK_Users_Classes
FOREIGN KEY(ClassID)
REFERENCES Classes(ClassID);
GO

SELECT * FROM UserTypes;
SELECT * FROM UserRoles;
SELECT * FROM Departments;
SELECT * FROM Classes;

--Employee: Teacher
INSERT INTO Users
(
UserTypeID, RoleID, DepartmentID,
FullName, UserName, PasswordHash,
Phone, Designation, EmployeeCode,
JoinDate, BasicSalary
)
VALUES
(
1, 3, 2,
'Abdul Karim', 'Teacher01', 'Replace_With_Password_hash',
'01788111111', 'Senior Teacher', 'EMP001',
'2025-01-01', 25000
);

--Student
INSERT INTO Users
(
UserTypeID, RoleID,DepartmentID,
FullName, UserName, PasswordHash,
Phone, ClassID, RollNo, AdmissionDate,
GuardianName, GuardainPhone
)
VALUES
(
2, 7, NULL,
'Rahim Ahemd', 'Student01', 'REPLACE_WITH_PASSWORD_HASH',
'015882222222',1, '1', '2026-02-01',
'Karim Mia', '01966333333'
);
INSERT INTO Users
(
UserTypeID, RoleID,DepartmentID,
FullName, UserName, PasswordHash,
Phone, ClassID, RollNo, AdmissionDate,
GuardianName, GuardainPhone
)
VALUES
(
2, 7, NULL,
'Rahim Ahemd', 'Student01', 'REPLACE_WITH_PASSWORD_HASH',
'015882222222',1, '1', '2026-02-01',
'Karim Mia', '01966333333'
);
GO

SELECT * FROM Users;

CREATE TABLE Salaries
(
SalaryID INT IDENTITY(1,1) PRIMARY KEY,
UserID INT NOT NULL,
SalaryMonth TINYINT NOT NULL,
SalaryYear SMALLINT NOT NULL,

BasicAmount DECIMAL (12, 2) NOT NULL,
Allowances DECIMAL (12, 2) NOT NULL DEFAULTS 0,
Deductions DECIMAL(12,2) NOT NULL DEFAULT 0,

    PayableAmount AS
        (BasicAmount + Allowances - Deductions),

    DueDate DATE,

    UNIQUE (UserID, SalaryMonth, SalaryYear),

    CHECK (SalaryMonth BETWEEN 1 AND 12),
    CHECK (
        BasicAmount >= 0 AND Allowances >= 0
        AND Deductions >= 0
        AND BasicAmount + Allowances >= Deductions
    ),

    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO


CREATE TABLE SalaryPayments
(
    SalaryPaymentID INT IDENTITY(1,1) PRIMARY KEY,
    SalaryID INT NOT NULL,
    AmountPaid DECIMAL(12,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentMethod VARCHAR(30) DEFAULT 'Bank Transfer',
    ReferenceNo VARCHAR(60),

    CHECK (AmountPaid > 0),

    FOREIGN KEY (SalaryID)
        REFERENCES Salaries(SalaryID)
);
GO



CREATE TABLE FeeStructures
(
    FeeStructureID INT IDENTITY(1,1) PRIMARY KEY,
    ClassID INT NOT NULL,
    FeeType VARCHAR(80) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    EffectiveFrom DATE NOT NULL,
    EffectiveTo DATE NULL,

    CHECK (Amount >= 0),

    FOREIGN KEY (ClassID)
        REFERENCES Classes(ClassID)
);
GO

INSERT INTO FeeStructures
    (ClassID, FeeType, Amount, EffectiveFrom)
VALUES
    (1, 'Monthly Tuition Fee', 2000, '2026-01-01'),
    (2, 'Monthly Tuition Fee', 2000, '2026-01-01'),
    (3, 'Monthly Tuition Fee', 2500, '2026-01-01'),
    (4, 'Monthly Tuition Fee', 3000, '2026-01-01');
GO



CREATE TABLE StudentFees
(
    StudentFeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    FeeStructureID INT NOT NULL,
    FeeMonth TINYINT NOT NULL,
    FeeYear SMALLINT NOT NULL,
    AmountDue DECIMAL(12,2) NOT NULL,
    DueDate DATE,

    UNIQUE (UserID, FeeStructureID, FeeMonth, FeeYear),

    CHECK (FeeMonth BETWEEN 1 AND 12),
    CHECK (AmountDue >= 0),

    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (FeeStructureID)
        REFERENCES FeeStructures(FeeStructureID)
);
GO


CREATE TABLE FeePayments
(
    FeePaymentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentFeeID INT NOT NULL,
    AmountPaid DECIMAL(12,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL DEFAULT 'Cash',
    ReceiptNo VARCHAR(50) UNIQUE,

    CHECK (AmountPaid > 0),

    FOREIGN KEY (StudentFeeID)
        REFERENCES StudentFees(StudentFeeID)
);
GO

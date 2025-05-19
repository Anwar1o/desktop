-- جدول العملاء
CREATE TABLE CUSTOMER (
    Id VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL
);

-- جدول هواتف العملاء (سمة متعددة القيم)
CREATE TABLE CUSTOMER_PHONE (
    CustId VARCHAR(20),
    PhoneNumber VARCHAR(20),
    PRIMARY KEY (CustId, PhoneNumber),
    FOREIGN KEY (CustId) REFERENCES CUSTOMER(Id)
);

-- جدول السيارات
CREATE TABLE CAR (
    Number VARCHAR(20) PRIMARY KEY,
    Model VARCHAR(50) NOT NULL,
    Year INT,
    PlateNumber VARCHAR(20) UNIQUE NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Available', 'Rented', 'Maintenance'))
);

-- جدول الموظفين
CREATE TABLE EMPLOYEE (
    Id VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Position VARCHAR(50)
);

-- جدول الفروع
CREATE TABLE BRANCH (
    Id VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    MgrId VARCHAR(20) UNIQUE,
    FOREIGN KEY (MgrId) REFERENCES EMPLOYEE(Id)
);

-- جدول عمليات التأجير
CREATE TABLE RENTAL (
    Id VARCHAR(20) PRIMARY KEY,
    RentalDate DATE NOT NULL,
    ReturnDate DATE,
    CustId VARCHAR(20) NOT NULL,
    CarNumber VARCHAR(20) NOT NULL,
    BranchId VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustId) REFERENCES CUSTOMER(Id),
    FOREIGN KEY (CarNumber) REFERENCES CAR(Number),
    FOREIGN KEY (BranchId) REFERENCES BRANCH(Id)
);

-- جدول علاقة الموظفين بالفروع (M:N)
CREATE TABLE EMPLOYEE_BRANCH (
    EmpId VARCHAR(20),
    BranchId VARCHAR(20),
    PRIMARY KEY (EmpId, BranchId),
    FOREIGN KEY (EmpId) REFERENCES EMPLOYEE(Id),
    FOREIGN KEY (BranchId) REFERENCES BRANCH(Id)
);

-- جدول الإشراف (علاقة أحادية)
CREATE TABLE SUPERVISION (
    EmpId VARCHAR(20),
    SuperId VARCHAR(20),
    PRIMARY KEY (EmpId),
    FOREIGN KEY (EmpId) REFERENCES EMPLOYEE(Id),
    FOREIGN KEY (SuperId) REFERENCES EMPLOYEE(Id)
);
INSERT INTO CUSTOMER (Id, Name, Address) VALUES
('C001', 'Ahmed Mohamed', '123 Palm Street, Riyadh'),
('C002', 'Sarah Abdullah', '456 King Fahd Road, Jeddah'),
('C003', 'Khalid Ali', '789 University Street, Dammam'),
('C004', 'Lina Hassan', '321 Tahliya Street, Makkah'),
('C005', 'Omar Kamal', '654 Olaya Street, Khobar'),
('C006', 'Nora Saeed', '987 Market Street, Madinah'),
('C007', 'Yasser Nasser', '147 King Abdulaziz Street, Abha'),
('C008', 'Hadeel Rami', '258 Sixty Street, Tabuk'),
('C009', 'Fares Waleed', '369 Prince Mohammed Street, Hail'),
('C010', 'Reem Adel', '753 Prince Sultan Street, Taif');
INSERT INTO CAR (Number, Model, Year, PlateNumber, Status) VALUES
('CAR001', 'Toyota Camry', 2022, 'ABC 1234', 'Available'),
('CAR002', 'Hyundai Accent', 2021, 'DEF 5678', 'Available'),
('CAR003', 'Nissan Sunny', 2020, 'GHI 9012', 'Rented'),
('CAR004', 'Kia Cerato', 2023, 'JKL 3456', 'Available'),
('CAR005', 'Chevrolet Optra', 2021, 'MNO 7890', 'Maintenance'),
('CAR006', 'Toyota Land Cruiser', 2022, 'PQR 1234', 'Available'),
('CAR007', 'Honda Civic', 2020, 'STU 5678', 'Rented'),
('CAR008', 'Mazda 3', 2023, 'VWX 9012', 'Available'),
('CAR009', 'Mercedes E200', 2021, 'YZA 3456', 'Available'),
('CAR010', 'BMW X5', 2022, 'BCD 7890', 'Maintenance');
INSERT INTO EMPLOYEE (Id, Name, Position) VALUES
('E001', 'Mohamed Ahmed', 'Branch Manager'),
('E002', 'Ali Ibrahim', 'Receptionist'),
('E003', 'Nora Khalid', 'Accountant'),
('E004', 'Khalid Saad', 'Rental Agent'),
('E005', 'Lama Abdulrahman', 'Branch Manager'),
('E006', 'Sami Wael', 'Maintenance Technician'),
('E007', 'Hind Majid', 'Receptionist'),
('E008', 'Tariq Nasser', 'Rental Agent'),
('E009', 'Yasmine Rami', 'Accountant'),
('E010', 'Wessam Hani', 'Maintenance Technician');
-- Search for customers with names containing 'ahmed' or 'ali'
SELECT Id, Name, Address 
FROM CUSTOMER
WHERE LOWER(Name) LIKE '%ahmed%' OR LOWER(Name) LIKE '%ali%'
ORDER BY Name ASC;
-- Count cars by status with additional statistics
SELECT 
    Status,
    COUNT(*) AS TotalCars,
    AVG(Year) AS AverageYear,
    MIN(Year) AS OldestCarYear,
    MAX(Year) AS NewestCarYear
FROM CAR
GROUP BY Status
ORDER BY TotalCars DESC;
-- Show active rentals ordered by rental date (oldest first)
SELECT 
    r.Id AS RentalId,
    c.Name AS CustomerName,
    car.Model AS CarModel,
    r.RentalDate,
    DATEDIFF(day, r.RentalDate, GETDATE()) AS DaysRented
FROM RENTAL r
JOIN CUSTOMER c ON r.CustId = c.Id
JOIN CAR car ON r.CarNumber = car.Number
WHERE r.ReturnDate IS NULL
ORDER BY r.RentalDate ASC
;-- Show car models by rental frequency (most popular first)
SELECT 
    c.Model,
    c.Year,
    COUNT(r.Id) AS RentalCount,
    AVG(DATEDIFF(day, r.RentalDate, r.ReturnDate)) AS AvgRentalDays
FROM CAR c
LEFT JOIN RENTAL r ON c.Number = r.CarNumber
GROUP BY c.Model, c.Year
ORDER BY RentalCount DESC;
-- Calculate branch performance metrics
SELECT 
    b.Name AS BranchName,
    b.Location,
    COUNT(DISTINCT r.Id) AS TotalRentals,
    COUNT(DISTINCT CASE WHEN r.ReturnDate IS NULL THEN r.Id END) AS ActiveRentals,
    COUNT(DISTINCT eb.EmpId) AS EmployeeCount,
    SUM(CASE WHEN r.ReturnDate IS NOT NULL 
         THEN DATEDIFF(day, r.RentalDate, r.ReturnDate) * 100 
         ELSE 0 END) AS TotalRevenue
FROM BRANCH b
LEFT JOIN RENTAL r ON b.Id = r.BranchId
LEFT JOIN EMPLOYEE_BRANCH eb ON b.Id = eb.BranchId
GROUP BY b.Id, b.Name, b.Location
ORDER BY TotalRevenue DESC;
-- Search rentals by customer name or car model
SELECT 
    r.Id AS RentalId,
    c.Name AS CustomerName,
    car.Model AS CarModel,
    b.Name AS BranchName,
    r.RentalDate,
    r.ReturnDate
FROM RENTAL r
JOIN CUSTOMER c ON r.CustId = c.Id
JOIN CAR car ON r.CarNumber = car.Number
JOIN BRANCH b ON r.BranchId = b.Id
WHERE LOWER(c.Name) LIKE '%john%' OR LOWER(car.Model) LIKE '%camry%'
ORDER BY r.RentalDate DESC;
-- Show employee supervision relationships
SELECT 
    e1.Name AS Employee,
    e2.Name AS Supervisor,
    b.Name AS Branch
FROM SUPERVISION s
JOIN EMPLOYEE e1 ON s.EmpId = e1.Id
JOIN EMPLOYEE e2 ON s.SuperId = e2.Id
LEFT JOIN EMPLOYEE_BRANCH eb ON e1.Id = eb.EmpId
LEFT JOIN BRANCH b ON eb.BranchId = b.Id
ORDER BY e2.Name, e1.Name;
Go
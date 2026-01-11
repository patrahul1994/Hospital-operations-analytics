-- ============================================================================
-- PROJECT 1: HOSPITAL OPERATIONS & PATIENT FLOW ANALYSIS
-- Healthcare Analytics Portfolio Project)
-- ============================================================================

-- STEP 1: DATABASE SETUP & SAMPLE DATA CREATION


CREATE DATABASE hospital_analytics;
USE hospital_analytics;

-- Table 1: Patients Demographics
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    city VARCHAR(50),
    state VARCHAR(50),
    insurance_provider VARCHAR(50),
    registration_date DATE
);

-- Table 2: Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    floor_number INT,
    total_beds INT,
    head_doctor VARCHAR(100)
);

-- Table 3: Admissions
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    department_id INT,
    admission_date DATETIME,
    discharge_date DATETIME,
    admission_type VARCHAR(20), -- Emergency, Planned, Transfer
    primary_diagnosis VARCHAR(200),
    severity_level VARCHAR(20), -- Critical, Moderate, Mild
    attending_physician VARCHAR(100),
    total_charges DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Table 4: Readmissions (within 30 days)
CREATE TABLE readmissions (
    readmission_id INT PRIMARY KEY,
    original_admission_id INT,
    readmission_date DATETIME,
    readmission_reason VARCHAR(200),
    days_since_discharge INT,
    FOREIGN KEY (original_admission_id) REFERENCES admissions(admission_id)
);

-- Table 5: Lab Tests
CREATE TABLE lab_tests (
    test_id INT PRIMARY KEY,
    admission_id INT,
    test_name VARCHAR(100),
    test_date DATETIME,
    test_cost DECIMAL(8,2),
    result_status VARCHAR(20), -- Normal, Abnormal, Critical
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
);





-- Insert Departments
INSERT INTO departments VALUES
(1, 'Cardiology', 3, 40, 'Dr. Sharma'),
(2, 'Neurology', 4, 30, 'Dr. Patel'),
(3, 'Orthopedics', 2, 35, 'Dr. Kumar'),
(4, 'Pediatrics', 1, 45, 'Dr. Singh'),
(5, 'Emergency', 0, 50, 'Dr. Reddy'),
(6, 'Oncology', 5, 25, 'Dr. Gupta');

-- Insert Sample Patients
INSERT INTO patients VALUES
(1001, 'Rajesh', 'Sharma', '1975-03-15', 'Male', 'B+', 'Mumbai', 'Maharashtra', 'Star Health', '2023-01-10'),
(1002, 'Priya', 'Verma', '1988-07-22', 'Female', 'O+', 'Delhi', 'Delhi', 'HDFC ERGO', '2023-02-15'),
(1003, 'Amit', 'Singh', '1965-11-30', 'Male', 'A+', 'Bangalore', 'Karnataka', 'Max Bupa', '2023-03-20'),
(1004, 'Sneha', 'Patel', '1992-05-18', 'Female', 'AB-', 'Pune', 'Maharashtra', 'Care Health', '2023-04-05'),
(1005, 'Vikram', 'Reddy', '1980-09-25', 'Male', 'O-', 'Hyderabad', 'Telangana', 'Star Health', '2023-05-12');

-- Insert Sample Admissions
INSERT INTO admissions VALUES
(5001, 1001, 1, '2024-01-15 08:30:00', '2024-01-20 14:00:00', 'Emergency', 'Acute Myocardial Infarction', 'Critical', 'Dr. Sharma', 185000.00),
(5002, 1002, 2, '2024-02-10 10:15:00', '2024-02-18 11:30:00', 'Planned', 'Brain Tumor Surgery', 'Moderate', 'Dr. Patel', 320000.00),
(5003, 1003, 3, '2024-03-05 14:45:00', '2024-03-12 09:00:00', 'Planned', 'Hip Replacement', 'Moderate', 'Dr. Kumar', 215000.00),
(5004, 1004, 4, '2024-04-20 16:20:00', '2024-04-23 10:00:00', 'Emergency', 'Acute Appendicitis', 'Moderate', 'Dr. Singh', 45000.00),
(5005, 1005, 5, '2024-05-12 20:00:00', '2024-05-13 08:30:00', 'Emergency', 'Fracture - Multiple', 'Critical', 'Dr. Reddy', 78000.00);

-- Insert Readmissions
INSERT INTO readmissions VALUES
(6001, 5001, '2024-02-10 09:00:00', 'Chest Pain - Post MI Complication', 21),
(6002, 5004, '2024-05-15 18:30:00', 'Wound Infection', 22);

-- Insert Lab Tests
INSERT INTO lab_tests VALUES
(7001, 5001, 'Cardiac Enzyme Panel', '2024-01-15 09:00:00', 2500.00, 'Critical'),
(7002, 5001, 'ECG', '2024-01-15 09:30:00', 800.00, 'Abnormal'),
(7003, 5002, 'MRI Brain', '2024-02-10 11:00:00', 12000.00, 'Abnormal'),
(7004, 5003, 'X-Ray Hip', '2024-03-05 15:00:00', 1200.00, 'Abnormal'),
(7005, 5004, 'Complete Blood Count', '2024-04-20 17:00:00', 600.00, 'Normal');


SELECT * FROM departments
SELECT * FROM patients
SELECT * FROM admissions
SELECT * FROM readmissions
SELECT * FROM lab_tests


--- ANALYTICAL QUERIES 


-- Query 1: Calculate Average Length of Stay (ALOS) by Department
-- Business Value: Identifies departments with longer stays for resource planning

SELECT
    d.department_name,
    COUNT(a.admission_id) AS total_admissions,
    ROUND(AVG(DATEDIFF(DAY, a.admission_date, a.discharge_date) * 1.0), 1) AS avg_length_of_stay_days,
    ROUND(AVG(a.total_charges), 2) AS avg_charges
FROM admissions a
JOIN departments d ON a.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_length_of_stay_days DESC;






-- Query 2: 30-Day Readmission Rate Analysis
-- Business Value: Quality metric - hospitals are penalized for high readmission rates
SELECT 
    d.department_name,
    COUNT(DISTINCT a.admission_id) AS total_discharges,
    COUNT(DISTINCT r.readmission_id) AS total_readmissions,
    ROUND((COUNT(DISTINCT r.readmission_id) * 100.0 / 
           COUNT(DISTINCT a.admission_id)), 2) AS readmission_rate_percent
FROM admissions a
JOIN departments d ON a.department_id = d.department_id
LEFT JOIN readmissions r ON a.admission_id = r.original_admission_id
GROUP BY d.department_name
ORDER BY readmission_rate_percent DESC;



-- Query 3: Peak Admission Hours Analysis (Emergency vs Planned)
-- Business Value: Staff scheduling optimization

SELECT
    admission_type,
    DATEPART(HOUR, admission_date) AS admission_hour,
    COUNT(*) AS admission_count
FROM admissions
GROUP BY admission_type, DATEPART(HOUR, admission_date)
ORDER BY admission_type, admission_count DESC;


-- Query 4: High-Value Patients (Total Lifetime Revenue)
-- Business Value: VIP patient identification for personalized care
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.insurance_provider,
    COUNT(a.admission_id) AS total_visits,
    SUM(a.total_charges) AS total_revenue,
    MAX(a.admission_date) AS last_visit_date
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.insurance_provider
HAVING SUM(a.total_charges) > 100000
ORDER BY total_revenue DESC;


-- Query 5: Department Bed Utilization Rate
-- Business Value: Optimize bed allocation and identify expansion needs
WITH daily_occupancy AS (
    SELECT
        department_id,
        CAST(admission_date AS DATE) AS admission_day,
        COUNT(*) AS patients_admitted
    FROM admissions
    GROUP BY department_id, CAST(admission_date AS DATE)
)
SELECT
    d.department_name,
    d.total_beds,
    ROUND(AVG(do.patients_admitted * 1.0), 1) AS avg_daily_occupancy,
    ROUND(
        AVG(do.patients_admitted * 1.0) / d.total_beds * 100,
        1
    ) AS utilization_rate_percent
FROM departments d
LEFT JOIN daily_occupancy do
    ON d.department_id = do.department_id
GROUP BY d.department_name, d.total_beds
ORDER BY utilization_rate_percent DESC;


-- Query 6: Lab Test Cost Analysis by Diagnosis
-- Business Value: Identify high-cost diagnoses for cost containment
SELECT 
    a.primary_diagnosis,
    COUNT(DISTINCT a.admission_id) AS patient_count,
    COUNT(lt.test_id) AS total_tests_ordered,
    ROUND(AVG(lt.test_cost), 2) AS avg_test_cost,
    SUM(lt.test_cost) AS total_lab_cost
FROM admissions a
JOIN lab_tests lt ON a.admission_id = lt.admission_id
GROUP BY a.primary_diagnosis
ORDER BY total_lab_cost DESC;

-- Query 7: Patient Age Group Distribution & Severity Analysis
-- Business Value: Demographic insights for marketing and service planning
SELECT
    CASE
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) < 18 THEN '0-17 (Pediatric)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '70+ (Elderly)'
    END AS age_group,
    a.severity_level,
    COUNT(*) AS admission_count,
    ROUND(AVG(a.total_charges), 2) AS avg_charges
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) < 18 THEN '0-17 (Pediatric)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN DATEDIFF(YEAR, p.date_of_birth, GETDATE()) BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '70+ (Elderly)'
    END,
    a.severity_level
ORDER BY age_group, severity_level;


-- Query 8: Insurance Provider Performance Analysis
-- Business Value: Negotiate better rates with high-volume insurers
SELECT 
    p.insurance_provider,
    COUNT(DISTINCT p.patient_id) AS unique_patients,
    COUNT(a.admission_id) AS total_admissions,
    SUM(a.total_charges) AS total_billed,
    ROUND(AVG(a.total_charges), 2) AS avg_claim_amount
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.insurance_provider
ORDER BY total_billed DESC;

-- Query 9: Critical Cases - Emergency Response Time Analysis
-- Business Value: Quality metric for emergency department performance
SELECT
    CAST(a.admission_date AS DATE) AS admission_day,
    COUNT(*) AS critical_admissions,
    AVG(
        DATEDIFF(
            MINUTE,
            a.admission_date,
            lt.first_test_date
        ) * 1.0
    ) AS avg_time_to_first_test_minutes
FROM admissions a
CROSS APPLY (
    SELECT MIN(test_date) AS first_test_date
    FROM lab_tests
    WHERE lab_tests.admission_id = a.admission_id
) lt
WHERE a.severity_level = 'Critical'
  AND a.admission_type = 'Emergency'
GROUP BY CAST(a.admission_date AS DATE)
ORDER BY admission_day;

-- ============================================================================
-- ADVANCED QUERIES FOR PORTFOLIO SHOWCASE
-- ============================================================================


INSERT INTO admissions VALUES
(5006, 1001, 1, '2024-03-10 09:00:00', '2024-03-14 11:00:00',
 'Planned', 'Post MI Follow-up', 'Moderate', 'Dr. Sharma', 85000.00),
(5007, 1002, 2, '2024-04-05 10:00:00', '2024-04-09 12:00:00',
 'Planned', 'Post Surgery Review', 'Mild', 'Dr. Patel', 45000.00);

-- Query 11: Cohort Analysis - Patient Retention
WITH first_visit AS (
    SELECT
        patient_id,
        MIN(admission_date) AS first_admission_date
    FROM admissions
    GROUP BY patient_id
),
return_visits AS (
    SELECT
        a.patient_id,
        DATEDIFF(
            MONTH,
            fv.first_admission_date,
            a.admission_date
        ) AS months_since_first_visit
    FROM admissions a
    JOIN first_visit fv ON a.patient_id = fv.patient_id
    WHERE a.admission_date > fv.first_admission_date
)
SELECT
    months_since_first_visit,
    COUNT(DISTINCT patient_id) AS returning_patients
FROM return_visits
GROUP BY months_since_first_visit
ORDER BY months_since_first_visit;

-- Query 12: Physician Performance Dashboard
-- Business Value: Identify high-performing doctors for recognition/promotion
SELECT
    a.attending_physician,
    COUNT(a.admission_id) AS total_cases,
    ROUND(AVG(DATEDIFF(DAY, a.admission_date, a.discharge_date) * 1.0), 1) AS avg_los,
    COUNT(r.readmission_id) AS readmission_count,
    ROUND(
        COUNT(r.readmission_id) * 100.0 /
        NULLIF(COUNT(a.admission_id), 0),
        2
    ) AS readmission_rate_percent,
    SUM(a.total_charges) AS total_revenue_generated
FROM admissions a
LEFT JOIN readmissions r
    ON a.admission_id = r.original_admission_id
GROUP BY a.attending_physician
HAVING COUNT(a.admission_id) >= 2
ORDER BY readmission_rate_percent ASC, total_revenue_generated DESC;


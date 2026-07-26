
-- Create Schema
CREATE SCHEMA heal;

-- ==========================
-- Department Table
-- ==========================
CREATE TABLE heal.departments
(
    department_id integer NOT NULL,
    department_name varchar(100),
    location varchar(100),

    CONSTRAINT departments_pk PRIMARY KEY (department_id)
);

-- ==========================
-- Patients Table
-- ==========================
CREATE TABLE heal.patients
(
    patient_id integer NOT NULL,
    first_name varchar(50),
    last_name varchar(50),
    date_of_birth date,
    gender varchar(10,
    phone varchar(20),

    CONSTRAINT patients_pk PRIMARY KEY (patient_id)
);

-- ==========================
-- Doctors Table
-- ==========================
CREATE TABLE heal.doctors
(
    doctor_id integer NOT NULL,
    first_name varchar(50),
    last_name varchar(50),
    specialty varchar(100),
    department_id integer,
    hire_date date,

    CONSTRAINT doctors_pk PRIMARY KEY (doctor_id),

    CONSTRAINT fk_doctors_department
        FOREIGN KEY (department_id)
        REFERENCES hospital.departments(department_id)
);

-- ==========================
-- Appointments Table
-- ==========================
CREATE TABLE heal.appointments
(
    appointment_id integer NOT NULL,
    patient_id integer,
    doctor_id integer,
    appointment_date date,
    status varchar(20),

    CONSTRAINT appointments_pk PRIMARY KEY (appointment_id),

    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id)
        REFERENCES hospital.patients(patient_id),

    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES hospital.doctors(doctor_id)
);

-- ==========================
-- Diagnoses Table
-- ==========================
CREATE TABLE heal.diagnoses
(
    diagnosis_id integer NOT NULL,
    patient_id integer,
    doctor_id integer,
    condition_name varchar(200),
    diagnosis_date date,

    CONSTRAINT diagnoses_pk PRIMARY KEY (diagnosis_id),

    CONSTRAINT fk_diagnoses_patient
        FOREIGN KEY (patient_id)
        REFERENCES hospital.patients(patient_id),

    CONSTRAINT fk_diagnoses_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES hospital.doctors(doctor_id)
);

--- Insert data

-- Departments
COPY hospital.departments
FROM 'C:\Users\Admin\Documents\departmets.csv'
DELIMITER E'\t'
CSV HEADER;

-- Patients
COPY hospital.patients
FROM 'C:\Users\Admin\Documents\patients.csv'
DELIMITER E'\t'
CSV HEADER;

-- Doctors
COPY hospital.doctors
FROM 'C:\Users\Admin\Documents\doctors.csv'
DELIMITER E'\t'
CSV HEADER;

-- Appointments
COPY hospital.appointments
FROM 'C:\Users\Admin\Documents\appointments.csv'
DELIMITER E'\t'
CSV HEADER;

-- Diagnoses
COPY hospital.diagnoses
FROM 'C:\Users\Admin\Documents\diagnoses.csv'
DELIMITER E'\t'
CSV HEADER;

--- Question:
--== Question 1: Return the complete patient roster from the patients table
SELECT * FROM heal.patients;

--== Question 2: Return all department names and their locations.
SELECT department_name, location FROM heal.departments;

--== Question 3: Return doctors assigned to the Cardiology department.
SELECT first_name, last_name, specialty FROM heal.doctors
WHERE specialty LIKE '%Cardiologist%';

--== Question 4: Return all female patients with their contact information.
SELECT first_name, last_name, phone FROM heal.patients
WHERE gender = 'F';

--== Question 5: Return all doctors sorted by hire date from oldest to most recent.
SELECT first_name, last_name, hire_date FROM heal.doctors
ORDER BY hire_date ASC;

--== Question 6: Return all appointments with a Completed status.
SELECT appointment_id, patient_id, appointments.appointment_date FROM heal.appointments
WHERE status LIKE 'Completed';

--== Question 7: Count the total number of doctors on staff.
SELECT COUNT(doctor_id) AS total_doctors FROM heal.doctors;

--== Question 8: Return all diagnoses recorded in the year 2025.
SELECT
  di.condition_name,
  di.diagnosis_date,
  p.last_name
FROM
  heal.diagnoses di
  JOIN heal.patients p ON di.patient_id = p.patient_id
WHERE
  di.diagnosis_date >= '2025-01-01'
  AND di.diagnosis_date < '2026-01-01'
ORDER BY
  di.diagnosis_date;

--== Question 9: Count appointments per year using strftime to extract the year from appointment_date. Show year and appointment_count. Order by year.
SELECT
  TO_CHAR (appointment_date, 'YYYY') AS YEAR,
  COUNT(*) AS appointment_count
FROM
  heal.appointments
GROUP BY
  YEAR
ORDER BY
  YEAR;

--== Question 10: Show the number of distinct diagnoses per patient. Join patients to diagnoses. Show first name, last name, and diagnosis_count. Order by count descending.
SELECT p.first_name, p.last_name,
COUNT(di.diagnosis_id) AS diagnosis_count
FROM heal.patients p
JOIN heal.diagnoses di ON p.patient_id = di.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY diagnosis_count DESC;

--== Question 11: Find distinct patients who have at least one appointment in 2025. Use strftime to extract the year. Show first name and last name ordered by last name.
SELECT DISTINCT
  p.first_name,
  p.last_name
FROM
  heal.patients p
  JOIN heal.appointments a ON p.patient_id = a.patient_id
WHERE
  TO_CHAR (a.appointment_date, 'YYYY') = '2025'
ORDER BY
  p.last_name;

--== Question 12: The analytics team wants to know what gender values exist in the patient database. List the distinct gender values from the patients table.
SELECT DISTINCT(gender) FROM heal.patients;

--== Question 13: The scheduling team needs to review all appointments booked during a two-week window. Find all appointments with appointment_date between January 15, 2025 and January 20, 2025 (inclusive). Show appointment_id, patient_id, appointment_date, and status.
SELECT appointment_id, patient_id, appointment_date, status
FROM heal.appointments
WHERE appointment_date BETWEEN '2025-01-15' AND '2025-01-20';

--== Question 14: Count the number of appointments per patient.
SELECT patient_id, COUNT(*) as appointment_count
FROM heal.appointments
GROUP BY patient_id
ORDER BY patient_id;

--== Question 15: The hospital directory needs each physician listed alongside their department name for the public-facing staff page.
--Return each doctor's name paired with their department name.
SELECT d.first_name, d.last_name, de.department_name
FROM heal.doctors d 
JOIN heal.departments de ON d.department_id = de.department_id;

--== Question 16: The clinical records team needs a patient-linked view of all diagnoses for a care history audit.
--Return each diagnosis with the patient's first name, last name, condition name, and diagnosis date.
SELECT p.first_name, p.last_name, di.condition_name, di.diagnosis_date
FROM heal.patients p
JOIN heal.diagnoses di ON p.patient_id = di.patient_id
ORDER BY di.diagnosis_date;

--== Question 17: The scheduling team needs a forward-looking appointment list with both patient and doctor names for daily briefing sheets.
--Return all scheduled appointments with patient and doctor full names.
SELECT a.appointment_date, 
p.first_name ||' '|| p.last_name AS patient_name, 
d.first_name ||' '|| d.last_name AS doctor_name
FROM heal.appointments a JOIN heal.patients p ON a.patient_id = p.patient_id
JOIN heal.doctors d ON a.doctor_id = d.doctor_id 
WHERE a.status = 'Scheduled' ORDER BY a.appointment_date;

--== Question 18: The capacity planning team needs to know physician headcount per department to identify under-staffed units.
--Return the number of doctors in each department.
SELECT de.department_name, COUNT(d.doctor_id) AS doctor_count FROM heal.departments de
LEFT JOIN heal.doctors d ON de.department_id = d.department_id
GROUP BY de.department_name
ORDER BY department_name;

--== Question 19: The chronic care team is identifying patients who carry multiple diagnoses to prioritise case management outreach.
--Return patients who have more than one recorded diagnosis.
SELECT patient_id, COUNT(diagnosis_id) AS diagnosis_count
FROM heal.diagnoses 
GROUP BY patient_id
HAVING COUNT(diagnosis_id) > 1;

--== Question 20: The patient flow team needs each appointment linked to the department responsible so throughput can be measured by clinical unit.
--Return each appointment's date, patient last name, and the department of the attending doctor.
SELECT a.appointment_date, p.last_name as patient_last_name, de.department_name
FROM heal.appointments a 
JOIN heal.patients p ON a.patient_id = p.patient_id
JOIN heal.doctors d ON a.doctor_id = d.doctor_id
JOIN heal.departments de ON d.department_id = de.department_id
ORDER BY a.appointment_date, p.last_name;

--== Question 21: The hospital audit team needs a complete view of every appointment. Show full appointment details including patient name, doctor name, department name, appointment date, and status. Order by appointment date.
SELECT p.first_name, p.last_name, d.first_name AS dr_first, d.last_name AS dr_last,
de.department_name, a.appointment_date, a.status
FROM heal.appointments a
JOIN heal.patients p ON a.patient_id = p.patient_id
JOIN heal.doctors d ON a.doctor_id = d.doctor_id
JOIN heal.departments de ON d.department_id = de.department_id
ORDER BY a.appointment_date;

--== Question 22: The admissions team wants to know which registered patients have never had an appointment scheduled. Find patients who have no appointment records. Show first name, last name, and gender.
SELECT p.first_name, p.last_name, p.gender
FROM heal.patients p LEFT 
JOIN heal.appointments a ON p.patient_id = a.patient_id 
WHERE a.appointment_id IS NULL;

--== Question 23: Create a unified appointment list by combining Scheduled (labelled 'Upcoming') and Completed (labelled 'Past') appointments. Show patient_id, doctor_id, appointment_date, and category. Order by appointment_date.
SELECT patient_id, doctor_id, appointment_date, 
'Upcoming' AS category FROM heal.appointments WHERE status = 'Scheduled' 
UNION ALL SELECT patient_id, doctor_id, appointment_date,
'Past' AS category FROM heal.appointments WHERE status = 'Completed'
ORDER BY appointment_date;

--== Question 24: The clinical team wants to identify patients who have never received a diagnosis. Find all patients who have no records in the diagnoses table. Show first name, last name, and gender.
SELECT p.first_name, p.last_name, p.gender
FROM heal.patients p 
LEFT JOIN heal.diagnoses di ON p.patient_id = di.patient_id 
WHERE di.diagnosis_id IS NULL;

--== Question 25: Generate a patient summary report showing every registered patient alongside how many diagnoses they have received, including patients with zero diagnoses. Show first name, last name, and diagnosis_count. Order by diagnosis_count descending, then last name.
SELECT p.first_name, p.last_name, COUNT(di.diagnosis_id)
AS diagnosis_count
FROM heal.patients p 
LEFT JOIN heal.diagnoses di ON p.patient_id = di.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY diagnosis_count DESC, p.last_name;

--== Question 26: Find doctors who have more appointments than the average number of appointments for all doctors in their department. Show first name, last name, specialty, and appointment count.
SELECT d.first_name, d.last_name, d.specialty, COUNT(a.appointment_id)
AS appt_count
FROM heal.doctors d
JOIN heal.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialty, d.department_id
HAVING COUNT(a.appointment_id) > (SELECT AVG(cnt) FROM(SELECT COUNT(a2.appointment_id) 
AS cnt FROM heal.doctors d2 JOIN heal.appointments a2 ON d2.doctor_id = a2.doctor_id
WHERE d2.department_id = d.department_id GROUP BY d2.doctor_id))
ORDER BY appt_count DESC;

--== Question 27:  Rank each doctor by their appointment count within their department. Show first name, last name, department_id, appt_count, and dept_rank. Order by department, then rank.
SELECT d.first_name, d.last_name, d.department_id, COUNT(a.appointment_id)
AS appt_count, RANK() OVER(PARTITION BY d.department_id 
ORDER BY COUNT(a.appointment_id)DESC) AS dept_rank
FROM heal.doctors d LEFT JOIN heal.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.department_id
ORDER BY d.department_id, dept_rank;

--== Question 28: Find the doctor with the most appointments in each department. Show doctor name, department name, and appointment count.
WITH doctor_counts AS (
SELECT d.doctor_id, d.first_name, d.last_name, d.department_id,
COUNT(a.appointment_id) AS appt_count
FROM heal.doctors d LEFT JOIN heal.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.department_id
  ),
  ranked AS (SELECT *, RANK() OVER (PARTITION BY department_id
ORDER BY appt_count DESC) AS rnk
FROM doctor_counts)
SELECT r.first_name, r.last_name, de.department_name, r.appt_count
FROM ranked r
JOIN heal.departments de ON r.department_id = de.department_id
WHERE r.rnk = 1
ORDER BY de.department_name;

--==Question 29: Classify patients into age groups based on their age as of 2026-01-01: Young Adult (under 35), Middle-Aged (35–49), Senior (50+). Show each group's patient count and average age. Order by avg_age ascending.
WITH patient_ages AS (
     SELECT patient_id, last_name,
(EXTRACT(YEAR FROM DATE '2026-01-01')-EXTRACT(YEAR FROM date_of_birth)) AS age FROM heal.patients)
SELECT CASE WHEN age < 35 THEN 'Young Adult' WHEN age < 50 THEN 'Middle-Aged' ELSE 'Senior'
END AS age_group, COUNT(*) AS patient_count, ROUND(AVG(age),1)
AS avg_age FROM patient_ages GROUP BY age_group ORDER BY avg_age;

--==Question 30: The operations team wants to flag doctors who are busier than the hospital average. Find doctors whose appointment count exceeds the hospital-wide average appointment count per doctor. Show first name, last name, specialty, and appointment count.
SELECT d.first_name, d.last_name, d.specialty, 
COUNT(a.appointment_id) AS appt_count 
FROM heal.doctors d JOIN heal.appointments a 
ON d.doctor_id = a.doctor_id 
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialty 
HAVING COUNT(a.appointment_id) > (SELECT AVG(cnt) 
FROM (SELECT COUNT(appointment_id) AS cnt 
FROM heal.appointments GROUP BY doctor_id)) 
ORDER BY appt_count DESC;

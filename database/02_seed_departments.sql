-- ====================================================================
-- CampusFlow: Seed Core Departments
-- ====================================================================
SET DEFINE OFF;

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Information Technology (IT)', 'Network connectivity, lab computers, Wi-Fi, portals, smart boards', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Electrical and Power Systems', 'Lighting, power backup, UPS, fans, AC units, switchboards', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Plumbing and Water Works', 'Water purifiers, restrooms, pipe leaks, drainage, taps', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Classroom and Lab Facilities', 'Desks, chairs, projectors, podiums, whiteboard repairs', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Hostel and Residential Maintenance', 'Hostel rooms, mess amenities, corridor fixtures, laundry rooms', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Campus Transport Services', 'College buses, parking permits, EV charging points, shuttles', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'Academic and Administrative Support', 'Exam hall seating, transcript requests, library equipment', 'ACTIVE');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS)
VALUES (SEQ_DEPARTMENTS.NEXTVAL, 'General Housekeeping and Cleaning', 'Sanitation, trash disposal, campus grounds, landscaping', 'ACTIVE');

COMMIT;

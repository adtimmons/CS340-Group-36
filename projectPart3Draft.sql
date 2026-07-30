/*  Group 36 Project Step 2 Draft by Jason Bluedorn and Alysha Timmons */

/* disable foreign key checks and commits to reduce import errors */
SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

/* Generate the Lines entity with line id, line name, and department */
CREATE OR REPLACE TABLE AssemblyLines (
    lineID int NOT NULL AUTO_INCREMENT,
    lineName varchar(255) NOT NULL,
    department varchar(255) NOT NULL,
    PRIMARY KEY (lineID)
);

/* Generate the TeamMembers entity with member ID, first name, last name, home line, and employment status */
CREATE OR REPLACE TABLE TeamMembers (
    teamMemberID int NOT NULL AUTO_INCREMENT,
    firstName varchar(255) NOT NULL,
    lastName varchar(255) NOT NULL,
    homeLineID int NOT NULL,
    employmentStatus varchar(255) NOT NULL, 
    PRIMARY KEY (teamMemberID),
    FOREIGN KEY (homeLineID) REFERENCES AssemblyLines(lineID) ON DELETE RESTRICT
);

/* Generate the Skills table with a skill ID, skill name, and skill description */
CREATE OR REPLACE TABLE Skills (
    skillID int NOT NULL AUTO_INCREMENT,
    skillName varchar(255) NOT NULL,
    skillDescription varchar(255),
    PRIMARY KEY (skillID)
);

/* Generate the Schedules table with a scheduleID, scheduleDate, and a shiftName */
CREATE OR REPLACE TABLE Schedules (
    scheduleID int NOT NULL AUTO_INCREMENT,
    scheduleDate date NOT NULL,
    shiftName varchar(255) NOT NULL,
    PRIMARY KEY (scheduleID)
);

/* Generate the Positions table with a positionID, position Name, lineID, required staff, and qualifying skill */
CREATE OR REPLACE TABLE Positions (
    positionID int NOT NULL AUTO_INCREMENT,
    positionName varchar(255) NOT NULL, 
    lineID int NOT NULL,
    requiredStaff int NOT NULL,
    qualifyingSkillID int NOT NULL,
    PRIMARY KEY (positionID),
    FOREIGN KEY (lineID) REFERENCES AssemblyLines(lineID) ON DELETE CASCADE,
    FOREIGN KEY (qualifyingSkillID) REFERENCES Skills(skillID) ON DELETE RESTRICT
);

/* generate the DailyAssignments table that includes the assignment ID, scheduleID, Team Member id, and the schedule id with unique constraint on team member and schedule */
CREATE OR REPLACE TABLE DailyAssignments (
    assignmentID int NOT NULL AUTO_INCREMENT,
    scheduleID int NOT NULL, 
    teamMemberID int NOT NULL,
    positionID int NOT NULL,
    PRIMARY KEY (assignmentID),
    FOREIGN KEY (scheduleID) REFERENCES Schedules(scheduleID) ON DELETE CASCADE,
    FOREIGN KEY (teamMemberID) REFERENCES TeamMembers(teamMemberID) ON DELETE CASCADE,
    FOREIGN KEY (positionID) REFERENCES Positions(positionID) ON DELETE CASCADE,
    CONSTRAINT assignedTeamMember UNIQUE (teamMemberID, scheduleID)
);

/* generates an intersection table between skills and team members */
CREATE OR REPLACE TABLE TeamMemberSkills (
    teamMemberID int NOT NULL,
    skillID int NOT NULL,
    PRIMARY KEY (teamMemberID, skillID),
    FOREIGN KEY (teamMemberID) REFERENCES TeamMembers(teamMemberID) ON DELETE CASCADE,
    FOREIGN KEY (skillID) REFERENCES Skills(skillID) ON DELETE CASCADE
);

/* inserting test data */

INSERT INTO AssemblyLines
   (lineID, lineName, department)
VALUES
   (1, 'Line 1', 'Production'),
   (2, 'Line 2', 'Production'),
   (3, 'Line 3', 'Production'),
   (4, 'Line 4', 'Production'),
   (5, 'Warehouse Area', 'Warehouse'),
   (6, 'Support Area', 'Support');
 
 
INSERT INTO TeamMembers
   (teamMemberID, firstName, lastName, homeLineID, employmentStatus)
VALUES
   (1, 'John', 'Smith', 1, 'Full-Time'),
   (2, 'Sarah', 'Johnson', 1, 'Full-Time'),
   (3, 'Michael', 'Davis', 2, 'Full-Time'),
   (4, 'Emily', 'Brown', 3, 'Full-Time'),
   (5, 'David', 'Wilson', 4, 'Full-Time');
 
 
INSERT INTO Skills
   (skillID, skillName, skillDescription)
VALUES
   (1, 'Packer', 'Certified to package finished products'),
   (2, 'Machine Operator', 'Operates production machinery'),
   (3, 'Forklift', 'Certified forklift operator'),
   (4, 'Quality Check', 'Performs QA inspections'),
   (5, 'Sanitation', 'Performs cleaning and sanitation procedures');
 
 
INSERT INTO Positions
   (positionID, positionName, lineID, requiredStaff, qualifyingSkillID)
VALUES
   (1, 'Packer', 3, 4, 1),
   (2, 'Machine Operator', 2, 2, 2),
   (3, 'Forklift Driver', 5, 1, 3),
   (4, 'QA Inspector', 1, 2, 4),
   (5, 'Sanitation Technician', 6, 2, 5),
   (6, 'Packaging Inspector', 3, 1, 4);
 
 
INSERT INTO TeamMemberSkills
   (teamMemberID, skillID)
VALUES
   (1, 1),
   (1, 2),
   (2, 1),
   (3, 2),
   (4, 4),
   (5, 5),
   (5, 3);
 
 
INSERT INTO Schedules
   (scheduleID, scheduleDate, shiftName)
VALUES
   (1, '2026-07-22', 'Day'),
   (2, '2026-07-22', 'Night'),
   (3, '2026-07-23', 'Day');
 
 
INSERT INTO DailyAssignments
   (assignmentID, scheduleID, teamMemberID, positionID)
VALUES
   (1, 1, 1, 2),
   (2, 1, 2, 1),
   (3, 1, 4, 4),
   (4, 2, 3, 2),
   (5, 3, 1, 1),
   (6, 2, 5, 5),
   (7, 3, 5, 3);

/* set foreign key checks and commit */
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
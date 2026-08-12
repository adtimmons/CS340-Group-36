-- PL SQL for Group 36
-- Alysha Timmons and Jason Bluedorn
-- CITATION: All procedures based off of example code given in OSU CS_340 Explorations

-- -----------------------------------------------------------------------------------------------
-- Reset Procedure
-- -----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_db_reset;

DELIMITER / /

CREATE PROCEDURE sp_db_reset()

BEGIN
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
END //

DELIMITER;

-- ----------------------------------------------------------------------------------------------
-- LINES CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE Lines Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_assembly_line;

DELIMITER / /

CREATE PROCEDURE sp_create_assembly_line(
    IN input_line_name VARCHAR(255),
    IN input_department VARCHAR(255),
    OUT line_id INT
)
BEGIN

    INSERT INTO AssemblyLines (lineName, department)
    VALUES (input_line_name, input_department);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO line_id;
    SELECT LAST_INSERT_ID() AS 'line_id';

END //

DELIMITER;

-- ------------------------------------------------
-- UPDATE Lines Row
-- ------------------------------------------------

DROP PROCEDURE IF EXISTS sp_update_assembly_line;

DELIMITER / /

CREATE PROCEDURE sp_update_assembly_line(
    IN input_line_id INT,
    IN input_line_name VARCHAR(255),
    IN input_department VARCHAR(255)
)
BEGIN

    UPDATE AssemblyLines
    SET lineName = input_line_name, department = input_department
    WHERE lineID = input_line_id;

END //

DELIMITER;

-- -----------------------------------------
-- DELETE Lines Row
-- -----------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_assembly_line;

DELIMITER / /

CREATE PROCEDURE sp_delete_assembly_line(IN input_line_id INT)
BEGIN

    DELETE FROM AssemblyLines
    WHERE lineID = input_line_id;

END //

DELIMITER;

-- ----------------------------------------------------------------------------------------------
-- TEAM MEMBERS CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE TeamMembers Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_team_member;

DELIMITER / /

CREATE PROCEDURE sp_create_team_member(
    IN input_first_name VARCHAR(255),
    IN input_last_name VARCHAR(255),
    IN input_line_id INT,
    IN input_employment_status VARCHAR(255),
    OUT team_member_id INT
)
BEGIN

    INSERT INTO TeamMembers (firstName, lastName, homeLineID, employmentStatus)
    VALUES (input_first_name, input_last_name, input_line_id, input_employment_status);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO team_member_id;
    SELECT LAST_INSERT_ID() AS 'team_member_id';

END //

DELIMITER;

-- -----------------------------------------
-- UPDATE TeamMember Row
-- -----------------------------------------

DROP PROCEDURE IF EXISTS sp_update_team_member;

DELIMITER / /

CREATE PROCEDURE sp_update_team_member(
    IN input_tm_id INT,
    IN input_first_name VARCHAR(255),
    IN input_last_name VARCHAR(255),
    IN input_line_id INT,
    IN input_employment_status VARCHAR(255)
)
BEGIN

    UPDATE TeamMembers
    SET firstName = input_first_name, lastName = input_last_name,
        homeLineID = input_line_id, employmentStatus = input_employment_status
    WHERE teamMemberID = input_tm_id;

END //

DELIMITER;

-- ---------------------------------------
-- DELETE TeamMembers Row
-- ----------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_team_member;

DELIMITER / /

CREATE PROCEDURE sp_delete_team_member(IN input_tm_id INT)
BEGIN

    DELETE FROM TeamMembers
    WHERE teamMemberID = input_tm_id;

END //

DELIMITER;

-- ----------------------------------------------------------------------------------------------
-- POSITIONS CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE Positions Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_position;

DELIMITER //

CREATE PROCEDURE sp_create_position(
    IN input_position_name VARCHAR(255),
    IN input_line_id INT,
    IN input_req_staff INT,
    IN input_skill_id INT,
    OUT position_id INT
)
BEGIN

    INSERT INTO Positions (positionName, lineID, requiredStaff, qualifyingSkillID)
    VALUES (input_position_name, input_line_id, input_req_staff, input_skill_id);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO position_id;
    SELECT LAST_INSERT_ID() AS 'position_id';


END //

DELIMITER ;

-- ----------------------------------------
-- UPDATE Position Row
-- ----------------------------------------

DROP PROCEDURE IF EXISTS sp_update_position;

DELIMITER //

CREATE PROCEDURE sp_update_position(
    IN input_position_id INT,
    IN input_position_name VARCHAR(255),
    IN input_line_id INT,
    IN input_req_staff INT,
    IN input_skill_id INT
)
BEGIN

    UPDATE Positions
    SET positionName = input_position_name, lineID = input_line_id,
        requiredStaff = input_req_staff, qualifyingSkillID = input_skill_id
    WHERE positionID = input_position_id;

END //

DELIMITER ;

-- ----------------------------------------
-- DELETE Position Row
-- ----------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_position;

DELIMITER //

CREATE PROCEDURE sp_delete_position(IN input_position_id INT)
BEGIN

    DELETE FROM Positions
    WHERE positionID = input_position_id;

END //

DELIMITER ;

-- ----------------------------------------------------------------------------------------------
-- SKILLS CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE Skill Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_skill;

DELIMITER //

CREATE PROCEDURE sp_create_skill(
    IN input_skill_name VARCHAR(255),
    IN input_skill_description VARCHAR(255),
    OUT skill_id INT
)
BEGIN

    INSERT INTO Skills (skillName, skillDescription)
    Values (input_skill_name, input_skill_description);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO skill_id;
    SELECT LAST_INSERT_ID() AS 'skill_id';


END //

DELIMITER ;

-- ----------------------------------------
-- UPDATE Skill Row
-- ----------------------------------------

DROP PROCEDURE IF EXISTS sp_update_skill;

DELIMITER //

CREATE PROCEDURE sp_update_skill(
    IN input_skill_id INT,
    IN input_skill_name VARCHAR(255),
    IN input_skill_description VARCHAR(255)
)
BEGIN

    UPDATE Skills
    SET skillName = input_skill_name, skillDescription = input_skill_description
    WHERE skillID = input_skill_id;

END //

DELIMITER ;

-- ---------------------------------------
-- DELETE Skill Row
-- ---------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_skill;

DELIMITER //

CREATE PROCEDURE sp_delete_skill(IN input_skill_id INT)
BEGIN

    DELETE FROM Skills
    WHERE skillID = input_skill_id;

END //

DELIMITER ;

-- ----------------------------------------------------------------------------------------------
-- TEAM MEMBER SKILLS CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE TeamMemberSkill Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_tm_skill;

DELIMITER //

CREATE PROCEDURE sp_create_tm_skill(
    IN input_tm_id INT,
    IN input_skill_id INT
)
BEGIN

    INSERT INTO TeamMemberSkills (teamMemberID, skillID)
    VALUES (input_tm_id, input_skill_id);

    -- cannot return PK because it is composite primary key

END //

DELIMITER ;

-- ----------------------------------------
-- DELETE TeamMemberSkill Row
-- ----------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_tm_skill;

DELIMITER //

CREATE PROCEDURE sp_delete_tm_skill(IN input_tm_id INT, IN input_skill_id INT)
BEGIN

    -- delete needs to include both tm id and skill id in order to only delete intended row
    DELETE FROM TeamMemberSkills
    WHERE teamMemberID = input_tm_id AND skillID = input_skill_id;

END //

DELIMITER ;

-- ----------------------------------------------------------------------------------------------
-- SCHEDULES CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE Schedule Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_schedule;

DELIMITER //

CREATE PROCEDURE sp_create_schedule(
    IN input_schedule_date DATE,
    IN input_shift_name VARCHAR(255),
    OUT schedule_id INT
)
BEGIN

    INSERT INTO Schedules (scheduleDate, shiftName)
    Values (input_schedule_date, input_shift_name);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO schedule_id;
    SELECT LAST_INSERT_ID() AS 'schedule_id';


END //

DELIMITER ;

-- ---------------------------------------
-- UPDATE Schedule Row
-- ---------------------------------------

DROP PROCEDURE IF EXISTS sp_update_schedule;

DELIMITER //

CREATE PROCEDURE sp_update_schedule(
    IN input_schedule_id INT,
    IN input_schedule_date DATE,
    IN input_shift_name VARCHAR(255)
)
BEGIN

    UPDATE Schedules
    SET scheduleDate = input_schedule_date, shiftName = input_shift_name
    WHERE scheduleID = input_schedule_id;

END //

DELIMITER ;

-- ---------------------------------------
-- DELETE Schedule Row
-- ---------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_schedule;

DELIMITER //

CREATE PROCEDURE sp_delete_schedule(IN input_schedule_id INT)
BEGIN

    DELETE FROM Schedules WHERE scheduleID = input_schedule_id;

END //

DELIMITER ;

-- ----------------------------------------------------------------------------------------------
-- DAILY ASSIGNMENTS CUD FUNCTIONALITY
-- ----------------------------------------------------------------------------------------------

-------------------------------------------
-- CREATE DailyAssignment Row
-------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_daily_assignment;

DELIMITER //

CREATE PROCEDURE sp_create_daily_assignment(
    IN input_schedule_id INT,
    IN input_tm_id INT,
    IN input_position_id INT,
    OUT assignment_id INT
)
BEGIN

    INSERT INTO DailyAssignments (scheduleID, teamMemberID, positionID)
    VALUES (input_schedule_id, input_tm_id, input_position_id);

    -- get ID for output
    SELECT LAST_INSERT_ID() INTO assignment_id;
    SELECT LAST_INSERT_ID() AS 'assignment_id';


END //

DELIMITER ;

-- ---------------------------------------
-- UPDATE DailyAssignment Row
-- ---------------------------------------

DROP PROCEDURE IF EXISTS sp_update_daily_assignment;

DELIMITER //

CREATE PROCEDURE sp_update_daily_assignment(
    IN input_assignment_id INT,
    IN input_schedule_id INT,
    IN input_tm_id INT,
    IN input_position_id INT
)
BEGIN

    UPDATE DailyAssignments
    SET scheduleID = input_schedule_id, teamMemberID = input_tm_id, positionID = input_position_id
    WHERE assignmentID = input_assignment_id;

END //

DELIMITER ;

-- ---------------------------------------
-- DELETE DailyAssignment Row
-- ---------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_daily_assignment;

DELIMITER //

CREATE PROCEDURE sp_delete_daily_assignment(IN input_assignment_id INT)
BEGIN

    DELETE FROM DailyAssignments WHERE assignmentID = input_assignment_id;

END //

DELIMITER ;

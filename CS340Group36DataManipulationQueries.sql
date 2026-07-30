/* Group 36, authors Alysha Timmons and Jason Bluedorn */
/* Any values with @ in front are to be replaced with variables using data from database */

/* ---------------------------------------------------
Lines SQL
-----------------------------------------------------*/

/* READ Lines */
SELECT lineID, lineName, department
FROM AssemblyLines;

/* Add new Line */

INSERT INTO AssemblyLines (lineName, department)
Values (@lineName_from_form, @department_from_form);

/* Delete a Line */

DELETE FROM AssemblyLines
WHERE lineID = @lineID_of_row_of_button;

/* Edit a line pre-fill*/

SELECT lineID, lineName, department
FROM AssemblyLines
WHERE lineID = @lineID_of_row_of_button;

/* Update the line */

UPDATE AssemblyLines
SET lineID = @lineName_from_form, department = @department_from_form
WHERE lineID = @lineID_of_row_of_button;

/* ---------------------------------------------------
Team Members SQL
-----------------------------------------------------*/

/* Read lines */

SELECT TeamMembers.teamMemberID, TeamMembers.firstName, TeamMembers.lastName, AssemblyLines.lineName, TeamMembers.employmentStatus
FROM TeamMembers
INNER JOIN AssemblyLines ON TeamMembers.homeLineID = AssemblyLines.lineID;

/* Read for Home line Dropdown */

SELECT lineID, lineName FROM AssemblyLines;

/* Add new Team Member */

INSERT INTO TeamMembers (firstName, lastName, homeLineID, employmentStatus)
VALUES (@firstName_from_form, @lastName_from_form, @homeLineID_from_dropdown, @employmentStatus_from_dropdown);

/* Delete Team Member */

DELETE FROM TeamMembers
WHERE teamMemberID = @teamMemberID_of_row_of_button;

/* Edit Team Member Prefill */

SELECT TeamMembers.firstName, TeamMembers.lastName, AssemblyLines.lineName, TeamMembers.employmentStatus
FROM TeamMembers
INNER JOIN AssemblyLines ON TeamMembers.homeLineID = AssemblyLines.lineID
WHERE TeamMembers.teamMemberID = @teamMemberID_from_row_or_button;

/* Edit Team Member */

UPDATE TeamMembers
SET firstName = @firstName_from_form, lastName = @lastName_from_form,
    homeLineID = @homeLineID_from_dropdown, employmentStatus = @employmentStatus_from_dropdown
WHERE teamMemberID = @teamMemberID_of_row_of_button;

/* Line Dropdown for position add/edit */

SELECT lineID, lineName
FROM AssemblyLines;
/* ---------------------------------------------------
Positions SQL
-----------------------------------------------------*/

/* Read existing Positions */

SELECT Positions.positionID, Positions.positionName, AssemblyLines.lineName, Positions.requiredStaff, Skills.skillName
FROM AssemblyLines
INNER JOIN Positions ON AssemblyLines.lineID = Positions.lineID
INNER JOIN Skills ON Positions.qualifyingSkillID = Skills.skillID;

/* Skill Dropdown for position add */

SELECT skillID, skillName FROM Skills;

/* Add new Position */

INSERT INTO Positions (positionName, lineID, requiredStaff, qualifyingSkillID)
VALUES (@positionName_from_form, @lineID_from_dropdown, @requiredStaff_from_form, @qualifyingSkillID_from_dropdown);

/* Delete Position */

DELETE FROM Positions
WHERE positionID = @positionID_from_row_of_button;

/* Edit Position Pre-fill */

SELECT Positions.positionName, AssemblyLines.lineName, Positions.requiredStaff, Skills.skillName
FROM AssemblyLines
INNER JOIN Positions ON AssemblyLines.lineID = Positions.lineID
INNER JOIN Skills ON Positions.qualifyingSkillID = Skills.skillID
WHERE positionID = @positionID_from_row_of_button;

/* edit position */

UPDATE Positions
SET positionName = @positionName_from_form, lineID = @lineID_from_dropdown,
    requiredStaff = @requiredStaff_from_form, qualifyingSkillID = @qualifyingSkillID_from_dropdown
WHERE positionID = @positionID_from_row_of_button;

/* ---------------------------------------------------
Skills SQL
-----------------------------------------------------*/

/* read existing skills */

SELECT skillID, skillName, skillDescription
FROM Skills;

/* Add new Line */

INSERT INTO Skills (skillName, skillDescription)
Values (@skillName_from_form, @skillDescription_from_form);

/* Delete a Line */

DELETE FROM Skills
WHERE skillID = @skillID_of_row_of_button;

/* Edit a line pre-fill*/

SELECT skillID, skillName, skillDescription 
FROM Skills
WHERE skillID = @skillID_of_row_of_button;

/* Update skill */

UPDATE Skills
SET skillName = @skillName_from_form, skillDescription = @skillDescription_from_form
WHERE skillID = @skillID_from_row_of_button;

/* ---------------------------------------------------
Team Member Skills SQL
-----------------------------------------------------*/

/* Read existing skill assignments */

SELECT TeamMembers.firstName, TeamMembers.lastName, Skills.skillName
FROM TeamMembers
INNER JOIN TeamMemberSkills ON TeamMembers.teamMemberID = Skills.teamMemberID
INNER JOIN Skills ON TeamMemberSkills.skillID = Skills.skillID;

/* Team Member dropdown */

SELECT teamMemberID, firstName, lastName
FROM TeamMembers;

/* Skill dropdown */

SELECT skillID, skillName
FROM Skills;

/* add new skill to TeamMember */

INSERT INTO TeamMemberSkills (teamMemberID, skillID)
VALUES (@teamMemberID_from_dropdown, @skillID_from_dropdown);

/* Remove skill from TeamMember */

DELETE FROM TeamMemberSkills
WHERE teamMemberID = @teamMemberID_from_row_or_button AND skillID = @skillID_of_row_of_button;

/* ---------------------------------------------------
Schedules SQL
-----------------------------------------------------*/

/* read existing schedules */

SELECT scheduleID, scheduleDate, shiftName
FROM Schedules;

/* Add new Line */

INSERT INTO Schedules (scheduleDate, shiftName)
Values (@scheduleDate_from_form, @shiftName_from_form);

/* Delete a Line */

DELETE FROM Schedules
WHERE scheduleID = @scheduleID_of_row_of_button;

/* Edit a line pre-fill*/

SELECT scheduleDate, shiftName 
FROM Schedules
WHERE scheduleID = @scheduleID_of_row_of_button;

/* Update skill */

UPDATE Schedules
SET scheduleDate = @scheduleDate_from_form, shiftName = @shiftName_from_form
WHERE scheduleID = @scheduleID_from_row_of_button;

/* ---------------------------------------------------
Daily Assignments SQL
-----------------------------------------------------*/

/* read all daily assignments */

SELECT DailyAssignments.assignmentID, Schedules.scheduleDate, Schedules.shiftName, TeamMembers.firstName, TeamMembers.lastName, Positions.positionName
FROM Schedules
INNER JOIN DailyAssignments ON Schedules.scheduleID = DailyAssignments.scheduleID
INNER JOIN TeamMembers ON DailyAssignments.teamMemberID = TeamMembers.teamMemberID
INNER JOIN Positions ON DailyAssignments.positionID = Positions.positionID;

/* drop down for Schedules same as display query*/

SELECT scheduleID, scheduleDate, shiftName
FROM Schedules;

/* drop down for Team Members */

SELECT teamMemberID, firstName, lastName
FROM TeamMembers;

/* drop down for positions */

SELECT positionID, positionName FROM Positions;

/* Insert new Daily Assignment */

INSERT INTO DailyAssignments (scheduleID, teamMemberID, positionID)
VALUES (@scheduleID_from_dropdown, @teamMemberID_from_dropdown, @positionID_from_dropdown);

/* Delete daily assignment */

DELETE FROM DailyAssignments
WHERE assignmentID = @assignmentID_from_row_of_button;

/* Edit Daily Assignment Prefill */

SELECT Schedules.scheduleDate, Schedules.shiftName, TeamMembers.firstName, TeamMembers.lastName, Positions.positionName
FROM Schedules
INNER JOIN DailyAssignments ON Schedules.scheduleID = DailyAssignments.scheduleID
INNER JOIN TeamMembers ON DailyAssignments.teamMemberID = TeamMembers.teamMemberID
INNER JOIN Positions ON DailyAssignments.positionID = Positions.positionID
WHERE DailyAssignments.assignmentID = @assignmentID_from_row_of_button;

/* Update Daily Assignment */

UPDATE DailyAssignments
SET scheduleID = @scheduleID_from_dropdown, teamMemberID = @teamMemberID_from_dropdown, positionID = @positionID_from_dropdown
WHERE assignmentID = assignmentID_from_row_of_button;

/* Group 36, authors Alysha Timmons and Jason Bluedorn */
/* Any values with @ in front are to be replaced with variables using data from database */

/* ---------------------------------------------------
Lines SQL
-----------------------------------------------------*/

/* READ Lines */
SELECT lineID, lineName, department
FROM AssemblyLines;

/* Add new Line */
CALL sp_create_assembly_line(
    @lineName_from_form,
    @department_from_form,
    @lineID_out
);

/* Delete a Line */
CALL sp_delete_assembly_line(
    @lineID_of_row_of_button
);

/* Edit a line pre-fill */
SELECT lineID, lineName, department
FROM AssemblyLines
WHERE lineID = @lineID_of_row_of_button;

/* Update the line */
CALL sp_update_assembly_line(
    @lineID_of_row_of_button,
    @lineName_from_form,
    @department_from_form
);


/* ---------------------------------------------------
Team Members SQL
-----------------------------------------------------*/

/* Read Team Members */
SELECT TeamMembers.teamMemberID,
       TeamMembers.firstName,
       TeamMembers.lastName,
       TeamMembers.homeLineID,
       AssemblyLines.lineName,
       TeamMembers.employmentStatus
FROM TeamMembers
INNER JOIN AssemblyLines
    ON TeamMembers.homeLineID = AssemblyLines.lineID;

/* Read for Home line Dropdown */
SELECT lineID, lineName
FROM AssemblyLines;

/* Add new Team Member */
CALL sp_create_team_member(
    @firstName_from_form,
    @lastName_from_form,
    @homeLineID_from_dropdown,
    @employmentStatus_from_dropdown,
    @teamMemberID_out
);

/* Delete Team Member */
CALL sp_delete_team_member(
    @teamMemberID_of_row_of_button
);

/* Edit Team Member Prefill */
SELECT TeamMembers.teamMemberID,
       TeamMembers.firstName,
       TeamMembers.lastName,
       TeamMembers.homeLineID,
       AssemblyLines.lineName,
       TeamMembers.employmentStatus
FROM TeamMembers
INNER JOIN AssemblyLines
    ON TeamMembers.homeLineID = AssemblyLines.lineID
WHERE TeamMembers.teamMemberID = @teamMemberID_from_row_or_button;

/* Edit Team Member */
CALL sp_update_team_member(
    @teamMemberID_of_row_of_button,
    @firstName_from_form,
    @lastName_from_form,
    @homeLineID_from_dropdown,
    @employmentStatus_from_dropdown
);

/* Line Dropdown for position add/edit */
SELECT lineID, lineName
FROM AssemblyLines;


/* ---------------------------------------------------
Positions SQL
-----------------------------------------------------*/

/* Read existing Positions */
SELECT Positions.positionID,
       Positions.positionName,
       AssemblyLines.lineName,
       Positions.requiredStaff,
       Skills.skillName
FROM AssemblyLines
INNER JOIN Positions
    ON AssemblyLines.lineID = Positions.lineID
INNER JOIN Skills
    ON Positions.qualifyingSkillID = Skills.skillID
ORDER BY AssemblyLines.lineID, Positions.positionID;

/* Skill Dropdown for position add */
SELECT skillID, skillName
FROM Skills;

/* Add new Position */
CALL sp_create_position(
    @positionName_from_form,
    @lineID_from_dropdown,
    @requiredStaff_from_form,
    @qualifyingSkillID_from_dropdown,
    @positionID_out
);

/* Delete Position */
CALL sp_delete_position(
    @positionID_from_row_of_button
);

/* Edit Position Pre-fill */
SELECT Positions.positionID,
       Positions.positionName,
       Positions.lineID,
       AssemblyLines.lineName,
       Positions.requiredStaff,
       Positions.qualifyingSkillID,
       Skills.skillName
FROM AssemblyLines
INNER JOIN Positions
    ON AssemblyLines.lineID = Positions.lineID
INNER JOIN Skills
    ON Positions.qualifyingSkillID = Skills.skillID
WHERE Positions.positionID = @positionID_from_row_of_button;

/* Edit position */
CALL sp_update_position(
    @positionID_from_row_of_button,
    @positionName_from_form,
    @lineID_from_dropdown,
    @requiredStaff_from_form,
    @qualifyingSkillID_from_dropdown
);


/* ---------------------------------------------------
Skills SQL
-----------------------------------------------------*/

/* Read existing skills */
SELECT skillID, skillName, skillDescription
FROM Skills;

/* Add new Skill */
CALL sp_create_skill(
    @skillName_from_form,
    @skillDescription_from_form,
    @skillID_out
);

/* Delete a Skill */
CALL sp_delete_skill(
    @skillID_of_row_of_button
);

/* Edit a Skill pre-fill */
SELECT skillID, skillName, skillDescription
FROM Skills
WHERE skillID = @skillID_of_row_of_button;

/* Update Skill */
CALL sp_update_skill(
    @skillID_from_row_of_button,
    @skillName_from_form,
    @skillDescription_from_form
);


/* ---------------------------------------------------
Team Member Skills SQL
-----------------------------------------------------*/

/* Read existing skill assignments */
SELECT TeamMemberSkills.teamMemberID,
       TeamMembers.firstName,
       TeamMembers.lastName,
       TeamMemberSkills.skillID,
       Skills.skillName
FROM TeamMemberSkills
INNER JOIN TeamMembers
    ON TeamMemberSkills.teamMemberID = TeamMembers.teamMemberID
INNER JOIN Skills
    ON TeamMemberSkills.skillID = Skills.skillID;

/* Team Member dropdown */
SELECT teamMemberID, firstName, lastName
FROM TeamMembers;

/* Skill dropdown */
SELECT skillID, skillName
FROM Skills;

/* Add new skill to TeamMember */
CALL sp_create_tm_skill(
    @teamMemberID_from_dropdown,
    @skillID_from_dropdown
);

/* Remove skill from TeamMember */
CALL sp_delete_tm_skill(
    @teamMemberID_from_row_or_button,
    @skillID_of_row_of_button
);

/* Update TeamMember Skill */
CALL sp_update_tm_skill(
    @oldTeamMemberID,
    @oldSkillID,
    @newTeamMemberID,
    @newSkillID
);


/* ---------------------------------------------------
Schedules SQL
-----------------------------------------------------*/

/* Read existing schedules */
SELECT scheduleID,
       DATE_FORMAT(scheduleDate, '%m/%d/%Y') AS scheduleDate,
       shiftName
FROM Schedules;

/* Add new Schedule */
CALL sp_create_schedule(
    @scheduleDate_from_form,
    @shiftName_from_form,
    @scheduleID_out
);

/* Delete a Schedule */
CALL sp_delete_schedule(
    @scheduleID_of_row_of_button
);

/* Edit a Schedule pre-fill */
SELECT scheduleID, scheduleDate, shiftName
FROM Schedules
WHERE scheduleID = @scheduleID_of_row_of_button;

/* Update Schedule */
CALL sp_update_schedule(
    @scheduleID_from_row_of_button,
    @scheduleDate_from_form,
    @shiftName_from_form
);


/* ---------------------------------------------------
Daily Assignments SQL
-----------------------------------------------------*/

/* Read all daily assignments */
SELECT DailyAssignments.assignmentID,
       DATE_FORMAT(Schedules.scheduleDate, '%m/%d/%Y') AS scheduleDate,
       Schedules.shiftName,
       TeamMembers.firstName,
       TeamMembers.lastName,
       Positions.positionName
FROM Schedules
INNER JOIN DailyAssignments
    ON Schedules.scheduleID = DailyAssignments.scheduleID
INNER JOIN TeamMembers
    ON DailyAssignments.teamMemberID = TeamMembers.teamMemberID
INNER JOIN Positions
    ON DailyAssignments.positionID = Positions.positionID
ORDER BY Schedules.scheduleDate, TeamMembers.lastName;

/* Dropdown for Schedules */
SELECT scheduleID,
       DATE_FORMAT(scheduleDate, '%m/%d/%Y') AS scheduleDate,
       shiftName
FROM Schedules;

/* Dropdown for Team Members */
SELECT teamMemberID, firstName, lastName
FROM TeamMembers;

/* Dropdown for Positions */
SELECT positionID, positionName
FROM Positions;

/* Insert new Daily Assignment */
CALL sp_create_daily_assignment(
    @scheduleID_from_dropdown,
    @teamMemberID_from_dropdown,
    @positionID_from_dropdown,
    @assignmentID_out
);

/* Delete Daily Assignment */
CALL sp_delete_daily_assignment(
    @assignmentID_from_row_of_button
);

/* Edit Daily Assignment Prefill */
SELECT DailyAssignments.assignmentID,
       DailyAssignments.scheduleID,
       DailyAssignments.teamMemberID,
       DailyAssignments.positionID,
       Schedules.scheduleDate,
       Schedules.shiftName,
       TeamMembers.firstName,
       TeamMembers.lastName,
       Positions.positionName
FROM Schedules
INNER JOIN DailyAssignments
    ON Schedules.scheduleID = DailyAssignments.scheduleID
INNER JOIN TeamMembers
    ON DailyAssignments.teamMemberID = TeamMembers.teamMemberID
INNER JOIN Positions
    ON DailyAssignments.positionID = Positions.positionID
WHERE DailyAssignments.assignmentID = @assignmentID_from_row_of_button;

/* Update Daily Assignment */
CALL sp_update_daily_assignment(
    @assignmentID_from_row_of_button,
    @scheduleID_from_dropdown,
    @teamMemberID_from_dropdown,
    @positionID_from_dropdown
);
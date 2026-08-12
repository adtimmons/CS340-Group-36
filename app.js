const express = require("express");
const { engine } = require("express-handlebars");
const path = require("path");
const db = require("./database/db-connector");

const app = express();
const PORT = process.env.PORT || 1340;

// Configure Handlebars.
app.engine(
  "hbs",
  engine({
    extname: ".hbs",
    defaultLayout: "main"
  })
);

app.set("view engine", "hbs");
app.set("views", path.join(__dirname, "views"));

// Allow CSS and other public files.
app.use(express.static(path.join(__dirname, "public")));

// Allow form data to be read later.
app.use(express.urlencoded({ extended: true }));

// Pages.
app.get("/", (req, res) => {
  res.render("index", { title: "Home" });
});

app.get("/lines", async (req, res) => {
  try {
    const [lines] = await db.query(`
      SELECT lineID, lineName, department
      FROM AssemblyLines
      ORDER BY lineID;
    `);

    res.render("lines", {
      title: "Assembly Lines",
      lines
    });
  } catch (error) {
    console.error("Error loading AssemblyLines:", error);
    res.status(500).send(`
      <h2>Unable to load AssemblyLines</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/lines/add", async (req, res) => {
  try {
    const lineName = req.body.lineName;
    const department = req.body.department;

    if (!lineName || !department) {
      return res.status(400).send("Invalid line information.");
    }

    await db.query(
      "CALL sp_create_assembly_line(?, ?, @line_id)",
      [lineName, department]
    );

    res.redirect("/lines");
  } catch (error) {
    console.error("Error adding assembly line:", error);
    res.status(500).send(`
      <h2>Unable to add assembly line</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/lines/update", async (req, res) => {
  try {
    const lineID = Number(req.body.lineID);
    const lineName = req.body.lineName;
    const department = req.body.department;

    if (
      !Number.isInteger(lineID) ||
      lineID <= 0 ||
      !lineName ||
      !department
    ) {
      return res.status(400).send("Invalid line information.");
    }

    await db.query(
      "CALL sp_update_assembly_line(?, ?, ?)",
      [lineID, lineName, department]
    );

    res.redirect("/lines");
  } catch (error) {
    console.error("Error updating assembly line:", error);
    res.status(500).send(`
      <h2>Unable to update assembly line</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/lines/delete", async (req, res) => {
  try {
    const lineID = Number(req.body.lineID);

    if (!Number.isInteger(lineID) || lineID <= 0) {
      return res.status(400).send("Invalid line ID.");
    }

    await db.query(
      "CALL sp_delete_assembly_line(?)",
      [lineID]
    );

    res.redirect("/lines");
  } catch (error) {
    console.error("Error deleting assembly line:", error);
    res.status(500).send(`
      <h2>Unable to delete assembly line</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/team-members", async (req, res) => {
  try {
    const teamMembersQuery = `
      SELECT
        TeamMembers.teamMemberID,
        TeamMembers.firstName,
        TeamMembers.lastName,
        TeamMembers.homeLineID,
        AssemblyLines.lineName,
        TeamMembers.employmentStatus
      FROM TeamMembers
      INNER JOIN AssemblyLines
        ON TeamMembers.homeLineID = AssemblyLines.lineID
      ORDER BY TeamMembers.teamMemberID;
    `;

    const linesQuery = `
      SELECT
        lineID,
        lineName
      FROM AssemblyLines
      ORDER BY lineName;
    `;

    const [teamMembers] = await db.query(teamMembersQuery);
    const [lines] = await db.query(linesQuery);

    res.render("teamMembers", {
      title: "Team Members",
      teamMembers,
      lines
    });

  } catch (error) {
    console.error("Error loading Team Members:", error);
    res.status(500).send(`
      <h2>Unable to load Team Members</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/team-members/add", async (req, res) => {
  try {
    const firstName = req.body.firstName;
    const lastName = req.body.lastName;
    const homeLineID = Number(req.body.homeLineID);
    const employmentStatus = req.body.employmentStatus;

    if (
      !firstName ||
      !lastName ||
      !Number.isInteger(homeLineID) ||
      homeLineID <= 0 ||
      !employmentStatus
    ) {
      return res.status(400).send("Invalid team member information.");
    }

    await db.query(
      "CALL sp_create_team_member(?, ?, ?, ?, @team_member_id)",
      [firstName, lastName, homeLineID, employmentStatus]
    );

    res.redirect("/team-members");
  } catch (error) {
    console.error("Error adding team member:", error);
    res.status(500).send(`
      <h2>Unable to add team member</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/team-members/update", async (req, res) => {
  try {
    const teamMemberID = Number(req.body.teamMemberID);
    const firstName = req.body.firstName;
    const lastName = req.body.lastName;
    const homeLineID = Number(req.body.homeLineID);
    const employmentStatus = req.body.employmentStatus;

    if (
      !Number.isInteger(teamMemberID) ||
      teamMemberID <= 0 ||
      !firstName ||
      !lastName ||
      !Number.isInteger(homeLineID) ||
      homeLineID <= 0 ||
      !employmentStatus
    ) {
      return res.status(400).send("Invalid team member information.");
    }

    await db.query(
      "CALL sp_update_team_member(?, ?, ?, ?, ?)",
      [
        teamMemberID,
        firstName,
        lastName,
        homeLineID,
        employmentStatus
      ]
    );

    res.redirect("/team-members");
  } catch (error) {
    console.error("Error updating team member:", error);
    res.status(500).send(`
      <h2>Unable to update team member</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/team-members/delete", async (req, res) => {
  try {
    const teamMemberID = Number(req.body.teamMemberID);

    if (!Number.isInteger(teamMemberID) || teamMemberID <= 0) {
      return res.status(400).send("Invalid team member ID.");
    }

    await db.query(
      "CALL sp_delete_team_member(?)",
      [teamMemberID]
    );

    res.redirect("/team-members");
  } catch (error) {
    console.error("Error deleting team member:", error);
    res.status(500).send(`
      <h2>Unable to delete team member</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/positions", async (req, res) => {
  try {
    const positionsQuery = `
      SELECT
        Positions.positionID,
        Positions.positionName,
        AssemblyLines.lineName,
        Positions.requiredStaff,
        Skills.skillName
      FROM Positions
      INNER JOIN AssemblyLines
        ON Positions.lineID = AssemblyLines.lineID
      INNER JOIN Skills
        ON Positions.qualifyingSkillID = Skills.skillID
      ORDER BY AssemblyLines.lineID, Positions.positionID;
    `;

    const linesQuery = `
      SELECT lineID, lineName
      FROM AssemblyLines
      ORDER BY lineName;
    `;

    const skillsQuery = `
      SELECT skillID, skillName
      FROM Skills
      ORDER BY skillName;
    `;

    const [positions] = await db.query(positionsQuery);
    const [lines] = await db.query(linesQuery);
    const [skills] = await db.query(skillsQuery);

    res.render("positions", {
      title: "Positions",
      positions,
      lines,
      skills
    });
  } catch (error) {
    console.error("Error loading Positions:", error);
    res.status(500).send("Unable to load positions.");
  }
});

app.post("/positions/add", async (req, res) => {
  try {
    const positionName = req.body.positionName;
    const lineID = Number(req.body.lineID);
    const requiredStaff = Number(req.body.requiredStaff);
    const qualifyingSkillID = Number(req.body.qualifyingSkillID);

    if (
      !positionName ||
      !Number.isInteger(lineID) ||
      lineID <= 0 ||
      !Number.isInteger(requiredStaff) ||
      requiredStaff <= 0 ||
      !Number.isInteger(qualifyingSkillID) ||
      qualifyingSkillID <= 0
    ) {
      return res.status(400).send("Invalid position information.");
    }

    await db.query(
      "CALL sp_create_position(?, ?, ?, ?, @position_id)",
      [positionName, lineID, requiredStaff, qualifyingSkillID]
    );

    res.redirect("/positions");
  } catch (error) {
    console.error("Error adding position:", error);
    res.status(500).send(`
      <h2>Unable to add position</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/positions/update", async (req, res) => {
  try {
    const positionID = Number(req.body.positionID);
    const positionName = req.body.positionName;
    const lineID = Number(req.body.lineID);
    const requiredStaff = Number(req.body.requiredStaff);
    const qualifyingSkillID = Number(req.body.qualifyingSkillID);

    if (
      !Number.isInteger(positionID) ||
      positionID <= 0 ||
      !positionName ||
      !Number.isInteger(lineID) ||
      lineID <= 0 ||
      !Number.isInteger(requiredStaff) ||
      requiredStaff <= 0 ||
      !Number.isInteger(qualifyingSkillID) ||
      qualifyingSkillID <= 0
    ) {
      return res.status(400).send("Invalid position information.");
    }

    await db.query(
      "CALL sp_update_position(?, ?, ?, ?, ?)",
      [
        positionID,
        positionName,
        lineID,
        requiredStaff,
        qualifyingSkillID
      ]
    );

    res.redirect("/positions");
  } catch (error) {
    console.error("Error updating position:", error);
    res.status(500).send(`
      <h2>Unable to update position</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/positions/delete", async (req, res) => {
  try {
    const positionID = Number(req.body.positionID);

    if (!Number.isInteger(positionID) || positionID <= 0) {
      return res.status(400).send("Invalid position ID.");
    }

    await db.query(
      "CALL sp_delete_position(?)",
      [positionID]
    );

    res.redirect("/positions");
  } catch (error) {
    console.error("Error deleting position:", error);
    res.status(500).send(`
      <h2>Unable to delete position</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/skills", async (req, res) => {
  try {
    const skillsQuery = `
      SELECT
        skillID,
        skillName,
        skillDescription
      FROM Skills
      ORDER BY skillID;
    `;

    const [skills] = await db.query(skillsQuery);

    res.render("skills", {
      title: "Skills",
      skills
    });
  } catch (error) {
    console.error("Error loading Skills:", error);
    res.status(500).send("Unable to load skills.");
  }
});

app.post("/skills/add", async (req, res) => {
  try {
    const skillName = req.body.skillName;
    const skillDescription = req.body.skillDescription || null;

    if (!skillName) {
      return res.status(400).send("Skill name is required.");
    }

    await db.query(
      "CALL sp_create_skill(?, ?, @skill_id)",
      [skillName, skillDescription]
    );

    res.redirect("/skills");
  } catch (error) {
    console.error("Error adding skill:", error);
    res.status(500).send(`
      <h2>Unable to add skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/skills/update", async (req, res) => {
  try {
    const skillID = Number(req.body.skillID);
    const skillName = req.body.skillName;
    const skillDescription = req.body.skillDescription || null;

    if (
      !Number.isInteger(skillID) ||
      skillID <= 0 ||
      !skillName
    ) {
      return res.status(400).send("Invalid skill information.");
    }

    await db.query(
      "CALL sp_update_skill(?, ?, ?)",
      [skillID, skillName, skillDescription]
    );

    res.redirect("/skills");
  } catch (error) {
    console.error("Error updating skill:", error);
    res.status(500).send(`
      <h2>Unable to update skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/skills/delete", async (req, res) => {
  try {
    const skillID = Number(req.body.skillID);

    if (!Number.isInteger(skillID) || skillID <= 0) {
      return res.status(400).send("Invalid skill ID.");
    }

    await db.query(
      "CALL sp_delete_skill(?)",
      [skillID]
    );

    res.redirect("/skills");
  } catch (error) {
    console.error("Error deleting skill:", error);
    res.status(500).send(`
      <h2>Unable to delete skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/team-member-skills", async (req, res) => {
  try {
    const teamMemberSkillsQuery = `
      SELECT
        TeamMemberSkills.teamMemberID,
        CONCAT(TeamMembers.firstName, ' ', TeamMembers.lastName) AS teamMemberName,
        TeamMemberSkills.skillID,
        Skills.skillName
      FROM TeamMemberSkills
      INNER JOIN TeamMembers
        ON TeamMemberSkills.teamMemberID = TeamMembers.teamMemberID
      INNER JOIN Skills
        ON TeamMemberSkills.skillID = Skills.skillID
      ORDER BY TeamMembers.lastName, Skills.skillName;
    `;

    const teamMembersQuery = `
      SELECT
        teamMemberID,
        CONCAT(firstName, ' ', lastName) AS teamMemberName
      FROM TeamMembers
      ORDER BY lastName;
    `;

    const skillsQuery = `
      SELECT
        skillID,
        skillName
      FROM Skills
      ORDER BY skillName;
    `;

    const [teamMemberSkills] = await db.query(teamMemberSkillsQuery);
    const [teamMembers] = await db.query(teamMembersQuery);
    const [skills] = await db.query(skillsQuery);

    res.render("teamMemberSkills", {
      title: "Team Member Skills",
      teamMemberSkills,
      teamMembers,
      skills
    });

  } catch (error) {
    console.error(error);
    res.status(500).send("Error loading Team Member Skills.");
  }
});

app.post("/team-member-skills/add", async (req, res) => {
  try {
    const teamMemberID = Number(req.body.teamMemberID);
    const skillID = Number(req.body.skillID);

    if (
      !Number.isInteger(teamMemberID) ||
      !Number.isInteger(skillID) ||
      teamMemberID <= 0 ||
      skillID <= 0
    ) {
      return res.status(400).send("Invalid team member or skill.");
    }

    await db.query(
      "CALL sp_create_tm_skill(?, ?)",
      [teamMemberID, skillID]
    );

    res.redirect("/team-member-skills");
  } catch (error) {
    console.error("Error assigning skill:", error);

    res.status(500).send(`
      <h2>Unable to assign skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/team-member-skills/delete", async (req, res) => {
  try {
    const teamMemberID = Number(req.body.teamMemberID);
    const skillID = Number(req.body.skillID);

    if (
      !Number.isInteger(teamMemberID) ||
      !Number.isInteger(skillID) ||
      teamMemberID <= 0 ||
      skillID <= 0
    ) {
      return res.status(400).send("Invalid team member or skill.");
    }

    await db.query(
      "CALL sp_delete_tm_skill(?, ?)",
      [teamMemberID, skillID]
    );

    res.redirect("/team-member-skills");
  } catch (error) {
    console.error("Error deleting team member skill:", error);

    res.status(500).send(`
      <h2>Unable to delete team member skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/schedules", async (req, res) => {
  try {
    const schedulesQuery = `
      SELECT
        scheduleID,
        scheduleDate,
        shiftName
      FROM Schedules
      ORDER BY scheduleDate, shiftName;
    `;

    const [schedules] = await db.query(schedulesQuery);

    res.render("schedules", {
      title: "Schedules",
      schedules
    });

  } catch (error) {
    console.error(error);
    res.status(500).send("Error loading schedules.");
  }
});

app.post("/schedules/add", async (req, res) => {
  try {
    const scheduleDate = req.body.scheduleDate;
    const shiftName = req.body.shiftName;

    if (!scheduleDate || !shiftName) {
      return res.status(400).send("Invalid schedule information.");
    }

    await db.query(
      "CALL sp_create_schedule(?, ?, @schedule_id)",
      [scheduleDate, shiftName]
    );

    res.redirect("/schedules");
  } catch (error) {
    console.error("Error adding schedule:", error);
    res.status(500).send(`
      <h2>Unable to add schedule</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/schedules/update", async (req, res) => {
  try {
    const scheduleID = Number(req.body.scheduleID);
    const scheduleDate = req.body.scheduleDate;
    const shiftName = req.body.shiftName;

    if (
      !Number.isInteger(scheduleID) ||
      scheduleID <= 0 ||
      !scheduleDate ||
      !shiftName
    ) {
      return res.status(400).send("Invalid schedule information.");
    }

    await db.query(
      "CALL sp_update_schedule(?, ?, ?)",
      [scheduleID, scheduleDate, shiftName]
    );

    res.redirect("/schedules");
  } catch (error) {
    console.error("Error updating schedule:", error);
    res.status(500).send(`
      <h2>Unable to update schedule</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/team-member-skills/update", async (req, res) => {
  try {
    const [oldTeamMemberID, oldSkillID] =
      req.body.oldAssignment.split(",").map(Number);

    const newTeamMemberID = Number(req.body.newTeamMemberID);
    const newSkillID = Number(req.body.newSkillID);

    if (
      !Number.isInteger(oldTeamMemberID) ||
      !Number.isInteger(oldSkillID) ||
      !Number.isInteger(newTeamMemberID) ||
      !Number.isInteger(newSkillID) ||
      oldTeamMemberID <= 0 ||
      oldSkillID <= 0 ||
      newTeamMemberID <= 0 ||
      newSkillID <= 0
    ) {
      return res.status(400).send("Invalid skill assignment.");
    }

    await db.query(
      "CALL sp_update_tm_skill(?, ?, ?, ?)",
      [
        oldTeamMemberID,
        oldSkillID,
        newTeamMemberID,
        newSkillID
      ]
    );

    res.redirect("/team-member-skills");

  } catch (error) {
    console.error(
      "Error updating team member skill:",
      error
    );

    res.status(500).send(`
      <h2>Unable to update team member skill</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/schedules/delete", async (req, res) => {
  try {
    const scheduleID = Number(req.body.scheduleID);

    if (!Number.isInteger(scheduleID) || scheduleID <= 0) {
      return res.status(400).send("Invalid schedule ID.");
    }

    await db.query("CALL sp_delete_schedule(?)", [scheduleID]);

    res.redirect("/schedules");
  } catch (error) {
    console.error("Error deleting schedule:", error);
    res.status(500).send(`
      <h2>Unable to delete schedule</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.get("/daily-assignments", async (req, res) => {
  try {
    const assignmentsQuery = `
      SELECT
        DailyAssignments.assignmentID,
        Schedules.scheduleDate,
        Schedules.shiftName,
        CONCAT(TeamMembers.firstName, ' ', TeamMembers.lastName) AS teamMemberName,
        Positions.positionName
      FROM DailyAssignments
      INNER JOIN Schedules
        ON DailyAssignments.scheduleID = Schedules.scheduleID
      INNER JOIN TeamMembers
        ON DailyAssignments.teamMemberID = TeamMembers.teamMemberID
      INNER JOIN Positions
        ON DailyAssignments.positionID = Positions.positionID
      ORDER BY Schedules.scheduleDate, TeamMembers.lastName;
    `;

    const schedulesQuery = `
      SELECT
        scheduleID,
        scheduleDate,
        shiftName
      FROM Schedules
      ORDER BY scheduleDate;
    `;

    const teamMembersQuery = `
      SELECT
        teamMemberID,
        CONCAT(firstName, ' ', lastName) AS teamMemberName
      FROM TeamMembers
      ORDER BY lastName;
    `;

    const positionsQuery = `
      SELECT
        positionID,
        positionName
      FROM Positions
      ORDER BY positionName;
    `;

    const [dailyAssignments] = await db.query(assignmentsQuery);
    const [schedules] = await db.query(schedulesQuery);
    const [teamMembers] = await db.query(teamMembersQuery);
    const [positions] = await db.query(positionsQuery);

    res.render("dailyAssignments", {
      title: "Daily Assignments",
      dailyAssignments,
      schedules,
      teamMembers,
      positions
    });

  } catch (error) {
    console.error(error);
    res.status(500).send("Error loading Daily Assignments.");
  }
});

app.post("/daily-assignments/add", async (req, res) => {
  try {
    const scheduleID = Number(req.body.scheduleID);
    const teamMemberID = Number(req.body.teamMemberID);
    const positionID = Number(req.body.positionID);

    if (
      !Number.isInteger(scheduleID) ||
      scheduleID <= 0 ||
      !Number.isInteger(teamMemberID) ||
      teamMemberID <= 0 ||
      !Number.isInteger(positionID) ||
      positionID <= 0
    ) {
      return res.status(400).send("Invalid assignment information.");
    }

    await db.query(
      "CALL sp_create_daily_assignment(?, ?, ?, @assignment_id)",
      [scheduleID, teamMemberID, positionID]
    );

    res.redirect("/daily-assignments");
  } catch (error) {
    console.error("Error adding daily assignment:", error);
    res.status(500).send(`
      <h2>Unable to add daily assignment</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/daily-assignments/update", async (req, res) => {
  try {
    const assignmentID = Number(req.body.assignmentID);
    const scheduleID = Number(req.body.scheduleID);
    const teamMemberID = Number(req.body.teamMemberID);
    const positionID = Number(req.body.positionID);

    if (
      !Number.isInteger(assignmentID) ||
      assignmentID <= 0 ||
      !Number.isInteger(scheduleID) ||
      scheduleID <= 0 ||
      !Number.isInteger(teamMemberID) ||
      teamMemberID <= 0 ||
      !Number.isInteger(positionID) ||
      positionID <= 0
    ) {
      return res.status(400).send("Invalid assignment information.");
    }

    await db.query(
      "CALL sp_update_daily_assignment(?, ?, ?, ?)",
      [assignmentID, scheduleID, teamMemberID, positionID]
    );

    res.redirect("/daily-assignments");
  } catch (error) {
    console.error("Error updating daily assignment:", error);
    res.status(500).send(`
      <h2>Unable to update daily assignment</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/daily-assignments/delete", async (req, res) => {
  try {
    const assignmentID = Number(req.body.assignmentID);

    if (!Number.isInteger(assignmentID) || assignmentID <= 0) {
      return res.status(400).send("Invalid assignment ID.");
    }

    await db.query(
      "CALL sp_delete_daily_assignment(?)",
      [assignmentID]
    );

    res.redirect("/daily-assignments");
  } catch (error) {
    console.error("Error deleting daily assignment:", error);
    res.status(500).send(`
      <h2>Unable to delete daily assignment</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.post("/reset", async (req, res) => {
  try {
    await db.query("CALL sp_db_reset()");

    res.redirect("/");
  } catch (error) {
    console.error("Error resetting database:", error);
    res.status(500).send(`
      <h2>Unable to reset database</h2>
      <pre>${error.message}</pre>
    `);
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

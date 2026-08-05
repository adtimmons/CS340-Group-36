const express = require("express");
const { engine } = require("express-handlebars");
const path = require("path");
const db = require("./database/db-connector");

const app = express();
const PORT = process.env.PORT || 1339;

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
      ORDER BY Positions.positionID;
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
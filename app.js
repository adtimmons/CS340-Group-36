const express = require("express");
const { engine } = require("express-handlebars");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 9125;

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

app.get("/lines", (req, res) => {
  res.render("lines", { title: "Lines" });
});

app.get("/team-members", (req, res) => {
  res.render("teamMembers", { title: "Team Members" });
});

app.get("/positions", (req, res) => {
  res.render("positions", { title: "Positions" });
});

app.get("/skills", (req, res) => {
  res.render("skills", { title: "Skills" });
});

app.get("/team-member-skills", (req, res) => {
  res.render("teamMemberSkills", { title: "Team Member Skills" });
});

app.get("/schedules", (req, res) => {
  res.render("schedules", { title: "Schedules" });
});

app.get("/daily-assignments", (req, res) => {
  res.render("dailyAssignments", { title: "Daily Assignments" });
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
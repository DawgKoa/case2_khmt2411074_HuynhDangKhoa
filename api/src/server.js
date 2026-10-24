require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/database');
const { startReminderCron } = require('./services/reminderService');

const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB();

// Start Background Deadline Reminder Job (D4)
startReminderCron(30);

// Start Server
app.listen(PORT, () => {
  console.log(`[Server] Running on http://localhost:${PORT}`);
});

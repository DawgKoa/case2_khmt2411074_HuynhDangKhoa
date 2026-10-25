require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/database');
const { startReminderCron } = require('./services/reminderService');

const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB();

// Start Background Deadline Reminder Job (D4)
startReminderCron(30);

// Start Server (Listen on 0.0.0.0 so Android Emulator via 10.0.2.2 and LAN can connect)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Server] Running on http://localhost:${PORT} (0.0.0.0:${PORT})`);
});

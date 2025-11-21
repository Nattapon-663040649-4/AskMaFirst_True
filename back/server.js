const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const transferRoutes = require('./routes/transfer');
const userRoutes = require('./routes/user');
const userToken = require('./routes/register-token');
const familyRoutes = require('./routes/family');
const historyRoutes = require('./routes/history');
const inviteRoutes = require('./routes/send-invite'); 




const app = express();
const PORT = 3000;

// --Init Firebase Admin

  
// Middleware
app.use(cors());
app.use(bodyParser.json());

// 👉 เพิ่มการใช้งาน route ทั้งสอง
app.use('/', userRoutes);        // POST /user
app.use('/', transferRoutes);   // POST /transfer, GET /transactions
app.use('/', userToken);
app.use('/', familyRoutes); 
app.use('/', historyRoutes);
app.use('/', inviteRoutes)


// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend is running at http://localhost:${PORT}`);
});
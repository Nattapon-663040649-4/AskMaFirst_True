const express = require('express');
const router = express.Router();
const { admin, db } = require('../firebase'); // ปรับ path ให้ถูกต้องตามโปรเจกต์คุณ

router.post('/register-token', async (req, res) => {
  const { userId, fcmToken } = req.body;
  if (!userId || !fcmToken) {
    return res.status(400).json({ status: 'error', message: 'Missing userId or fcmToken' });
  }

  try {
    await db.collection('users').doc(userId).set({
      fcmToken
    }, { merge: true });

    res.json({ status: 'success', message: 'Token saved' });
  } catch (error) {
    console.error('Error saving token:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

module.exports = router;
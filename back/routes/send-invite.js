const express = require('express');
const router = express.Router();
const { admin, db } = require('../firebase');

router.post('/send-invite', async (req, res) => {
  const { from, to, fcm_token, family_id } = req.body;  // เพิ่ม family_id

  if (!fcm_token) {
    return res.json({ success: false, message: 'ไม่พบ token' });
  }

  const payload = {
    notification: {
      title: 'คำเชิญเข้าร่วมครอบครัว',
      body: `${from} เชิญคุณเข้าร่วมครอบครัว กดยอมรับหรือปฏิเสธได้เลย`,
    },
    data: {
      type: 'family_invite',
      fromPhone: from,
      toPhone: to,
      family_id: family_id,  // ส่ง family_id ไปด้วย
    },
    token: fcm_token,
  };

  try {
    await admin.messaging().send(payload);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.json({ success: false, message: 'ส่งไม่สำเร็จ' });
  }
});

module.exports = router;
// [POST] /history
const express = require('express');
const router = express.Router();
const { admin, db } = require('../firebase');

router.post('/history', async (req, res) => {
  const { phone } = req.body;

  try {
    const user = await db.collection('Users').doc(phone).get();
    const data = user.data();

    if (!data || !data.history) return res.json([]);

    return res.json(data.history); // <-- ให้ส่ง array of history
  } catch (err) {
    return res.status(500).send("เกิดข้อผิดพลาด");
  }
});

module.exports = router;
const express = require('express');
const router = express.Router();

const { admin, db } = require('../firebase');

router.post('/family-members', async (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ message: 'Phone is required' });

  try {
    const userDoc = await db.collection('Users').doc(phone).get();
    const userData = userDoc.data();
    if (!userData?.family_id) return res.status(404).json({ message: 'No family_id' });

    const familyDoc = await db.collection('families').doc(userData.family_id).get();
    const familyData = familyDoc.data();
    if (!familyData) return res.status(404).json({ message: 'Family not found' });

    const parents = [];
    const children = [];

    for (const p of familyData.parent || []) {
      const pDoc = await db.collection('Users').doc(p).get();
      if (pDoc.exists) parents.push(pDoc.data());
    }

    for (const c of familyData.child || []) {
      const cDoc = await db.collection('Users').doc(c).get();
      if (cDoc.exists) children.push(cDoc.data());
    }

    return res.json({ parents, children });
  } catch (err) {
    console.error('❌ Error fetching family members:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/family-invite-response', async (req, res) => {
  const { phone, family_id, accepted } = req.body;

  if (!phone || !family_id || accepted === undefined) {
    return res.status(400).json({ success: false, message: 'ข้อมูลไม่ครบ' });
  }

  try {
    if (accepted) {
      // ✅ 1) อัปเดต family_id ของ user ใน Firestore
      await db.collection('Users').doc(phone).update({
        family_id: family_id,
      });

      // ✅ 2) เพิ่มเบอร์เข้าไปใน array child ของ families
      await db.collection('families').doc(family_id).update({
        child: admin.firestore.FieldValue.arrayUnion(phone)
      });

      res.json({ success: true, message: 'เพิ่มสมาชิกครอบครัวสำเร็จ' });
    } else {
      res.json({ success: true, message: 'ผู้ใช้ปฏิเสธคำเชิญ' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'เกิดข้อผิดพลาดในระบบ' });
  }
});



module.exports = router;
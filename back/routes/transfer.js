const express = require('express');
const router = express.Router();
const { admin, db } = require('../firebase');

router.post('/approve-transfer', async (req, res) => {
  const { from, to, approved = false, amount } = req.body; // 👈 รับ amount มาด้วย

  if (approved) {
    const fromRef = db.collection('Users').doc(from);
    const fromSnap = await fromRef.get();
    const fromData = fromSnap.data();
    const childFcmToken = fromData?.fcm_token;
    console.log('📱 FCM token:', childFcmToken);

    if (childFcmToken) {
      await admin.messaging().send({
        token: childFcmToken,
        notification: {
          title: 'แม่อนุมัติแล้ว',
          body: `ไปยืนยันการโอน ${amount} บาทได้เลย`,
        },
        data: {
          type: 'transfer_approved',
          to: to,
          amount: amount.toString(), // 👈 ใช้ amount จริง
          phone: from, // ✅ เพิ่มตรงนี้!
          
        },
      });
      console.log("sent approve");
    }

    return res.json({ status: 'approved', message: 'แม่อนุมัติแล้ว' });
  } else {
    return res.json({ status: 'rejected', message: 'แม่ปฏิเสธแล้ว' });
  }
});

router.post('/transfer', async (req, res) => {
  const { from, to, amount, approved = false } = req.body;

  try {
    const fromRef = db.collection('Users').doc(from);
    const fromSnap = await fromRef.get();
    if (!fromSnap.exists) {
      console.log(to);
      return res.status(404).json({ status: 'error', message: 'ไม่พบผู้ใช้ที่โอน' });
    }

    const toRef = db.collection('Users').doc(to);
    const toSnap = await toRef.get();
    if (!toSnap.exists) {
      return res.status(404).json({ status: 'error', message: 'ไม่พบผู้ใช้ที่รับ' });
    }

    const fromData = fromSnap.data();
    const currentBalance = fromData.balance || 0;
    const limit = fromData.limited_money ?? 1000000;

    let isParent = false;
    let familyData = null; // 👈 ประกาศไว้ก่อน

    if (fromData.family_id) {
      const familyDoc = await db.collection('families').doc(fromData.family_id).get();
      familyData = familyDoc.data(); // 👈 กำหนดค่าให้ตัวแปรนอก
      if (familyData?.parent?.includes(to)) {
        isParent = true;
      }
    }

    if (!approved && amount > limit && !isParent) {
      if (familyData?.parent && Array.isArray(familyData.parent)) {
        for (const parentPhone of familyData.parent) {
          const parentSnap = await db.collection('Users').doc(parentPhone).get();
          const parentData = parentSnap.data();
          const parentFcmToken = parentData?.fcm_token;

          if (parentFcmToken) {
            await admin.messaging().send({
              token: parentFcmToken,
              notification: {
                title: 'คำขอโอนเงิน',
                body: `ลูกของคุณต้องการโอนเงิน ${amount} บาท (เกินลิมิตที่กำหนดไว้ ${limit} บาท)`,
              },
              data: {
                type: 'transfer_request',
                from_user: from,
                to: to,
                amount: amount.toString(),
              },
            });
            console.log("permitsion");
          }
        }
      }

      return res.status(403).json({
        status: 'pending',
        message: 'ไปถามแม่ก่อนไป',
      });
    }

    if (amount > currentBalance) {
      return res.status(400).json({
        status: 'error',
        message: 'เงินไม่พอ',
      });
    }

    const newFromBalance = currentBalance - amount;
    const toData = toSnap.data();
    const newToBalance = (toData.balance || 0) + amount;

    const transaction = {
      from,
      to,
      amount,
      timestamp: new Date(),
    };

    await fromRef.update({
      balance: newFromBalance,
      history: admin.firestore.FieldValue.arrayUnion({ ...transaction, type: 'send' }),
    });

    await toRef.update({
      balance: newToBalance,
      history: admin.firestore.FieldValue.arrayUnion({ ...transaction, type: 'receive' }),
    });

    return res.json({
      status: 'approve',
      message: 'โอนเงินสำเร็จ',
      newBalance: newFromBalance,
    });

  } catch (err) {
    console.error('❌ Transfer Error:', err);
    return res.status(500).json({
      status: 'error',
      message: 'เกิดข้อผิดพลาด',
    });
  }
});




module.exports = router;
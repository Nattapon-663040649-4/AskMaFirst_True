const express = require('express');
const router = express.Router();

const { admin, db } = require('../firebase');

router.post('/user', async (req, res) => {
  const { phone } = req.body;
  if (!phone) {
    return res.status(400).json({ message: 'Phone number is required' });
  }

  try {
    const docRef = db.collection('Users').doc(phone);
    const docSnap = await docRef.get();

    if (docSnap.exists) {
      res.json(docSnap.data());
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    console.error('Error fetching user:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/update-user', async (req, res) => {
  const { phone, limited_money } = req.body;
  try {
    const userRef = db.collection('Users').doc(phone);
    await userRef.update({ limited_money });
    res.status(200).send('User updated');
  } catch (error) {
    res.status(500).send('Update failed: ' + error.message);
  }
});



module.exports = router;
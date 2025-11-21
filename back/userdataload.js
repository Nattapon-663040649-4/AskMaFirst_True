// ตัวอย่างเส้นทาง backend รับ phone number แล้วตอบข้อมูล Firebase
app.post('/user', async (req, res) => {
  const { phone } = req.body;

  try {
    const docRef = db.collection('users').doc(phone);
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

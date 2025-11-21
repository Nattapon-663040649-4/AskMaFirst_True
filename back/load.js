const admin = require('firebase-admin');
const serviceAccount = require('./firebasekey.json');
 admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
 });

const db = admin.firestore();
async function readUserData() {
  const docRef = db.collection('transactions').doc('user');
  const docSnap = await docRef.get();

  if (docSnap.exists) {
    console.log('📄 ข้อมูลของ user:', docSnap.data());
  } else {
    console.log('❌ ไม่พบ document ชื่อ user');
  }
}

readUserData().catch(console.error);
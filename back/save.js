const admin = require('firebase-admin');
const serviceAccount = require('./firebasekey.json');
 admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
 });

 const db = admin.firestore();

 async function saveTransaction() {
    const transactionData = {
        name: 'boss',
        timestamp:admin.firestore.FieldValue.serverTimestamp(),

    }

    const res = await db.collection('transactions').doc('user').set(transactionData);
 console.log('Transaction ok boss')
 }

 saveTransaction().catch(console.error);


 
 
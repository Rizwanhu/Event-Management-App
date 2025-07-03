// Script to activate all existing admin accounts
// Run this in Firebase Console or through a Flutter app to activate existing admin accounts

// Firebase Firestore batch update to set all admin accounts as active
// This is a one-time script to fix any existing admin accounts that might be inactive

/*
In Firebase Console, go to Firestore Database and run this query:

1. Go to the 'admins' collection
2. For each document, update the 'isActive' field to true

Or you can use this Firebase Cloud Function or run it manually:

async function activateAllAdmins() {
  const admin = require('firebase-admin');
  const db = admin.firestore();
  
  const adminsRef = db.collection('admins');
  const snapshot = await adminsRef.get();
  
  const batch = db.batch();
  
  snapshot.forEach(doc => {
    batch.update(doc.ref, { isActive: true });
  });
  
  await batch.commit();
  console.log('All admin accounts have been activated');
}

activateAllAdmins();
*/

// For manual update in Firebase Console:
// 1. Go to Firestore Database
// 2. Open the 'admins' collection
// 3. For each admin document, click Edit
// 4. Set 'isActive' field to true
// 5. Save the document

// Alternative: You can also delete and recreate admin accounts using the signup form

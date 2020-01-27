const functions = require("firebase-functions");

const admin = require("firebase-admin");
admin.initializeApp();

exports.createCustomToken = functions.https.onCall(async (data, context) => {
  // Grab uid.
  const uid = data.uid;

  try {
    const customToken = await admin.auth().createCustomToken(uid);
    // Send token back to client
    return { token: customToken, error: "" };
  } catch (error) {
    console.log("Error creating custom token:", error);
    return { error: error };
  }
});

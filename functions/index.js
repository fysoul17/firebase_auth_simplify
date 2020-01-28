const functions = require("firebase-functions");
const kakao = require("./kakao");

const admin = require("firebase-admin");
admin.initializeApp();

exports.verifyKakaoToken = functions.https.onCall(async (data, context) => {
  const token = data.token;
  if (!token) return { error: "There is no token provided." };

  console.log(`Verifying Kakao token: ${token}`);

  return kakao
    .createFirebaseToken(token)
    .then(firebaseToken => {
      console.log(`Returning firebase token to user: ${firebaseToken}`);
      return { token: firebaseToken };
    })
    .catch(e => {
      return { error: e.message };
    });
});

exports.linkWithKakao = functions.https.onCall(async (data, context) => {
  const token = data.token;
  if (!token) return { error: "There is no token provided." };

  console.log(`Linking with Kakao token: ${token}`);

  return kakao
    .linkToCurrentUser(token, context.auth.uid)
    .then(userRecord => {
      console.log(`Returning user: ${userRecord}`);
      return { userRecord: userRecord };
    })
    .catch(e => {
      return { error: e.message };
    });
});

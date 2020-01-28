const admin = require("firebase-admin");
const functions = require("firebase-functions");
const request = require("request-promise");

const kakao_appId = functions.config().kakao.appid;

// Kakao API request url to retrieve user profile based on access token
const requestMeUrl = "https://kapi.kakao.com/v2/user/me?secure_resource=true";
const accessTokenInfoUrl = "https://kapi.kakao.com/v1/user/access_token_info";

/**
 * requestMe - Returns user profile from Kakao API
 *
 * @param  {String} kakaoAccessToken Access token retrieved by Kakao Login API
 * @return {Promise<Response>}      User profile response in a promise
 */
function requestMe(kakaoAccessToken) {
  console.log("Requesting user profile from Kakao API server.");
  return request({
    method: "GET",
    headers: { Authorization: "Bearer " + kakaoAccessToken },
    url: requestMeUrl
  });
}

/**
 * validateToken - Returns access token info from Kakao API,
 * which checks if this token is issued by this application.
 *
 * @param {String} kakaoAccessToken Access token retrieved by Kakao Login API
 * @return {Promise<Response>}      Access token info response
 */
function validateToken(kakaoAccessToken) {
  console.log("Validating access token from Kakao API server.");
  return request({
    method: "GET",
    headers: { Authorization: "Bearer " + kakaoAccessToken },
    url: accessTokenInfoUrl
  });
}

/**
 * createIfNotExist - If email is not given,
 * create a new user since there is no other way to map users.
 * If email is not verified, make the user re-authenticate with other means.
 *
 * @param  {String} kakaoUserId    user id per app
 * @param  {String} email          user's email address
 * @param  {Boolean} emailVerified whether this email is verified or not
 * @param  {String} displayName    user
 * @param  {String} photoURL       profile photo url
 * @return {Promise<UserRecord>}   Firebase user record in a promise
 */
function createIfNotExist(kakaoUserId, email, emailVerified, displayName, photoURL) {
  return getUser(kakaoUserId, email, emailVerified).catch(error => {
    if (error.code == "auth/user-not-found") {
      const params = {
        uid: `kakao:${kakaoUserId}`,
        displayName: displayName
      };
      if (email) {
        params["email"] = email;
      }
      if (photoURL) {
        params["photoURL"] = photoURL;
      }
      console.log(`creating a firebase user with email ${email}`);
      return admin.auth().createUser(params);
    }
    throw error;
  });
  //.then(userRecord => linkUserWithKakao(kakaoUserId, userRecord));
  // We will not directly link account if there is existing email. Instead, we will throw error, so that we can give an option of signing-in with existing account or linking later.
  // This is same behaviour as google and facebook.
}

/**
 * getUser - fetch firebase user with kakao UID first, then with email if
 * no user found. If email is not verified, throw an error so that
 * the user can re-authenticate.
 *
 * @param {String} kakaoUserId    user id per app
 * @param {String} email          user's email address
 * @param {Boolean} emailVerified whether this email is verified or not
 * @return {Promise<admin.auth.UserRecord>}
 */
function getUser(kakaoUserId, email, emailVerified) {
  console.log(`fetching a firebase user with uid kakao:${kakaoUserId}`);
  return admin
    .auth()
    .getUser(`kakao:${kakaoUserId}`)
    .catch(error => {
      if (error.code != "auth/user-not-found") {
        throw error;
      }
      if (!email) {
        throw error; // cannot find existing accounts since there is no email.
      }
      console.log(`fetching a firebase user with email ${email}`);
      return admin
        .auth()
        .getUserByEmail(email)
        .then(userRecord => {
          if (!emailVerified) {
            throw new Error("This user should authenticate first with other providers");
          }
          return userRecord;
        });
    });
}

/**
 * linkUserWithKakao - Link current user record with kakao UID
 * if not linked yet.
 *
 * @param {String} kakaoUserId
 * @param {admin.auth.UserRecord} userRecord
 * @return {Promise<UserRecord>}
 */
function linkUserWithKakao(kakaoUserId, userRecord) {
  if (userRecord.customClaims && userRecord.customClaims["kakaoUID"] == kakaoUserId) {
    console.log(`currently linked with kakao UID ${kakaoUserId}...`);
    return Promise.resolve(userRecord);
  }
  console.log(`linking user with kakao UID ${kakaoUserId}...`);
  return admin
    .auth()
    .setCustomUserClaims(userRecord.uid, { kakaoUID: kakaoUserId, provider: "kakaocorp.com" })
    .then(() => userRecord);
}

/**
 * createFirebaseToken - returns Firebase token using Firebase Admin SDK
 *
 * @param  {String} kakaoAccessToken access token from Kakao Login API
 * @return {Promise<String>}                  Firebase token in a promise
 */
exports.createFirebaseToken = function(kakaoAccessToken) {
  return validateToken(kakaoAccessToken)
    .then(response => {
      const body = JSON.parse(response);
      if (body.appId != kakao_appId) {
        throw new Error("The given token does not belong to this application.");
      }
      return requestMe(kakaoAccessToken);
    })
    .then(response => {
      const body = JSON.parse(response);
      const userId = body.id;
      if (!userId) {
        throw new Error("There was no user with the given access token.");
      }
      let nickname = null;
      let profileImage = null;
      let email = null;
      let isEmailVerified = null;
      if (body.properties) {
        nickname = body.properties.nickname;
        profileImage = body.properties.profile_image;
      }
      if (body.kakao_account) {
        email = body.kakao_account.email;
        isEmailVerified = body.kakao_account.is_email_verified;
      }
      return createIfNotExist(userId, email, isEmailVerified, nickname, profileImage);
    })
    .then(userRecord => {
      const userId = userRecord.uid;
      console.log(`creating a custom firebase token based on uid ${userId}`);
      return admin.auth().createCustomToken(userId, { kakaoUID: userId, provider: "kakaocorp.com" });
    });
};

/**
 * linkToCurrentUser - Link kakao account to currently signed-in user.
 *
 * @param  {String} uid uid of current user
 */
exports.linkToCurrentUser = function(kakaoAccessToken, uid) {
  return validateToken(kakaoAccessToken)
    .then(response => {
      const body = JSON.parse(response);
      if (body.appId != kakao_appId) {
        throw new Error("The given token does not belong to this application.");
      }
      return requestMe(kakaoAccessToken);
    })
    .then(response => {
      const body = JSON.parse(response);
      console.log(body);
      const userId = body.id;
      if (!userId) {
        throw new Error("There was no user with the given access token.");
      }

      return admin
        .auth()
        .getUser(uid)
        .then(userRecord => {
          return linkUserWithKakao(userId, userRecord);
        })
        .catch(error => {
          throw error;
        });
    });
};

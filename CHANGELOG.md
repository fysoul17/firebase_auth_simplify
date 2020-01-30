## [0.4.1] - 30/Jan/2020

- Added example screenshots

## [0.4.0] - 29/Jan/2020

- Added Phone authentication
- Added Phone authentication example
- Added assertion for sign-in logic

## [0.3.3] - 29/Jan/2020

- Fixed bug that Kakao sign-in links automatically with existing e-mail. It will throw an error and only can be linked by using link function.
- Kakao sign-in will throw a new exception in regards to above issue.
- Added try-catch block for email authentication. It will now catch error correctly.
- Fixed bug at example code. It will now trim the white space before sending to the server.
- Fixed bug at example code. Sign-in/out dialog will be disappear as expected when sign-in/out is succeeded.

## [0.3.2] - 29/Jan/2020

- Minor bug fix

## [0.3.1] - 29/Jan/2020

- Added getUserClaim function so that we can get claim data from provider
- Changed logic of signing-out from 3rd party providers

## [0.3.0] - 28/Jan/2020

- Updated cloud function for verifiying/creating Kakao token
- Changed logic of Kakao sign in
- Refactoring Kakao sign in
- Refactoring other sign ins
- Added linking function
- Made email and password as a required field

## [0.2.0] - 27/Jan/2020

- Supporting Facebook sign in

## [0.1.0] - 27/Jan/2020

- Supporting Kakao sign in

## [0.0.1] - 25/Jan/2020

- Initial release with Firebase email and Gmail support

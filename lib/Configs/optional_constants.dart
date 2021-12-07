//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

const IsCallFeatureTotallyHide =
    false; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const Is24hrsTimeformat =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int GroupMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int BroadcastMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int StatusDeleteAfterInHours =
    24; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsLogoutButtonShowInSettingsPage =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const FeedbackEmail =
    ''; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingGroups =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingBroadcasts =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingStatus =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsPercentProgressShowWhileUploading =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxFileSizeAllowedInMB =
    60; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfFilesInMultiSharing =
    10; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfContactsSelectForForward =
    7; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.

//---- ####### Below Details Not neccsarily required unless you are using the Admin App:
const ConnectWithAdminApp =
    true; // If you are planning to use the admin app, set it to "true". We recommend it to always set it to true for Advance features whether you use the admin app or not.
const dynamic RateAppUrlAndroid =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const dynamic RateAppUrlIOS =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const TERMS_CONDITION_URL =
    'YOUR_TNC'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const PRIVACY_POLICY_URL =
    'YOUR_PRIVACY_POLICY'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
//--
int maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading =
    20; //Minimum Value should be 15.
int maxAdFailedLoadAttempts = 3;//Minimum Value should be 3.

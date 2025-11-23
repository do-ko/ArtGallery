const APP_CONFIG = window.__APP_CONFIG__ || {};

import {
    CognitoUserPool,
} from "amazon-cognito-identity-js";

export const UserPool = new CognitoUserPool({
    UserPoolId: APP_CONFIG.COGNITO_USER_POOL_ID,
    ClientId: APP_CONFIG.COGNITO_CLIENT_ID,
});

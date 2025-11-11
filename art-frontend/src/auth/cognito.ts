const APP_CONFIG = window.__APP_CONFIG__ || {};

import {
    CognitoUserPool,
    CognitoUser,
    AuthenticationDetails,
    CognitoUserSession
} from "amazon-cognito-identity-js";

const pool = new CognitoUserPool({
    UserPoolId: APP_CONFIG.COGNITO_USER_POOL_ID,
    ClientId: APP_CONFIG.COGNITO_CLIENT_ID,
});

export function getCurrentUser(): CognitoUser | null {
    return pool.getCurrentUser();
}

export function getSession(): Promise<CognitoUserSession> {
    return new Promise((resolve, reject) => {
        const user = getCurrentUser();
        if (!user) return reject(new Error("No user"));
        user.getSession((err: any, session: CognitoUserSession) => {
            if (err) return reject(err);
            resolve(session);
        });
    });
}

export async function authHeader(useAccessToken = false): Promise<Record<string,string>> {
    try {
        const session = await getSession();
        const token = useAccessToken
            ? session.getAccessToken().getJwtToken()
            : session.getIdToken().getJwtToken();
        return { Authorization: `Bearer ${token}` };
    } catch {
        return {};
    }
}

export function signIn(username: string, password: string): Promise<CognitoUser | "NEW_PASSWORD_REQUIRED"> {
    const user = new CognitoUser({ Username: username, Pool: pool });
    const details = new AuthenticationDetails({ Username: username, Password: password });

    return new Promise((resolve, reject) => {
        user.authenticateUser(details, {
            onSuccess: () => resolve(user),
            onFailure: (err) => reject(err),
            newPasswordRequired: () => resolve("NEW_PASSWORD_REQUIRED"),
            mfaRequired: () => reject(new Error("MFA_REQUIRED")),
            totpRequired: () => reject(new Error("TOTP_REQUIRED")),
        });
    });
}

export function completeNewPassword(user: CognitoUser, newPassword: string): Promise<void> {
    return new Promise((resolve, reject) => {
        user.completeNewPasswordChallenge(newPassword, {}, {
            onSuccess: () => resolve(),
            onFailure: (err) => reject(err),
        });
    });
}

export function signOut(): void {
    const user = getCurrentUser();
    if (user) user.signOut();
}

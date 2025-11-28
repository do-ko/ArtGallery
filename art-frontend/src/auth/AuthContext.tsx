import {createContext, type Dispatch, type SetStateAction, useContext, useState} from "react";
import {
    AuthenticationDetails,
    CognitoUser,
    CognitoUserAttribute,
    CognitoUserSession
} from "amazon-cognito-identity-js";
import {UserPool} from "./cognito.ts";

type AuthContextType = {
    signUp: (email: string, password: string) => Promise<{ userSub: string }>;
    signIn: (username: string, password: string) => Promise<CognitoUserSession>;
    getSession: () => Promise<CognitoUserSession>;
    getCurrentUser: () => CognitoUser | null;
    signOut: () => void;
    confirmSignUp: (email: string, code: string) => Promise<void>;
    resendConfirmationCode: (email: string) => Promise<void>;
    getAuthHeader: () => Promise<string>;
    isLoggedIn : boolean;
    setIsLoggedIn: Dispatch<SetStateAction<boolean>>
};

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider = (props: any) => {

    const [isLoggedIn, setIsLoggedIn] = useState(false);

    const signUp = async (email: string, password: string): Promise<{ userSub: string }> => {
        return await new Promise((resolve, reject) => {
            const attributes = [new CognitoUserAttribute({Name: "email", Value: email})];

            UserPool.signUp(email, password, attributes, [], (err, result) => {
                if (err || !result) return reject(err);
                resolve({userSub: result.userSub});
            });
        });
    }

        const signIn = async (username: string, password: string): Promise<CognitoUserSession> => {
        return await new Promise((resolve, reject) => {
            const user = new CognitoUser({Username: username, Pool: UserPool});
            const details = new AuthenticationDetails({Username: username, Password: password});

            user.authenticateUser(details, {
                onSuccess: (data) => {
                    console.log("data", data);
                    resolve(data);
                },
                onFailure: (err) => {
                    console.log("err")
                    reject(err);
                },
                newPasswordRequired: (data) => {
                    console.log("newPasswordRequired")
                    resolve(data)
                }
            });
        })
    }

    const getSession = async (): Promise<CognitoUserSession> => {
        return await new Promise((resolve, reject) => {
            const user = UserPool.getCurrentUser();

            if (!user) return reject("Brak użytkownika – niezalogowany.");

            user.getSession((err: any, session: CognitoUserSession) => {
                if (err || !session) return reject(err || "Brak sesji.");
                resolve(session);
            });
        });
    };

    const getCurrentUser = (): CognitoUser | null => {
        return UserPool.getCurrentUser();
    };

    const signOut = (): void => {
        const user = UserPool.getCurrentUser();
        if (user) user.signOut();
        setIsLoggedIn(false);
    }

    const confirmSignUp = async (email: string, code: string): Promise<void> => {
        return await new Promise((resolve, reject) => {
            const user = new CognitoUser({Username: email, Pool: UserPool});
            user.confirmRegistration(code, true, (err) => err ? reject(err) : resolve());
        });
    }

    const resendConfirmationCode = async (email: string): Promise<void> => {
        return await new Promise((resolve, reject) => {
            const user = new CognitoUser({Username: email, Pool: UserPool});
            user.resendConfirmationCode((err) => err ? reject(err) : resolve());
        });
    }

    const getAuthHeader = async (): Promise<string> => {
        return new Promise((resolve, reject) => {
            const user = UserPool.getCurrentUser();
            if (!user) return reject("Brak użytkownika — nie zalogowany");

            user.getSession(async (err : any, session : CognitoUserSession) => {
                if (err || !session) return reject("Brak sesji");

                const accessToken = session.getAccessToken();
                const now = Math.floor(Date.now() / 1000);

                if (accessToken.getExpiration() > now) {
                    return resolve(`Bearer ${accessToken.getJwtToken()}`);
                }

                const refreshTok = session.getRefreshToken();
                if (!refreshTok) return reject("Brak refresh tokena — zaloguj się ponownie");

                user.refreshSession(refreshTok, (err, newSession) => {
                    if (err || !newSession) return reject("Nie udało się odświeżyć sesji");

                    return resolve(`Bearer ${newSession.getAccessToken().getJwtToken()}`);
                });
            });
        });
    };

    return (
        <AuthContext.Provider
            value={{signUp, signIn, getSession, getCurrentUser, signOut, confirmSignUp, resendConfirmationCode, getAuthHeader, isLoggedIn, setIsLoggedIn}}>
            {props.children}
        </AuthContext.Provider>
    )
}

export const useAuth = () => {
    const ctx = useContext(AuthContext);
    if (!ctx) {
        throw new Error("useAuth must be used within <AccountProvider>");
    }
    return ctx;
};
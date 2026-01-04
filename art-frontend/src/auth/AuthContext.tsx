import {createContext, useContext} from "react";

type AuthContextType = {
    login: () => void;
    logout: () => void;
    isAuthenticated: () => boolean;
    setTokenData: (id_token : string, access_token: string) => void;
    getAccessToken: () => string | null;
    getAuthHeader: () => string;
};

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider = (props: any) => {

    const APP_CONFIG = window.__APP_CONFIG__ || {};
    const STORAGE_ACCESS_TOKEN_KEY = "access_token";
    const STORAGE_ID_TOKEN_KEY = "id_token";

    const login = async () => {
        console.log(":::::::::::::: logging in ::::::::::::::")
        const clientId = APP_CONFIG.KEYCLOAK_CLIENT_ID;
        const realm = APP_CONFIG.KEYCLOAK_REALM;
        const baseUrl = window.location.origin;
        const redirectUri = `${baseUrl}/auth/callback`;
        const codeVerifier = generateCodeVerifier();
        const codeChallenge = codeVerifier;

        console.log("clientId: ", clientId);
        console.log("realm: ", realm);
        console.log("baseUrl: ", baseUrl);
        console.log("redirectUri: ", redirectUri);
        console.log("codeVerifier: ", codeVerifier);
        console.log("codeChallenge: ", codeChallenge);

        sessionStorage.setItem("pkce_code_verifier", codeVerifier);


        const authUrl =
            `${baseUrl}/realms/${realm}/protocol/openid-connect/auth` +
            `?client_id=${encodeURIComponent(clientId)}` +
            `&redirect_uri=${encodeURIComponent(redirectUri)}` +
            `&response_type=code` +
            `&scope=openid` +
            `&code_challenge=${codeChallenge}` +
            `&code_challenge_method=plain`;

        console.log("authUrl: ", authUrl);

        window.location.href = authUrl;
    }

    const logout = () => {
        console.log(":::::::::::::: logging out ::::::::::::::")
        const idToken = sessionStorage.getItem(STORAGE_ID_TOKEN_KEY);
        const realm = APP_CONFIG.KEYCLOAK_REALM;
        const baseUrl = window.location.origin;
        const postLogoutRedirectUri = window.location.origin;

        clearToken()

        let logoutUrl =
            `${baseUrl}/realms/${realm}/protocol/openid-connect/logout` +
            `?post_logout_redirect_uri=${encodeURIComponent(postLogoutRedirectUri)}`;

        if (idToken) {
            logoutUrl += `&id_token_hint=${encodeURIComponent(idToken)}`;
        }

        window.location.href = logoutUrl;
    }

    const isAuthenticated = () => {
        console.log(":::::::::::::: isAuthenticated ::::::::::::::")
        const token = sessionStorage.getItem(STORAGE_ACCESS_TOKEN_KEY);
        if (token && !isExpired(token)) {
            return true;
        }

        clearToken()
        return false;
    }

    const setTokenData = (id_token : string, access_token: string) => {
        console.log(":::::::::::::: setTokenData ::::::::::::::")
        sessionStorage.setItem(STORAGE_ACCESS_TOKEN_KEY, access_token);
        sessionStorage.setItem(STORAGE_ID_TOKEN_KEY, id_token);
    }

    const getAccessToken = () => {
        console.log(":::::::::::::: getAccessToken ::::::::::::::")
        const token = sessionStorage.getItem(STORAGE_ACCESS_TOKEN_KEY);
        return token;
    }

    const getAuthHeader = () => {
        console.log(":::::::::::::: getAuthHeader ::::::::::::::")
        const token = getAccessToken();
        return "Bearer " + token;
    }

    // local functions
    function generateCodeVerifier(): string {
        const array = new Uint8Array(32);
        crypto.getRandomValues(array);
        return base64UrlEncode(array);
    }

    function base64UrlEncode(buffer: Uint8Array): string {
        return btoa(String.fromCharCode(...buffer))
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");
    }

    function isExpired(token: string): boolean {
        const payload = JSON.parse(atob(token.split(".")[1]));
        const now = Math.floor(Date.now() / 1000);
        return payload.exp < now;
    }

    function clearToken() {
        sessionStorage.removeItem(STORAGE_ACCESS_TOKEN_KEY);
        sessionStorage.removeItem(STORAGE_ID_TOKEN_KEY);
    }

    return (
        <AuthContext.Provider
            value={{login, logout, isAuthenticated, getAccessToken, setTokenData, getAuthHeader}}>
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
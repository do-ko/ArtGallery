import {useEffect} from "react";
import {useNavigate} from "react-router-dom";
import {useAuth} from "./AuthContext.tsx";

export default function AuthCallback() {
    const navigate = useNavigate();
    const {setTokenData} = useAuth();

    useEffect(() => {
        (async () => {
            try {
                const params = new URLSearchParams(window.location.search);
                const code = params.get("code");

                if (!code) {
                    throw new Error("Brak code w callback");
                }

                const codeVerifier = sessionStorage.getItem("pkce_code_verifier");
                if (!codeVerifier) {
                    throw new Error("Brak code_verifier");
                }

                const config = (window as any).__APP_CONFIG__;
                const clientId = config.KEYCLOAK_CLIENT_ID;
                const realm = config.KEYCLOAK_REALM;
                const baseUrl = window.location.origin;
                const redirectUri = `${window.location.origin}/auth/callback`;

                const response = await fetch(
                    `${baseUrl}/realms/${realm}/protocol/openid-connect/token`,
                    {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded",
                        },
                        body: new URLSearchParams({
                            grant_type: "authorization_code",
                            client_id: clientId,
                            code,
                            redirect_uri: redirectUri,
                            code_verifier: codeVerifier,
                        }),
                    }
                );

                if (!response.ok) {
                    const text = await response.text();
                    throw new Error(`Token exchange failed: ${text}`);
                }

                const tokenResponse = await response.json();

                console.log("tokenResponse: ", tokenResponse);
                setTokenData(tokenResponse.id_token, tokenResponse.access_token);
                sessionStorage.removeItem("pkce_code_verifier");

                navigate("/", {replace: true});
            } catch (err) {
                console.error("Auth callback error:", err);
                navigate("/", {replace: true});
            }
        })();
    }, []);

    return (
        <div style={{padding: 40, textAlign: "center"}}>
            <h2>Signing you in…</h2>
            <p>Please wait</p>
        </div>
    );
}

import {useAuth} from "react-oidc-context";
import {isCognitoEnabled} from "../types/config.ts";

export default function LoginButton() {
    if (!isCognitoEnabled) return null;
    const auth = useAuth();

    return (
        <button onClick={async () => {
            try {
                console.log("[OIDC] signinRedirect start", auth);
                await auth.signinRedirect();
            } catch (e) {
                console.error("[OIDC] signinRedirect error", e);
            }
        }} className="login-btn">
            Log in
        </button>
    );
}

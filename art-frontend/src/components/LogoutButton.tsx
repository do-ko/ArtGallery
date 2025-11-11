import { useAuth } from "react-oidc-context";
import {isCognitoEnabled} from "../types/config.ts";

export default function LogoutButton() {
    if (!isCognitoEnabled) return null;
    const auth = useAuth();
    return (
        <button onClick={() => auth.signoutRedirect()} className="logout-btn">
            Log out
        </button>
    );
}

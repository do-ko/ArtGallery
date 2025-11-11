import LoginButton from "./LoginButton.tsx";
import LogoutButton from "./LogoutButton.tsx";
import {isCognitoEnabled} from "../types/config.ts";
import {useAuth} from "react-oidc-context";


export default function HeaderBar() {
    const auth = useAuth();

    return (
        <header className="gallery-header">
            <h1 className="gallery-title">🎨 Art Gallery</h1>

            {isCognitoEnabled && (auth.isAuthenticated ? (
                <LogoutButton />
            ) : (
                <LoginButton />
            ))}
        </header>
    );
}
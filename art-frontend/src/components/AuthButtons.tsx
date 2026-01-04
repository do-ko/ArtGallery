import {useAuth} from "../auth/AuthContext.tsx";
import './Button.css'

export function AuthButtons() {
    const {login, logout, isAuthenticated } = useAuth();

    if (!isAuthenticated()) return (
        <button className={"primary-btn auth-btn-position"}
                onClick={login}>
            Log in
        </button>);

    return (<button className={"primary-btn auth-btn-position"}
                    onClick={logout}>
        Log out
    </button>);
}

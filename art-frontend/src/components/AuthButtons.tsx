import {useEffect, useState} from "react";
import {getSession, signOut} from "../auth/cognito";
import {useNavigate} from "react-router-dom";

export function AuthButtons() {
    const [signedIn, setSignedIn] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        getSession().then(() => setSignedIn(true)).catch(() => setSignedIn(false));
    }, []);

    if (!signedIn) return (
        <button className={"auth-btn"}
                onClick={() => navigate("/login")}>
            Log in
        </button>);

    return (<button className={"auth-btn"}
                    onClick={() => {
                        signOut();
                        location.reload();
                    }}>
        Log out
    </button>);
}

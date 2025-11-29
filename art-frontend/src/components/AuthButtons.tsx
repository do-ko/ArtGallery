import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext.tsx";
import './Button.css'

export function AuthButtons() {
    const [signedIn, setSignedIn] = useState(false);
    const navigate = useNavigate();
    const {signOut, getSession} = useAuth();

    useEffect(() => {
        if (import.meta.env.MODE !== 'production') {
            setSignedIn(false);
            return;
        }

        getSession()
            .then((session) => {
                if (session.isValid()) {
                    setSignedIn(true);
                } else {
                    signOut();
                    setSignedIn(false);
                }
            })
            .catch(() => {
                signOut();
                setSignedIn(false);
            });
    }, []);

    if (!signedIn) return (
        <button className={"primary-btn auth-btn-position"}
                onClick={() => navigate("/login")}>
            Log in
        </button>);

    return (<button className={"primary-btn auth-btn-position"}
                    onClick={() => {
                        signOut();
                        setSignedIn(false);
                        navigate("/");
                    }}>
        Log out
    </button>);
}

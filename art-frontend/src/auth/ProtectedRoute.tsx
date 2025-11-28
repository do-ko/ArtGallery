import {Navigate} from "react-router-dom";
import {useAuth} from "./AuthContext.tsx";
import {type JSX, useEffect} from "react";

export default function ProtectedRoute({children}: { children: JSX.Element }) {
    const {getSession, signOut, isLoggedIn, setIsLoggedIn} = useAuth();

    useEffect(() => {
        getSession()
            .then(session => {
                setIsLoggedIn(session.isValid())
                if (!session.isValid()) {
                    signOut()
                }
            })
            .catch(() => {
                signOut()
            })
    }, []);

    if (!isLoggedIn) {
        return <Navigate to="/" replace/>;
    }

    return children;
}

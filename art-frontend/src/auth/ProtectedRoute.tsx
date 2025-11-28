import {Navigate} from "react-router-dom";
import {useAuth} from "./AuthContext.tsx";
import {type JSX, useEffect, useState} from "react";

export default function ProtectedRoute({children}: { children: JSX.Element }) {
    const {getSession} = useAuth();
    const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);

    useEffect(() => {
        getSession()
            .then(session => setIsLoggedIn(session.isValid()))
            .catch(() => setIsLoggedIn(false))
    }, []);

    if (!isLoggedIn) {
        return <Navigate to="/" replace/>;
    }

    return children;
}

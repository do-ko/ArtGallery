import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext.tsx";
import "./AddArtButton.css"

export function AddArtButton() {
    const [signedIn, setSignedIn] = useState(false);
    const navigate = useNavigate();
    const {getSession} = useAuth();

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
                    setSignedIn(false);
                }
            })
            .catch(() => {
                setSignedIn(false);
            });
    }, []);

    if (!signedIn) return;

    return (<button className={"add-art-btn"}
                    onClick={() => {
                        navigate("/addArt");
                    }}>
        Add Art
    </button>);
}
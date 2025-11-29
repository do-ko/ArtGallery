import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext.tsx";
import "./Button.css"

export function AddArtButton() {
    const navigate = useNavigate();
    const {isLoggedIn} = useAuth();
    if (!isLoggedIn) return;

    return (<button className={"secondary-btn art-btn-position"}
                    onClick={() => {
                        navigate("/addArt");
                    }}>
        Add Art
    </button>);
}
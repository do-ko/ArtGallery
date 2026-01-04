import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext.tsx";
import "./Button.css"

export function AddArtButton() {
    const navigate = useNavigate();
    const {isAuthenticated} = useAuth();
    if (!isAuthenticated) return;

    return (<button className={"secondary-btn art-btn-position"}
                    onClick={() => {
                        navigate("/addArt");
                    }}>
        Add Art
    </button>);
}
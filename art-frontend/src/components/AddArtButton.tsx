import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext.tsx";
import "./AddArtButton.css"

export function AddArtButton() {
    const navigate = useNavigate();
    const {isLoggedIn} = useAuth();
    if (!isLoggedIn) return;

    return (<button className={"add-art-btn"}
                    onClick={() => {
                        navigate("/addArt");
                    }}>
        Add Art
    </button>);
}
import {useNavigate} from "react-router-dom";
import {useAuth} from "../auth/AuthContext";
import './Button.css'

export function ProfileButton() {
    const navigate = useNavigate();
    const {isAuthenticated} = useAuth();
    if (!isAuthenticated) return;

    return (<button className={"secondary-btn profile-btn-position"}
                    onClick={() => {
                        navigate("/profile");
                    }}>
        Profile
    </button>);
}

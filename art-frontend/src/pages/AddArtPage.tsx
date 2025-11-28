import HeaderBar from "../components/HeaderBar.tsx";
import {useState} from "react";
import "./AddArtPage.css";
import {addArtwork} from "../api/artApi.ts";
import {useAuth} from "../auth/AuthContext.tsx";
import {useNavigate} from "react-router-dom";

export default function AddArtPage() {
    const navigate = useNavigate();
    const {getAuthHeader} = useAuth();

    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [type, setType] = useState("PAINTING");
    const [loading, setLoading] = useState(false);

    const artTypes = [
        "PAINTING",
        "DRAWING",
        "PHOTOGRAPHY",
        "DIGITAL_ART",
        "SCULPTURE",
        "COLLAGE",
        "PRINTMAKING",
        "MIXED_MEDIA",
        "INSTALLATION",
        "STREET_ART",
        "CRAFT",
        "ILLUSTRATION",
        "GRAPHIC_DESIGN",
        "CONCEPT_ART",
        "CALLIGRAPHY",
        "ANIMATION_FRAME",
        "OTHER",
    ];

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        setLoading(true);
        try {
            const authHeader = await getAuthHeader();
            await addArtwork(authHeader, title, description, type);
            navigate("/");
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    return (<div className="addArtContainer">
        <HeaderBar/>

        <h1 className="addArtTitle">Add New Artwork</h1>

        <form className="addArtForm" onSubmit={handleSubmit}>
            <label>
                Title:
                <input
                    type="text"
                    value={title}
                    required
                    maxLength={255}
                    onChange={(e) => setTitle(e.target.value)}
                />
            </label>

            <label>
                Description:
                <textarea
                    value={description}
                    maxLength={1000}
                    onChange={(e) => setDescription(e.target.value)}
                />
            </label>

            <label>
                Art Type:
                <select value={type} onChange={(e) => setType(e.target.value)}>
                    {artTypes.map((t) => (
                        <option key={t} value={t}>
                            {t}
                        </option>
                    ))}
                </select>
            </label>

            <button type="submit" className="addArtSubmitBtn" disabled={loading}>
                {loading ? <div className="spinner"></div> : "Add Artwork"}
            </button>
        </form>
    </div>)
}
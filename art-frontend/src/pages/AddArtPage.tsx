import HeaderBar from "../components/HeaderBar.tsx";
import {useState} from "react";
import "./AddArtPage.css";
import {addArtwork, addArtworkImage} from "../api/artApi.ts";
import {useNavigate} from "react-router-dom";

export default function AddArtPage() {
    const navigate = useNavigate();
    // const {getAuthHeader} = useAuth();

    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [type, setType] = useState("PAINTING");
    const [loading, setLoading] = useState(false);
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);
    const [file, setFile] = useState<File | null>(null);

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

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const f = e.target.files?.[0] || null;
        setFile(f);
        setPreviewUrl(f ? URL.createObjectURL(f) : null);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!file) {
            alert("Please select an image.");
            return;
        }

        setLoading(true);
        try {
            const presignedUrl = await addArtworkImage("authHeader", file.name, file?.type)

            await fetch(presignedUrl.uploadUrl, {
                method: "PUT",
                body: file,
                headers: {"Content-Type": file.type},
            });

            console.log(presignedUrl.imageUrl)

            await addArtwork("authHeader", title, description, type, presignedUrl.imageUrl);
            navigate("/");
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="addArtContainer">
            <HeaderBar/>

            <h1 className="addArtTitle">Add New Artwork</h1>

            <form className="addArtForm" onSubmit={handleSubmit}>
                <div className="formAndPreview">
                    <div className="formFields">

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
                                    <option key={t} value={t}>{t}</option>
                                ))}
                            </select>
                        </label>

                        <label>
                            Artwork Image:
                            <input type="file" required accept="image/*" onChange={handleFileChange}/>
                        </label>
                    </div>

                    <div className="imagePreviewBox">
                        {previewUrl ? (
                            <img src={previewUrl} alt="preview" className="imagePreview"/>
                        ) : (
                            <div className="imagePreview placeholder">No image selected</div>
                        )}
                    </div>
                </div>

                <button type="submit" className="addArtSubmitBtn" disabled={loading}>
                    {loading ? <div className="spinner"></div> : "Add Artwork"}
                </button>
            </form>
        </div>
    )
}
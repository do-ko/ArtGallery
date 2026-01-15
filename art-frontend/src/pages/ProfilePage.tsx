import {useEffect, useState} from "react";
import HeaderBar from "../components/HeaderBar";
import "./ProfilePage.css";
import {useNavigate} from "react-router-dom";
import type {Artist} from "../types/artist";
import {getProfile} from "../api/artistApi.ts";
import EditIcon from "@mui/icons-material/Edit";
import CheckIcon from "@mui/icons-material/Check";
import CloseIcon from "@mui/icons-material/Close";
import {useAuth} from "../auth/AuthContext.tsx";

export default function ProfilePage() {
    const [artist, setArtist] = useState<Artist | null>(null);
    const [loading, setLoading] = useState(true);

    const [editing, setEditing] = useState(false);
    const [newDisplayName, setNewDisplayName] = useState("");

    const {getAuthHeader} = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        (async () => {
            try {
                const authHeader = getAuthHeader();
                const response = await getProfile(authHeader);
                setArtist(response);
                setNewDisplayName(response.displayName ?? "");
            } catch (err) {
                console.error(err);
                navigate("/");
            } finally {
                setLoading(false);
            }
        })();
    }, []);

    if (loading) {
        return (
            <div className="profile-loading">
                <div className="spinner"></div>
            </div>
        );
    }

    if (!artist) {
        return <div className="profile-error">Failed to load profile.</div>;
    }

    return (
        <div className="profile-container">
            <HeaderBar/>

            <div className="profile-card">
                <div className="profile-header">

                    <div className="avatar">
                        {artist.displayName?.[0] ?? "?"}
                    </div>

                    <div className="profile-info">
                        <div className="name-row">
                            {editing ? (
                                <>
                                    <input
                                        type="text"
                                        value={newDisplayName}
                                        className="edit-input"
                                        onChange={(e) => setNewDisplayName(e.target.value)}
                                    />
                                    <button
                                        className="save-btn"
                                        onClick={() => {
                                            setArtist({
                                                ...artist,
                                                displayName: newDisplayName
                                            });
                                            setEditing(false);
                                        }}>
                                        <CheckIcon/>
                                    </button>
                                    <button className="cancel-btn" onClick={() => setEditing(false)}>
                                        <CloseIcon/>
                                    </button>
                                </>
                            ) : (
                                <>
                                    <h2>{artist.displayName || "Display name not set"}</h2>
                                    <button className="edit-icon" onClick={() => setEditing(true)}>
                                        <EditIcon/>
                                    </button>
                                </>
                            )}
                        </div>

                        <p className="count">{artist.artworkIds.length} artworks uploaded</p>
                    </div>
                </div>

                <div className="artworks-box">
                    <h3>Your Artworks</h3>
                    {/* LISTA ARTÓW (na razie Placeholder) */}
                    <div className="artworks-placeholder">
                        No artworks yet (API coming soon)
                    </div>
                </div>
            </div>
        </div>
    );
}

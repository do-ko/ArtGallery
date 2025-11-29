import type {Art} from "../types/art";
import NoPhotographyIcon from "@mui/icons-material/NoPhotography";

type ArtCardProps = { art: Art };

export default function ArtCard({art}: ArtCardProps) {
    const hasImage = Boolean(art.imageUrl);

    return (
        <article className="art-card" title={art.title}>

            {hasImage ? (
                <img
                    src={art.imageUrl}
                    alt={art.title}
                    className="art-image"
                />
            ) : (
                <div className="art-placeholder">
                    <NoPhotographyIcon style={{ fontSize: 48, opacity: 0.6 }} />
                </div>
            )}

            <div className="art-overlay">
                <span className="art-title">{art.title}</span>
            </div>
        </article>
    );
}
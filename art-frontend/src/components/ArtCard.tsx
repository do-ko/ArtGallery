import type {Art} from "../types/art";

type ArtCardProps = { art: Art };

export default function ArtCard({art}: ArtCardProps) {
    return (
        <article className="art-card" title={art.title}>
            <div className="art-card-content">
                <span className="art-title">{art.title}</span>
            </div>
        </article>
    );
}
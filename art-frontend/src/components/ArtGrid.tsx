import ArtCard from "./ArtCard";
import type {Art} from "../types/art";

type ArtGridProps = {
    items: Art[];
    loading?: boolean;
};

export default function ArtGrid({items, loading}: ArtGridProps) {
    return (
        <main className="gallery-grid">
            {loading && items.length === 0 ? (
                <div className="loading">Searching…</div>
            ) : (
                items.map((a) => <ArtCard key={a.id} art={a}/>)
            )}
        </main>
    );
}
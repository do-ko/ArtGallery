import { useEffect, useState } from "react";
import { getArtworks } from "../api/artApi";
import type {Art} from "../types/art.ts";
import type {Page} from "../types/page.ts";
import "./Gallery.css";

export default function Gallery() {
    const [page, setPage] = useState<Page<Art>>({
        content: [],
        number: 0,
        size: 10,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        numberOfElements: 0,
        empty: true,
    });

    useEffect(() => {
        getArtworks('', 0, page.size).then(setPage);
    }, []);

    const next = () => !page.last && getArtworks('', page.number + 1, page.size).then(setPage);
    const prev = () => !page.first && getArtworks('', page.number - 1, page.size).then(setPage);

    return (
        <div className="gallery-root">
            <header className="gallery-header">🎨 Art Gallery</header>

            <main className="gallery-grid">
                {page.content.map((art) => (
                    <article key={art.id} className="art-card" title={art.title}>
                        <div className="art-card-content">
                            <span className="art-title">{art.title}</span>
                        </div>
                    </article>
                ))}
            </main>

            <footer className="gallery-footer">
                <button onClick={prev} disabled={page.first}>Prev</button>
                <span>Page {page.number + 1} / {Math.max(page.totalPages, 1)}</span>
                <button onClick={next} disabled={page.last}>Next</button>
            </footer>
        </div>
    );
}

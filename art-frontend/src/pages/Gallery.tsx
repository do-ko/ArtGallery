import {useEffect, useState} from "react";
import {getArtworks} from "../api/artApi";
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

    const [title, setTitle] = useState("");
    const [loading, setLoading] = useState(false);
    const debouncedQuery = useDebounce(title, 300);

    useEffect(() => {
        setLoading(true);
        getArtworks(title, 0, page.size)
            .then(setPage)
            .finally(() => setLoading(false));
    }, [debouncedQuery]);

    const next = () => !page.last && getArtworks(title, page.number + 1, page.size).then(setPage);
    const prev = () => !page.first && getArtworks(title, page.number - 1, page.size).then(setPage);

    return (
        <div className="gallery-root">
            <header className="gallery-header">🎨 Art Gallery</header>

            <div className="gallery-search">
                <label htmlFor="art-search" className="sr-only">Search artworks</label>
                <input
                    id="art-search"
                    className="search-input"
                    type="text"
                    placeholder="Search by title…"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                />
            </div>


            <main className="gallery-grid">
                {loading && page.content.length === 0 ? (
                    <div className="loading">Searching…</div>
                ) : (
                    page.content.map((art) => (
                        <article key={art.id} className="art-card" title={art.title}>
                            <div className="art-card-content">
                                <span className="art-title">{art.title}</span>
                            </div>
                        </article>
                    ))
                )}
            </main>

            <footer className="gallery-footer">
                <button onClick={prev} disabled={page.first}>Prev</button>
                <span>Page {page.number + 1} / {Math.max(page.totalPages, 1)}</span>
                <button onClick={next} disabled={page.last}>Next</button>
            </footer>
        </div>
    );
}

function useDebounce<T>(value: T, delay = 300): T {
    const [v, setV] = useState(value);
    useEffect(() => {
        const id = setTimeout(() => setV(value), delay);
        return () => clearTimeout(id);
    }, [value, delay]);
    return v;
}

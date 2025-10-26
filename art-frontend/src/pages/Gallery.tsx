import {useEffect, useState} from "react";
import {getArtworks} from "../api/artApi";
import type {Art} from "../types/art";
import type {Page} from "../types/page";
import {useDebounce} from "../hooks/useDebounce";

import HeaderBar from "../components/HeaderBar";
import SearchBar from "../components/SearchBar";
import ArtGrid from "../components/ArtGrid";
import Pagination from "../components/Pagination";

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
    const debouncedTitle = useDebounce(title, 300);

    useEffect(() => {
        setLoading(true);
        getArtworks(debouncedTitle, 0, page.size)
            .then(setPage)
            .finally(() => setLoading(false));
    }, [debouncedTitle]);

    const next = () =>
        !page.last && getArtworks(debouncedTitle, page.number + 1, page.size).then(setPage);
    const prev = () =>
        !page.first && getArtworks(debouncedTitle, page.number - 1, page.size).then(setPage);

    return (
        <div className="gallery-root">
            <HeaderBar/>

            <SearchBar value={title} onChange={setTitle}/>

            <ArtGrid items={page.content} loading={loading}/>

            <Pagination
                page={page.number}
                totalPages={page.totalPages}
                first={page.first}
                last={page.last}
                onPrev={prev}
                onNext={next}
            />
        </div>
    );
}
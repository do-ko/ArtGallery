type PaginationProps = {
    page: number;
    totalPages: number;
    first: boolean;
    last: boolean;
    onPrev: () => void;
    onNext: () => void;
};

export default function Pagination({page, totalPages, first, last, onPrev, onNext}: PaginationProps) {
    return (
        <footer className="gallery-footer">
            <button onClick={onPrev} disabled={first}>Prev</button>
            <span>Page {page + 1} / {Math.max(totalPages, 1)}</span>
            <button onClick={onNext} disabled={last}>Next</button>
        </footer>
    );
}
type SearchBarProps = {
    value: string;
    onChange: (v: string) => void;
    placeholder?: string;
};

export default function SearchBar({value, onChange, placeholder}: SearchBarProps) {
    return (
        <div className="gallery-search">
            <label htmlFor="art-search" className="sr-only">Search artworks</label>
            <input
                id="art-search"
                className="search-input"
                type="text"
                placeholder={placeholder ?? "Search by title…"}
                value={value}
                onChange={(e) => onChange(e.target.value)}
            />
        </div>
    );
}
type HeaderBarProps = {
    onLogin?: () => void;
};

export default function HeaderBar({onLogin}: HeaderBarProps) {
    return (
        <header className="gallery-header">
            <h1 className="gallery-title">🎨 Art Gallery</h1>
            <button className="login-btn" onClick={onLogin}>Log In</button>
        </header>
    );
}
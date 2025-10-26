import LoginButton from "./LoginButton.tsx";


export default function HeaderBar() {
    return (
        <header className="gallery-header">
            <h1 className="gallery-title">🎨 Art Gallery</h1>
            <LoginButton/>
        </header>
    );
}
import {AuthButtons} from "./AuthButtons.tsx";
import {AddArtButton} from "./AddArtButton.tsx";


export default function HeaderBar() {
    return (
        <header className="gallery-header">
            <h1 className="gallery-title">🎨 Art Gallery</h1>

            <AddArtButton />
            <AuthButtons />
        </header>
    );
}
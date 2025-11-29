import {AuthButtons} from "./AuthButtons.tsx";
import {AddArtButton} from "./AddArtButton.tsx";
import {ProfileButton} from "./ProfileButton.tsx";


export default function HeaderBar() {
    return (
        <header className="gallery-header">
            <h1 className="gallery-title">🎨 Art Gallery</h1>

            <AddArtButton/>
            <ProfileButton />
            <AuthButtons/>
        </header>
    );
}
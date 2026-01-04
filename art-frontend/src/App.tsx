import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Gallery from "./pages/Gallery.tsx";
import {AuthProvider} from "./auth/AuthContext.tsx";
import AddArtPage from "./pages/AddArtPage.tsx";
import ProtectedRoute from "./auth/ProtectedRoute.tsx";
import ProfilePage from "./pages/ProfilePage.tsx";
import AuthCallback from "./auth/AuthCallback.tsx";

function App() {

    return (
        <AuthProvider>
            <BrowserRouter>
                <Routes>
                    <Route path="/" element={<Gallery/>}/>
                    <Route path="/addart" element={
                        <ProtectedRoute>
                            <AddArtPage/>
                        </ProtectedRoute>
                    }/>
                    <Route path="/profile" element={
                        <ProtectedRoute>
                            <ProfilePage/>
                        </ProtectedRoute>
                    }/>
                    <Route path="/auth/callback" element={<AuthCallback/>}/>
                </Routes>
            </BrowserRouter>
        </AuthProvider>
    )
}

export default App

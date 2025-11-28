import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Gallery from "./pages/Gallery.tsx";
import LoginPage from "./pages/LoginPage.tsx";
import SignUpPage from "./pages/SignUpPage.tsx";
import {AuthProvider} from "./auth/AuthContext.tsx";
import AddArtPage from "./pages/AddArtPage.tsx";
import ProtectedRoute from "./auth/ProtectedRoute.tsx";

function App() {

    return (
        <AuthProvider>
            <BrowserRouter>
                <Routes>
                    <Route path="/" element={<Gallery/>}/>
                    <Route path="/login" element={<LoginPage/>}/>
                    <Route path="/signup" element={<SignUpPage/>}/>
                    <Route path="/addart" element={
                        <ProtectedRoute>
                            <AddArtPage/>
                        </ProtectedRoute>
                    }/>
                </Routes>
            </BrowserRouter>
        </AuthProvider>
    )
}

export default App

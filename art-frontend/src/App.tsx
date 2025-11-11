import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Gallery from "./pages/Gallery.tsx";
import LoginForm from "./pages/LoginPage.tsx";


function App() {

    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Gallery/>}/>
                <Route path="/login" element={<LoginForm/>}/>
            </Routes>
        </BrowserRouter>
    )
}

export default App

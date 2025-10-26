import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Gallery from "./pages/Gallery.tsx";

function App() {

  return (
      <BrowserRouter>
          <Routes>
              <Route path="/" element={<Gallery />} />
              <Route path="/login/callback" element={<Gallery />} />
          </Routes>
      </BrowserRouter>
  )
}

export default App

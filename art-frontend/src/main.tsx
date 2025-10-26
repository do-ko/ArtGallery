import {StrictMode} from 'react'
import {createRoot} from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import {AuthProvider} from "react-oidc-context";

const cognitoAuthConfig = {
    authority: "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_8DYC9NF4Z",
    client_id: "30hsrvna5p8ll22630qsjhk4sr",
    redirect_uri: "http://localhost:5173/login/callback",
    response_type: "code",
    scope: "phone openid email",
};

createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <AuthProvider {...cognitoAuthConfig}>
            <App/>
        </AuthProvider>
    </StrictMode>,
)

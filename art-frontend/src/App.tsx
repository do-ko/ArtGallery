import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Gallery from "./pages/Gallery.tsx";
import {AuthProvider} from "react-oidc-context";
import { APP_CONFIG, isCognitoEnabled } from "./types/config.ts";

function App() {

    const oidcConfig = isCognitoEnabled ? {
        authority: APP_CONFIG.COGNITO_ISSUER_URI,
        client_id: APP_CONFIG.COGNITO_CLIENT_ID,
        redirect_uri: APP_CONFIG.REDIRECT_URI,
        post_logout_redirect_uri: APP_CONFIG.LOGOUT_URI,
        response_type: "code",
        scope: "openid email profile",
        metadata: {
            authorization_endpoint: `${APP_CONFIG.COGNITO_DOMAIN_BASE}/oauth2/authorize`,
            token_endpoint:         `${APP_CONFIG.COGNITO_DOMAIN_BASE}/oauth2/token`,
            userinfo_endpoint:      `${APP_CONFIG.COGNITO_DOMAIN_BASE}/oauth2/userInfo`,
            end_session_endpoint:   `${APP_CONFIG.COGNITO_DOMAIN_BASE}/logout`,
            issuer:                 APP_CONFIG.COGNITO_ISSUER_URI,
        },
        onSigninCallback: () => {
            window.history.replaceState({}, document.title, window.location.pathname);
        },
        automaticSilentRenew: false,
    } : undefined;

  return (
      <BrowserRouter>
          {isCognitoEnabled ? (
              <AuthProvider {...oidcConfig!}>
                  <Routes>
                      <Route path="/" element={<Gallery />} />
                      <Route path="/auth/callback" element={<Gallery />} />
                  </Routes>
              </AuthProvider>
          ) : (
              <Routes>
                  <Route path="/" element={<Gallery />} />
              </Routes>
          )}
      </BrowserRouter>
  )
}

export default App

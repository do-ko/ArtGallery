declare global {
    interface Window { __APP_CONFIG__?: Record<string, string>; }
}
export const APP_CONFIG = window.__APP_CONFIG__ ?? {};

export const isCognitoEnabled =
    !!APP_CONFIG.COGNITO_CLIENT_ID &&
    !!APP_CONFIG.COGNITO_DOMAIN_BASE &&
    !!APP_CONFIG.COGNITO_ISSUER_URI &&
    !!APP_CONFIG.REDIRECT_URI;
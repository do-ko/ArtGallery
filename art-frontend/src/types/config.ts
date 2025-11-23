declare global {
    interface Window { __APP_CONFIG__?: Record<string, string>; }
}
export const APP_CONFIG = window.__APP_CONFIG__ ?? {};
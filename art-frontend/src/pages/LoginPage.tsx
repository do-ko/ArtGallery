import { useEffect, useMemo, useState } from "react";
import {
    signIn,
    completeNewPassword,
    getCurrentUser,
} from "../auth/cognito.ts";
import "./LoginPage.css";

type Mode = "login" | "new_password";

export default function LoginPage() {
    const [mode, setMode] = useState<Mode>("login");
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [pending, setPending] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [showPwd, setShowPwd] = useState(false);

    const canSubmit = useMemo(() => {
        if (mode === "login") return username.trim().length > 0 && password.length > 0;
        return password.length >= 8;
    }, [mode, username, password]);

    useEffect(() => {
        setError(null);
    }, [username, password, mode]);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        if (!canSubmit || pending) return;

        setPending(true);
        try {
            if (mode === "login") {
                const res = await signIn(username.trim(), password);
                if (res === "NEW_PASSWORD_REQUIRED") {
                    setPassword("");
                    setMode("new_password");
                } else {
                    window.location.replace("/");
                }
            } else {
                const user = getCurrentUser();
                if (!user) throw new Error("Brak zalogowanego użytkownika do ustawienia nowego hasła.");
                await completeNewPassword(user, password);
                window.location.replace("/");
            }
        } catch (err: any) {
            setError(err?.message || "Coś poszło nie tak. Spróbuj ponownie.");
        } finally {
            setPending(false);
        }
    }

    return (
        <div className="login-wrap">
            <div className="bg-gradient" />
            <div className="card">
                <div className="brand">
                    <div className="logo">🎨</div>
                    <div>
                        <h1>Art Gallery</h1>
                        <p className="muted">{mode === "login" ? "Zaloguj się do swojego konta" : "Ustaw nowe hasło"}</p>
                    </div>
                </div>

                <form onSubmit={handleSubmit} className="form">
                    {mode === "login" && (
                        <div className="field">
                            <label htmlFor="username">E-mail lub nazwa użytkownika</label>
                            <input
                                id="username"
                                type="text"
                                autoComplete="username"
                                placeholder="you@example.com"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                disabled={pending}
                            />
                        </div>
                    )}

                    <div className="field">
                        <label htmlFor="password">{mode === "login" ? "Hasło" : "Nowe hasło"}</label>
                        <div className="password-box">
                            <input
                                id="password"
                                type={showPwd ? "text" : "password"}
                                autoComplete={mode === "login" ? "current-password" : "new-password"}
                                placeholder={mode === "login" ? "••••••••" : "min. 8 znaków"}
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                disabled={pending}
                            />
                            <button
                                type="button"
                                className="icon-btn"
                                onClick={() => setShowPwd((s) => !s)}
                                aria-label={showPwd ? "Ukryj hasło" : "Pokaż hasło"}
                                disabled={pending}
                            >
                                {showPwd ? "🙈" : "👁️"}
                            </button>
                        </div>
                    </div>

                    {error && <div className="error">{error}</div>}

                    <button className="primary" disabled={!canSubmit || pending}>
                        {pending ? "Przetwarzanie…" : mode === "login" ? "Zaloguj się" : "Zapisz hasło"}
                    </button>

                    {mode === "login" && (
                        <div className="row small">
                            <a href="#" onClick={(e) => e.preventDefault()} className="link-disabled">
                                Zapomniałam/em hasła?
                            </a>
                            <span className="dot">•</span>
                            <a href="#" onClick={(e) => e.preventDefault()} className="link-disabled">
                                Utwórz konto
                            </a>
                        </div>
                    )}
                </form>

                <div className="footer">
                    <a href="/" className="ghost">← Wróć do galerii</a>
                </div>
            </div>
        </div>
    );
}

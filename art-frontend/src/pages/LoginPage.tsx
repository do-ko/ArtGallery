import {useEffect, useMemo, useState} from "react";
import "./LoginPage.css";
import {useNavigate} from "react-router-dom";
import {ConfirmEmailForm} from "../components/ConfirmEmailForm";
import {useAuth} from "../auth/AuthContext.tsx";

export default function LoginPage() {
    const navigate = useNavigate();
    const [mode, setMode] = useState<"login" | "new_password" | "confirm">("login");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [pending, setPending] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [showPwd, setShowPwd] = useState(false);
    const {signIn, setIsLoggedIn} = useAuth();

    const canSubmit = useMemo(() => {
        if (mode === "login") return email.trim().length > 0 && password.length > 0;
        return password.length >= 8;
    }, [mode, email, password]);

    useEffect(() => {
        setError(null);
    }, [email, password, mode]);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        if (!canSubmit || pending) return;

        setPending(true);

        if (import.meta.env.MODE !== "production") {
            console.log("Cognito disabled (dev mode). Mock login success.");
            navigate("/")
            return;
        }

        if (mode === "login") {
            signIn(email, password)
                .then(async () => {
                    setIsLoggedIn(true)
                    // const authHeader = await getAuthHeader();
                    // await handleFirstLogin(authHeader)
                    navigate("/")
                })
                .catch((err) => {
                    console.error("Failed to log in:", err)
                    if (err.code === "UserNotConfirmedException") {
                        setMode("confirm");
                    }
                })
                .finally(() => {
                    setPending(false);
                });
        }
    }

    return (
        <div className="login-wrap">
            <div className="bg-gradient"/>
            <div className="card">
                <div className="brand">
                    <div className="logo">🎨</div>
                    <div>
                        <h1>Art Gallery</h1>
                        <p className="muted">{mode === "login" ? "Zaloguj się do swojego konta" : "Ustaw nowe hasło"}</p>
                    </div>
                </div>

                {mode === "confirm" ? (
                    <ConfirmEmailForm email={email}/>
                ) : (
                    <form onSubmit={handleSubmit} className="form">
                        {mode === "login" && (
                            <div className="field">
                                <label htmlFor="username">E-mail</label>
                                <input
                                    id="username"
                                    type="text"
                                    autoComplete="email"
                                    placeholder="you@example.com"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
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
                                <a href={"/"} onClick={() => navigate("/")}>
                                    Wróć do galerii
                                </a>
                                <span className="dot">•</span>
                                <a href="#" onClick={(e) => e.preventDefault()}
                                   className="link-disabled">
                                    Zapomniałam/em hasła?
                                </a>
                                <span className="dot">•</span>
                                <a href="/signup" onClick={() => navigate("/signup")}>
                                    Utwórz konto
                                </a>
                            </div>
                        )}
                    </form>
                )}
            </div>
        </div>

    );
}

import {useMemo, useState} from "react";
import "./LoginPage.css";
import {useNavigate} from "react-router-dom";
import {ConfirmEmailForm} from "../components/ConfirmEmailForm";
import {useAuth} from "../auth/AuthContext.tsx";

function usePasswordStrength(pwd: string) {
    let score = 0;
    if (pwd.length >= 12) score++;
    if (/[A-Z]/.test(pwd)) score++;
    if (/[a-z]/.test(pwd)) score++;
    if (/\d/.test(pwd)) score++;
    if (/[^A-Za-z0-9]/.test(pwd)) score++;
    return Math.min(score, 5);
}

export default function SignUpPage() {
    const navigate = useNavigate();

    const [email, setEmail] = useState("");
    const [pwd, setPwd] = useState("");
    const [pwd2, setPwd2] = useState("");
    const [showPwd, setShowPwd] = useState(false);

    const [step, setStep] = useState<"form" | "confirm">("form");
    const [pending, setPending] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);
    const {signUp} = useAuth();

    const strength = usePasswordStrength(pwd);
    const pwdMatch = pwd && pwd === pwd2;

    const passwordErrors = useMemo(() => {
        const errors: string[] = [];
        if (pwd.length < 12) errors.push("Min. 12 znaków");
        if (!/[A-Z]/.test(pwd)) errors.push("Wielka litera");
        if (!/[a-z]/.test(pwd)) errors.push("Mała litera");
        if (!/\d/.test(pwd)) errors.push("Cyfra");
        if (!/[^A-Za-z0-9]/.test(pwd)) errors.push("Symbol");
        return errors;
    }, [pwd]);

    const canSubmit = useMemo(() => {
        return (
            email.trim().length > 3 &&
            passwordErrors.length == 0 &&
            pwdMatch &&
            !pending
        );
    }, [email, passwordErrors, pwdMatch, pending]);

    async function onSubmit(e: React.FormEvent) {
        e.preventDefault();
        if (!canSubmit) return;
        setPending(true);
        setError(null);
        setMessage(null);

        if (import.meta.env.MODE !== "production") {
            console.log("Cognito disabled (dev mode). Mock signup success.");
            setMessage("Mock: konto utworzone (dev mode).");
            setStep("confirm");
            setPending(false);
            return;
        }

        signUp(email.trim(), pwd)
            .then(() => {
                setStep("confirm");
                setMessage("Wysłaliśmy kod potwierdzający na e-mail.");
            })
            .catch((err) => {
                if (err.code === "UserNotConfirmedException") {
                    setStep("confirm");
                } else {
                    setError(err?.message || "Rejestracja nie powiodła się.");
                }
            }).finally(() => {
            setPending(false);
        });
    }

    return (
        <div className="login-wrap">
            <div className="bg-gradient"/>
            <div className="card">
                <div className="brand">
                    <div className="logo">🎨</div>
                    <div>
                        <h1>Art Gallery</h1>
                        <p className="muted">{step === "form" ? "Utwórz konto" : "Potwierdź e-mail"}</p>
                    </div>
                </div>

                {step === "form" ? (
                    <form className="form" onSubmit={onSubmit}>
                        <div className="field">
                            <label htmlFor="email">E-mail</label>
                            <input
                                id="email"
                                type="email"
                                placeholder="you@example.com"
                                value={email}
                                onChange={e => setEmail(e.target.value)}
                                disabled={pending}
                                autoComplete="email"
                            />
                        </div>

                        <div className="field">
                            <label htmlFor="pwd">Hasło</label>
                            <div className="password-box">
                                <input
                                    id="pwd"
                                    type={showPwd ? "text" : "password"}
                                    placeholder="min. 12 znaków, duża/mała litera, cyfra, symbol"
                                    value={pwd}
                                    onChange={e => setPwd(e.target.value)}
                                    disabled={pending}
                                    autoComplete="new-password"
                                />
                                <button
                                    type="button"
                                    className="icon-btn"
                                    onClick={() => setShowPwd(s => !s)}
                                    aria-label="Pokaż/ukryj hasło"
                                    disabled={pending}
                                >
                                    {showPwd ? "🙈" : "👁️"}
                                </button>
                            </div>
                            <PasswordMeter strength={strength}/>
                        </div>

                        {pwd.length > 0 && passwordErrors.length != 0 && (
                            <ul className="muted small" style={{marginTop: 8}}>
                                {passwordErrors.map((e, i) => (
                                    <li key={i} style={{opacity: passwordErrors.includes(e) ? 1 : 0.5}}>
                                        {e}
                                    </li>
                                ))}
                            </ul>
                        )}

                        <div className="field">
                            <label htmlFor="pwd2">Powtórz hasło</label>
                            <input
                                id="pwd2"
                                type={showPwd ? "text" : "password"}
                                placeholder="Powtórz hasło"
                                value={pwd2}
                                onChange={e => setPwd2(e.target.value)}
                                disabled={pending}
                                autoComplete="new-password"
                            />
                            {!pwdMatch && pwd2.length > 0 && (
                                <div className="muted">Hasła się różnią</div>
                            )}
                        </div>

                        {error && <div className="error">{error}</div>}
                        {message && <div className="error" style={{
                            borderColor: "rgba(34,197,94,0.35)",
                            color: "#86efac",
                            background: "rgba(34,197,94,0.15)"
                        }}>{message}</div>}

                        <button className="primary" disabled={!canSubmit}>
                            {pending ? "Rejestruję…" : "Zarejestruj się"}
                        </button>

                        <div className="row small">
                            <a href={"/"} onClick={() => navigate("/")}>
                                Wróć do galerii
                            </a>
                            <span className="dot">•</span>
                            <a href={"/login"} onClick={() => navigate("/login")}>
                                Zaloguj się
                            </a>
                        </div>

                    </form>
                ) : (
                    <ConfirmEmailForm email={email}/>
                )}
            </div>
        </div>
    );
}

function PasswordMeter({strength}: { strength: number }) {
    const labels = ["bardzo słabe", "słabe", "średnie", "dobre", "bardzo dobre"];
    const pct = (strength / 5) * 100;
    return (
        <div>
            <div style={{
                height: 8,
                borderRadius: 6,
                background: "rgba(255,255,255,0.08)",
                border: "1px solid rgba(255,255,255,0.12)"
            }}>
                <div style={{
                    width: `${pct}%`,
                    height: "100%",
                    borderRadius: 6,
                    background: "linear-gradient(90deg,#f43f5e,#f59e0b,#22c55e)"
                }}/>
            </div>
            <div className="muted" style={{fontSize: 12, marginTop: 6}}>
                Siła hasła: {labels[Math.max(0, strength - 1)] || "—"}
            </div>
        </div>
    );
}

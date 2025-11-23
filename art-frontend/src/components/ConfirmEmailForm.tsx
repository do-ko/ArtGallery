import {useState} from "react";
import {useAuth} from "../auth/AuthContext.tsx";

export function ConfirmEmailForm({
                                     email,
                                 }: {
    email: string;
}) {
    const [code, setCode] = useState("");
    const [pending, setPending] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);
    const {confirmSignUp, resendConfirmationCode} = useAuth();

    async function onConfirm(e: React.FormEvent) {
        e.preventDefault();
        if (!code) return;
        setPending(true);
        setError(null);
        setMessage(null);

        if (import.meta.env.MODE !== "production") {
            console.log("Cognito disabled (dev mode). Mock confirmation success.");
            setMessage("Mock: konto potwierdzone (dev mode).");
            setPending(false);
            return;
        }

        confirmSignUp(email.trim(), code.trim())
            .then(() => {
                setMessage("Konto potwierdzone! Możesz się teraz zalogować.");
            })
            .catch((err) => {
                setError(err?.message || "Błędny kod lub już potwierdzone.");
            })
            .finally(() => {
                setPending(false);
            });
    }

    async function onResend() {
        setPending(true);
        setError(null);
        setMessage(null);

        if (import.meta.env.MODE !== "production") {
            console.log("Cognito disabled (dev mode). Mock resend code success.");
            setMessage("Mock: kod został wysłany ponownie (dev mode).");
            setPending(false);
            return;
        }


        resendConfirmationCode(email.trim())
            .then(() => {
                setMessage("Kod został wysłany ponownie.");
            })
            .catch((err) => {
                setError(err.message || "Nie udało się wysłać kodu.");
            })
            .finally(() => {
                setPending(false)
            })
    }

    return (
        <form className="form" onSubmit={onConfirm}>
            <div className="field">
                <label>E-mail</label>
                <input type="email" value={email} disabled/>
            </div>
            <div className="field">
                <label htmlFor="code">Kod potwierdzający</label>
                <input
                    id="code"
                    type="text"
                    placeholder="6-cyfrowy kod z e-maila"
                    value={code}
                    onChange={e => setCode(e.target.value)}
                    disabled={pending}
                />
            </div>

            {error && <div className="error">{error}</div>}
            {message && <div className="error" style={{
                borderColor: "rgba(34,197,94,0.35)",
                color: "#86efac",
                background: "rgba(34,197,94,0.15)"
            }}>{message}</div>}

            <div style={{display: "flex", gap: 10}}>
                <button type="submit" className="primary" style={{flex: 1}} disabled={pending || !code}>
                    {pending ? "Sprawdzam…" : "Potwierdź"}
                </button>
                <button type="button" className="ghost" style={{flex: 1}} onClick={onResend}
                        disabled={pending}>
                    Wyślij kod ponownie
                </button>
            </div>

            <div className="row small">
                <a href="/login">Wróć do logowania</a>
            </div>
        </form>
    );
}

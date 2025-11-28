const fetch = require("node-fetch");

exports.handler = async (event) => {
    const email = event.request.userAttributes.email;
    const cognitoSub = event.request.userAttributes.sub;

    try {
        const response = await fetch("http://" + process.env.API_URL + "/internal/artist/first-login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-Internal-Secret": process.env.INTERNAL_SECRET
            },
            body: JSON.stringify({ email, cognitoSub })
        });

        if (!response.ok) {
            console.error("Backend returned error", await response.text());
        } else {
            console.log("User created successfully");
        }
    } catch (err) {
        console.error("Fetch failed", err);
    }

    return event;
};

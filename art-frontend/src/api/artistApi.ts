import axios from "axios";
import {APP_CONFIG} from "../types/config.ts";
import type {Artist} from "../types/artist.ts";

const apiBase = APP_CONFIG.API_BASE ?? "http://localhost:8080/api";

export const getProfile = async (authHeader: string) => {
    const response = await axios.get<Artist>(`${apiBase}/artist/me`,
        {
            headers: {
                Authorization: authHeader
            }
        });
    console.log("response.data: ", response.data)
    return response.data;
};

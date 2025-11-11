import axios from "axios";
import type {Art} from "../types/art.ts";
import type {Page} from "../types/page.ts";
import { APP_CONFIG } from "../types/config.ts";

const apiBase = APP_CONFIG.API_BASE ?? "/api";

export const getArtworks = async (title?: string, page?: number, size?: number) => {
    const response = await axios.get<Page<Art>>(`${apiBase}/art`, {
        params: { title, page, size },
    });
    console.log("response.data: ", response.data)
    return response.data;
};

import axios from "axios";
import type {Art} from "../types/art.ts";
import type {Page} from "../types/page.ts";

const API_BASE = "http://localhost:8080/api";

export const getArtworks = async (title?: string, page?: number, size?: number) => {
    const response = await axios.get<Page<Art>>(`${API_BASE}/art`, {
        params: { title, page, size },
    });
    console.log("response.data: ", response.data)
    return response.data;
};

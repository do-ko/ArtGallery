import axios from "axios";
import type {Art} from "../types/art.ts";
import type {Page} from "../types/page.ts";
import {APP_CONFIG} from "../types/config.ts";
import type {PresignedUrl} from "../types/presignedUrl.ts";

const apiBase = APP_CONFIG.API_BASE ?? "http://localhost:8080/api";

export const getArtworks = async (title?: string, page?: number, size?: number) => {
    const response = await axios.get<Page<Art>>(`${apiBase}/art`, {
        params: {title, page, size},
    });
    console.log("response.data: ", response.data)
    return response.data;
};

export const addArtwork = async (authHeader: string, title: string, description: string, type: string, imageUrl: string) => {
    const response = await axios.post<Art>(`${apiBase}/art`,
        {
            title,
            description,
            type,
            imageUrl
        },
        {
            headers: {
                Authorization: authHeader
            }
        });
    console.log("response.data: ", response.data)
    return response.data;
};

export const addArtworkImage = async (authHeader: string, filename: string, contentType: string) => {
    const response = await axios.post<PresignedUrl>(`${apiBase}/art/url`,
        {
            filename: filename,
            contentType: contentType
        },
        {
            headers: {
                Authorization: authHeader
            }
        }
    )
    console.log("response.data: ", response.data)
    return response.data;
}

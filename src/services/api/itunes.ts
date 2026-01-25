import { get } from './index';

export interface ItunesTrack {
    id: number;
    title: string;
    artist: string;
    album: string;
    artwork: string;
    audio: string;
    url: string;
    date: string;
    previewUrl?: string; // Alias for audio/preview
}

export interface ItunesCollection {
    id: number;
    title: string;
    artist: string;
    artwork: string;
    count: number;
    genre: string;
    date: string;
}

export const itunesService = {
    search: async (term: string) => {
        const response = await get<{ results: any[] }>(`/itunes/search?term=${term}`);
        // Map backend response to interface if needed, or pass through
        return response.results.map(item => ({
            ...item,
            previewUrl: item.audio || item.previewUrl // Ensure previewUrl is populated
        })) as ItunesTrack[];
    },

    getRecommendations: async (genre?: string) => {
        const query = genre ? `?genre=${encodeURIComponent(genre)}` : '';
        const response = await get<{ recommendations: ItunesCollection[] }>(`/itunes/recommendations${query}`);
        return response.recommendations;
    },

    getAlbum: async (id: number) => {
        return get<{ id: number; title: string; artist: string; tracks: ItunesTrack[] }>(`/itunes/album/${id}`);
    }
};

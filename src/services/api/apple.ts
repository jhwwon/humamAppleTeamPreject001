import { get } from './index'

// Apple Music Web API Token (Public Token extracted from Web Player)
// Note: This token might expire. If it does, it needs to be updated from music.apple.com network tab.
const APPLE_MUSIC_TOKEN = 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNzY4NTIxMTkyLCJleHAiOjE3NzU3Nzg3OTIsInJvb3RfaHR0cHNfb3JpZ2luIjpbImFwcGxlLmNvbSJdfQ.iZTD-bdGzofBHTdPBDcuXR8SGhObN6HYWBgYfPteY_457FtNd1xb-V6NZSuJgSyVcOzJh8LEIZWXHDD48UMP6Q'

// Use local proxy to avoid CORS
const BASE_URL = '/apple-proxy'

// Types
export interface AppleMusicItem {
    id: string
    type: 'albums' | 'playlists' | 'songs'
    href: string
    attributes: {
        name: string
        artistName?: string
        artwork?: {
            url: string
            width: number
            height: number
        }
        url: string
        playParams?: {
            id: string
            kind: string
        }
        releaseDate?: string
        trackCount?: number
        editorialNotes?: {
            standard: string
            short: string
        }
        previews?: { url: string }[] // Add previews array
    }
}

export interface AppleMusicGrouping {
    id: string
    type: 'groupings'
    attributes: {
        name: string
        title?: string
    }
    relationships?: {
        tabs?: {
            data: any[]
        }
        grouping?: {
            data: any[]
        }
        contents?: { // Sometimes content is here
             data: AppleMusicItem[]
        }
    }
    views?: { // Often editorial content is in views
        [key: string]: {
            data: AppleMusicItem[]
            attributes?: { title: string }
        }
    }
}

// Custom Fetcher for Apple Music API
const fetchApple = async <T>(endpoint: string): Promise<T> => {
    const url = `${BASE_URL}${endpoint}`
    
    const response = await fetch(url, {
        headers: {
            'Authorization': `Bearer ${APPLE_MUSIC_TOKEN}`,
            'Accept-Language': 'ko-KR'
            // Origin headers are handled by Vite proxy
        }
    })

    if (!response.ok) {
        throw new Error(`Apple Music API Error: ${response.statusText}`)
    }

    return response.json()
}

export const appleMusicApi = {
    // Get New Releases / Browse Data
    getNewReleases: async () => {
        try {
            // User provided URL for 'New Music' grouping
            const data: any = await fetchApple('/editorial/kr/groupings?name=new-music&l=ko&platform=web')
            
            const tabs = data.data?.[0]?.relationships?.tabs?.data || []
            let songs: AppleMusicItem[] = []
            let playlists: AppleMusicItem[] = []
            
            // Extract from editorial content
            for (const tab of tabs) {
                 const children = tab.relationships?.children?.data || []
                 for (const child of children) {
                     if (child.relationships?.contents?.data) {
                         const contents = child.relationships.contents.data
                         
                         const songItems = contents.filter((i: any) => i.type === 'songs')
                         const playlistItems = contents.filter((i: any) => i.type === 'playlists')
                         
                         if (songItems.length > 0) songs = [...songs, ...songItems]
                         if (playlistItems.length > 0) playlists = [...playlists, ...playlistItems]
                     }
                 }
            }
            
            // Fallback to charts if empty
            if (songs.length === 0 || playlists.length === 0) {
                 const chartData: any = await fetchApple('/catalog/kr/charts?types=songs,playlists&limit=20')
                 if (songs.length === 0) songs = chartData.results.songs?.[0]?.data || []
                 if (playlists.length === 0) playlists = chartData.results.playlists?.[0]?.data || []
            }

            return {
                songs: songs.slice(0, 20),
                playlists: playlists.slice(0, 10), // Top 10 Playlists
                albums: [] 
            }
        } catch (e) {
            console.warn('Apple Music fetch failed, trying fallback chart', e)
            try {
                const chartData: any = await fetchApple('/catalog/kr/charts?types=songs,playlists&limit=20')
                return {
                    songs: chartData.results.songs?.[0]?.data || [],
                    playlists: chartData.results.playlists?.[0]?.data || [],
                    albums: []
                }
            } catch (err) {
                console.error('All Apple Music fetches failed', err)
                return { songs: [], playlists: [], albums: [] }
            }
        }
    },

    // Search using the official API (Better than iTunes Search API)
    search: async (term: string) => {
        const termEncoded = encodeURIComponent(term)
        const data: any = await fetchApple(`/catalog/kr/search?term=${termEncoded}&types=artists,albums,playlists,songs&limit=5`)
        return data.results
    },
    
    // Get Playlist/Album Tracks
    getTracks: async (id: string, type: 'albums' | 'playlists') => {
        const data: any = await fetchApple(`/catalog/kr/${type}/${id}/tracks`)
        return data.data
    }
}

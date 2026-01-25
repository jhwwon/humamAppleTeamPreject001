import ReactPlayer from 'react-player'
import { API_BASE_URL } from '../api/index'
import * as TidalAdapter from './TidalPlayerAdapter'

// Audio Source Types
export type AudioSourceType = 'YOUTUBE' | 'FILE' | 'TIDAL' | 'ITUNES_PREVIEW' | 'UNKNOWN'

// Interface for currently playing audio
export interface AudioState {
    isPlaying: boolean
    currentTime: number
    duration: number
    volume: number
    isBuffering: boolean
    sourceType: AudioSourceType
    error: string | null
}

class AudioService {
    private static instance: AudioService
    private player: ReactPlayer | null = null
    public state: AudioState = {
        isPlaying: false,
        currentTime: 0,
        duration: 0,
        volume: 0.7,
        isBuffering: false,
        sourceType: 'UNKNOWN',
        error: null
    }

    // Listeners
    private listeners: ((state: AudioState) => void)[] = []

    private constructor() { }

    public static getInstance(): AudioService {
        if (!AudioService.instance) {
            AudioService.instance = new AudioService()
        }
        return AudioService.instance
    }

    // Set ReactPlayer reference
    public setPlayer(player: ReactPlayer | null) {
        this.player = player
    }

    public subscribe(listener: (state: AudioState) => void) {
        this.listeners.push(listener)
        // Send current state immediately
        listener(this.state)
        return () => {
            this.listeners = this.listeners.filter(l => l !== listener)
        }
    }

    private updateState(updates: Partial<AudioState>) {
        this.state = { ...this.state, ...updates }
        this.listeners.forEach(l => l(this.state))
    }

    // Controls
    public async play() {
        if (this.state.sourceType === 'TIDAL') {
            await TidalAdapter.resumeTidal()
        }
        this.updateState({ isPlaying: true })
    }

    public async pause() {
        if (this.state.sourceType === 'TIDAL') {
            await TidalAdapter.pauseTidal()
        }
        this.updateState({ isPlaying: false })
    }

    public async togglePlay() {
        if (this.state.isPlaying) {
            await this.pause()
        } else {
            await this.play()
        }
    }

    public async seekTo(seconds: number) {
        if (this.state.sourceType === 'TIDAL') {
            await TidalAdapter.seekTidal(seconds)
        } else if (this.player) {
            this.player.seekTo(seconds, 'seconds')
        }
        this.updateState({ currentTime: seconds })
    }

    public async setVolume(volume: number) { // 0 to 1
        if (this.state.sourceType === 'TIDAL') {
            await TidalAdapter.setTidalVolume(volume)
        }
        this.updateState({ volume })
    }

    // Handlers for ReactPlayer events - Arrow functions to bind 'this' automatically
    public onProgress = (state: { playedSeconds: number }) => {
        if (!this.state.isBuffering) {
            this.updateState({ currentTime: state.playedSeconds })
        }
    }

    public onDuration = (duration: number) => {
        this.updateState({ duration })
    }

    public onBuffer = () => {
        this.updateState({ isBuffering: true })
    }

    public onBufferEnd = () => {
        this.updateState({ isBuffering: false })
    }

    public onError = (error: any) => {
        this.updateState({ error: 'Playback error', isPlaying: false })
        console.error('AudioService Error:', error)
    }

    // Helper to determine source type
    public getSourceType(track: any): AudioSourceType {
        if (track.sourceType === 'TIDAL' || (track.original_playlist_source === 'Tidal')) return 'TIDAL'
        if (track.url?.includes('youtube.com') || track.url?.includes('youtu.be')) return 'YOUTUBE'
        if (track.url?.includes('audio-ssl.itunes.apple.com')) return 'ITUNES_PREVIEW'
        return 'UNKNOWN'
    }

    public async resolveAndPlay(track: any) {
        let url = track.url
        let error = null
        const sourceType = this.getSourceType(track)

        // 1. Native Tidal Playback
        if (sourceType === 'TIDAL') {
            // Logic to use Tidal SDK will go here
            // For now, we will mark it as TIDAL source so the UI knows
            // We need to implement the actual SDK integration using the user's token
            console.log('[AudioService] Attempting Tidal Native Playback for:', track.title)

            // Check if we have a stored Tidal Token (from login)
            const tidalToken = localStorage.getItem('tidal_token') || localStorage.getItem('auth_token') // Allow falling back to main token if it wraps tidal

            // Try to play nativly
            const success = await TidalAdapter.playTidalTrack(track.sourceId || track.id)

            if (success) {
                this.updateState({
                    sourceType: 'TIDAL',
                    isBuffering: false,
                    isPlaying: true, // Auto start
                    error: null
                })
                return 'TIDAL_NATIVE'
            } else {
                console.warn('[AudioService] Tidal Native playback failed, falling back to Smart Match')
                // Fall through to fallback logic below
            }
        }

        // 2. Existing Logic (File / iTunes / YouTube)
        if (!url) {
            if (track.externalMetadata?.youtubeId) {
                url = `https://www.youtube.com/watch?v=${track.externalMetadata.youtubeId}`
            } else if (track.externalMetadata?.previewUrl) {
                url = track.externalMetadata.previewUrl
            }
        }

        // 3. Smart Match (Fallback if NOT Tidal or if Tidal failed)
        if (!url && sourceType !== 'TIDAL') {
            this.updateState({ isBuffering: true, error: null })
            try {
                const query = `${track.artist} - ${track.title} audio`
                const response = await fetch(`${API_BASE_URL}/youtube/search?query=${encodeURIComponent(query)}`)
                if (response.ok) {
                    const data = await response.json()
                    if (data.youtubeId) {
                        url = `https://www.youtube.com/watch?v=${data.youtubeId}`
                        console.log(`[SmartMatch] Resolved: ${track.title} -> ${url}`)
                    }
                }
            } catch (e) {
                console.error('[SmartMatch] Failed:', e)
                error = 'Failed to find track'
            }
        }

        if (url) {
            this.updateState({
                sourceType: this.getSourceType(track) === 'TIDAL' ? 'YOUTUBE' : this.getSourceType(url), // Fallback happens here if needed
                isBuffering: true,
                error: null
            })
            return url
        } else if (sourceType === 'TIDAL') {
            // If we returned 'TIDAL_NATIVE' above, we wouldn't be here. 
            // If we are here, it means we lack a token or implementation.
            this.updateState({ error: 'Tidal login required for high quality playback', isPlaying: false, isBuffering: false })
            return null
        } else {
            this.updateState({ error: error || 'No playable source found', isPlaying: false, isBuffering: false })
            return null
        }
    }
}

export const audioService = AudioService.getInstance()

import React, { createContext, useContext, useState, ReactNode, useEffect } from 'react'
import { Track } from '../services/api/playlists'
import { audioService, AudioState } from '../services/audio/AudioService'

interface MusicContextType {
    currentTrack: Track | null
    isPlaying: boolean
    queue: Track[]
    playTrack: (track: Track) => void
    togglePlay: () => void
    setQueue: (tracks: Track[]) => void
    playPlaylist: (tracks: Track[], startIndex?: number) => void
    playNext: () => void
    playPrevious: () => void
    audioState: AudioState
    resolvedUrl: string | null
}

const MusicContext = createContext<MusicContextType | undefined>(undefined)

export const useMusic = () => {
    const context = useContext(MusicContext)
    if (context === undefined) {
        throw new Error('useMusic must be used within a MusicProvider')
    }
    return context
}

export const MusicProvider = ({ children }: { children: ReactNode }) => {
    const [currentTrack, setCurrentTrack] = useState<Track | null>(null)
    const [queue, setQueueState] = useState<Track[]>([])
    const [resolvedUrl, setResolvedUrl] = useState<string | null>(null)

    // Subscribe to AudioService state
    const [audioState, setAudioState] = useState(audioService.state)

    useEffect(() => {
        const unsubscribe = audioService.subscribe((state) => {
            setAudioState(state)
        })
        return unsubscribe
    }, [])

    const playTrack = async (track: Track) => {
        setCurrentTrack(track)
        setResolvedUrl(null) // Reset URL to prevent playing previous track
        audioService.pause() // Pause previous track

        // Resolve URL (Smart Match)
        const url = await audioService.resolveAndPlay(track)
        setResolvedUrl(url)

        if (url) {
            audioService.play()
        }
    }

    const togglePlay = () => {
        audioService.togglePlay()
    }

    const setQueue = (tracks: Track[]) => {
        setQueueState(tracks)
    }

    const playPlaylist = (tracks: Track[], startIndex = 0) => {
        setQueue(tracks)
        if (tracks.length > startIndex) {
            playTrack(tracks[startIndex])
        }
    }

    const playNext = () => {
        if (!currentTrack || queue.length === 0) return

        const currentIndex = queue.findIndex(t => t.id === currentTrack.id)
        if (currentIndex !== -1 && currentIndex < queue.length - 1) {
            playTrack(queue[currentIndex + 1])
        }
    }

    const playPrevious = () => {
        if (!currentTrack || queue.length === 0) return

        const currentIndex = queue.findIndex(t => t.id === currentTrack.id)
        if (currentIndex > 0) {
            playTrack(queue[currentIndex - 1])
        }
    }

    // Auto-advance
    useEffect(() => {
        // We rely on the player's onEnded event instead of checking time here
    }, [])

    return (
        <MusicContext.Provider
            value={{
                currentTrack,
                isPlaying: audioState.isPlaying,
                queue,
                playTrack,
                togglePlay,
                setQueue,
                playPlaylist,
                playNext,
                playPrevious,
                audioState, // Expose full audio state
                resolvedUrl // Pass resolved URL to Player
            }}
        >
            {children}
        </MusicContext.Provider>
    )
}

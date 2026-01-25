// Tidal Player SDK Wrapper
// Documentation: https://tidal-music.github.io/tidal-sdk-web/

let tidalPlayer: any = null

export const initTidalPlayer = async () => {
    if (tidalPlayer) return tidalPlayer

    try {
        // Dynamic import to avoid build errors if package is missing
        // @ts-ignore
        const { createPlayer } = await import('@tidal-music/player')

        // We need to fetch the token from our backend or localStorage
        // Ideally we use the /api/tidal/auth/token endpoint
        const token = localStorage.getItem('tidal_token')
        if (!token) throw new Error('No Tidal token found')

        tidalPlayer = await createPlayer({
            outputDevices: true,
            volume: 1.0
        })

        // Authorize with the token
        // Use a function that returns the token (and handles refresh if possible)
        await tidalPlayer.authorize({
            tokenProvider: () => Promise.resolve(token)
        })

        console.log('[TidalSDK] Player initialized')
        return tidalPlayer
    } catch (error) {
        console.error('[TidalSDK] Initialization failed:', error)
        return null
    }
}

export const playTidalTrack = async (trackId: string) => {
    const player = await initTidalPlayer()
    if (!player) return false

    try {
        await player.load({
            productId: trackId,
            productType: 'track',
            sourceType: 'TIDAL',
            sourceId: trackId
        })
        await player.play()
        return true
    } catch (error) {
        console.error('[TidalSDK] Playback failed:', error)
        return false
    }
}

export const pauseTidal = async () => {
    if (tidalPlayer) await tidalPlayer.pause()
}

export const resumeTidal = async () => {
    if (tidalPlayer) await tidalPlayer.play()
}

export const setTidalVolume = async (volume: number) => {
    if (tidalPlayer) await tidalPlayer.setVolume(volume)
}

export const seekTidal = async (seconds: number) => {
    if (tidalPlayer) await tidalPlayer.seek(seconds)
}

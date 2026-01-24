import MusicSidebar from '../../components/music/MusicSidebar'
import MusicPlayer from '../../components/music/MusicPlayer'
import PlaylistCard from '../../components/music/PlaylistCard'
import TrackListOverlay from '../../components/music/TrackListOverlay'
import { MusicProvider } from '../../context/MusicContext'
import { playlistsApi, PlaylistWithTracks, Playlist } from '../../services/api/playlists'
import { Play, ArrowRight, Sparkles, Music, Guitar, Headphones, Zap, Loader2 } from 'lucide-react'
import { useState, useEffect, useCallback } from 'react'

const MusicLoungeContent = () => {
    const [selectedPlaylist, setSelectedPlaylist] = useState<PlaylistWithTracks | null>(null)
    const [playlists, setPlaylists] = useState<Playlist[]>([])
    const [loading, setLoading] = useState(true)

    // Fetch playlists from PMS (Personal Music Space)
    const fetchPlaylists = useCallback(async () => {
        try {
            setLoading(true)
            const response = await playlistsApi.getPlaylists('PMS')
            setPlaylists(response.playlists)
        } catch (error) {
            console.error('Failed to fetch playlists:', error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        fetchPlaylists()
    }, [fetchPlaylists])

    const handlePlaylistClick = async (id: number) => {
        try {
            const playlist = await playlistsApi.getById(id) as PlaylistWithTracks
            setSelectedPlaylist(playlist)
        } catch (error) {
            console.error('Failed to fetch playlist', error)
        }
    }

    // Get icon based on index
    const getIcon = (index: number) => {
        const icons = [
            <Music className="w-12 h-12" />,
            <Guitar className="w-12 h-12" />,
            <Headphones className="w-12 h-12" />,
            <Zap className="w-12 h-12" />
        ]
        return icons[index % icons.length]
    }

    return (
        <div className="min-h-screen bg-hud-bg-primary hud-grid-bg pb-32">
            <MusicSidebar />

            {/* Main Content */}
            <main className="ml-0 md:ml-64 p-4 md:p-6">
                {/* Hero Section */}
                <section className="hud-card hud-card-bottom rounded-xl p-8 mb-8 relative overflow-hidden">
                    <div className="relative z-10">
                        <h1 className="text-4xl font-bold text-hud-accent-primary mb-3">Good Evening!</h1>
                        <p className="text-lg text-hud-text-secondary mb-6">오늘도 좋은 음악과 함께하세요</p>

                        <div className="flex gap-4">
                            <button className="bg-hud-accent-primary text-hud-bg-primary px-6 py-3 rounded-lg font-semibold flex items-center gap-2 hover:bg-hud-accent-primary/90 transition-all btn-glow">
                                <Play className="w-5 h-5" fill="currentColor" />
                                Continue Listening
                            </button>
                            <button className="bg-hud-bg-secondary border border-hud-border-secondary text-hud-text-primary px-6 py-3 rounded-lg font-semibold flex items-center gap-2 hover:bg-hud-bg-hover transition-all">
                                <Sparkles className="w-5 h-5" />
                                Surprise Me
                            </button>
                        </div>
                    </div>
                </section>

                {/* AI 추천 섹션 */}
                <section className="mb-8">
                    <div className="flex items-center justify-between mb-6">
                        <h2 className="text-2xl font-bold text-hud-text-primary flex items-center gap-3">
                            My Playlists
                            <span className="bg-gradient-to-r from-hud-accent-secondary to-hud-accent-primary px-3 py-1 rounded-full text-xs font-semibold uppercase text-hud-bg-primary">
                                PMS
                            </span>
                        </h2>
                        <a href="/music/external-space" className="text-hud-accent-primary font-medium flex items-center gap-2 hover:text-hud-accent-primary/80 transition-all">
                            Add More <ArrowRight className="w-4 h-4" />
                        </a>
                    </div>

                    {loading ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="w-8 h-8 text-hud-accent-primary animate-spin" />
                        </div>
                    ) : playlists.length > 0 ? (
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                            {playlists.slice(0, 8).map((playlist, index) => (
                                <PlaylistCard
                                    key={playlist.id}
                                    title={playlist.title}
                                    trackCount={playlist.trackCount || 0}
                                    confidenceScore={playlist.aiScore ? Math.round(Number(playlist.aiScore)) : undefined}
                                    icon={getIcon(index)}
                                    onClick={() => handlePlaylistClick(playlist.id)}
                                />
                            ))}
                        </div>
                    ) : (
                        <div className="hud-card rounded-xl p-8 text-center">
                            <Music className="w-16 h-16 text-hud-text-muted mx-auto mb-4" />
                            <h3 className="text-xl font-bold text-hud-text-primary mb-2">플레이리스트가 없습니다</h3>
                            <p className="text-hud-text-secondary mb-4">The Cargo에서 플레이리스트를 가져와 시작하세요</p>
                            <a
                                href="/music/external-space"
                                className="inline-flex items-center gap-2 bg-hud-accent-primary text-hud-bg-primary px-6 py-3 rounded-lg font-semibold hover:bg-hud-accent-primary/90 transition-all"
                            >
                                <ArrowRight className="w-5 h-5" />
                                The Cargo로 이동
                            </a>
                        </div>
                    )}
                </section>

                {/* Stats Sidebar */}
                {playlists.length > 0 && (
                    <section className="grid lg:grid-cols-3 gap-6">
                        <div className="lg:col-span-3 hud-card hud-card-bottom rounded-xl p-6">
                            <h3 className="text-lg font-bold text-hud-text-primary mb-6">Your Stats</h3>

                            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                                {[
                                    { value: playlists.length.toString(), label: 'Total Playlists', color: 'text-hud-accent-primary' },
                                    { value: playlists.reduce((sum, p) => sum + (p.trackCount || 0), 0).toString(), label: 'Total Tracks', color: 'text-hud-accent-secondary' },
                                    { value: playlists.filter(p => p.status === 'PRP').length.toString(), label: 'Verified', color: 'text-hud-accent-info' },
                                    { value: playlists.filter(p => Number(p.aiScore) > 80).length.toString(), label: 'High Score', color: 'text-hud-accent-success' }
                                ].map((stat) => (
                                    <div key={stat.label} className="text-center">
                                        <div className={`text-3xl font-bold ${stat.color}`}>{stat.value}</div>
                                        <div className="text-xs text-hud-text-muted uppercase tracking-wider">{stat.label}</div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </section>
                )}
            </main>

            <MusicPlayer />

            {selectedPlaylist && (
                <TrackListOverlay
                    playlist={selectedPlaylist}
                    onClose={() => setSelectedPlaylist(null)}
                />
            )}
        </div>
    )
}

const MusicLounge = () => {
    return (
        <MusicProvider>
            <MusicLoungeContent />
        </MusicProvider>
    )
}

export default MusicLounge

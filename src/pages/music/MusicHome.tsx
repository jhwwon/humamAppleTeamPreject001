import { Link } from 'react-router-dom'
import { Music, Users, Disc, Crown, Star, TrendingUp, ArrowRight, Play, Heart, Sparkles } from 'lucide-react'

const MusicHome = () => {
    return (
        <div className="min-h-screen bg-hud-bg-primary hud-grid-bg">
            {/* Header */}
            <header className="bg-hud-bg-secondary/80 backdrop-blur-md border-b border-hud-border-secondary sticky top-0 z-40">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <Music className="w-8 h-8 text-hud-accent-primary" />
                        <span className="text-2xl font-bold text-hud-accent-primary text-glow">MusicSpace</span>
                    </div>
                    <nav className="hidden md:flex items-center gap-6">
                        <Link to="/" className="text-hud-accent-primary font-medium">HOME</Link>
                        <Link to="/music/lounge" className="text-hud-text-secondary hover:text-hud-accent-success transition-colors">PMS</Link>
                        <Link to="/music/lab" className="text-hud-text-secondary hover:text-hud-accent-warning transition-colors">GMS</Link>
                        <Link to="/music/external-space" className="text-hud-text-secondary hover:text-hud-accent-info transition-colors">EMS</Link>
                    </nav>
                </div>
            </header>

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Hero Section */}
                <section className="hud-card hud-card-bottom rounded-xl p-6 md:p-10 mb-8 bg-gradient-to-br from-hud-accent-info/20 to-hud-accent-primary/10">
                    <div className="flex flex-col md:flex-row items-center gap-6">
                        <div className="flex-1">
                            <h1 className="text-3xl md:text-4xl font-bold text-hud-text-primary mb-3">Welcome Back!</h1>
                            <p className="text-hud-text-secondary mb-6">오늘의 추천 음악을 확인하고 새로운 발견을 시작하세요</p>
                            <div className="flex flex-wrap gap-3">
                                <Link to="/music/lounge" className="bg-hud-accent-primary text-hud-bg-primary px-5 py-2.5 rounded-lg font-semibold flex items-center gap-2 hover:bg-hud-accent-primary/90 transition-all btn-glow">
                                    <Play className="w-4 h-4" fill="currentColor" /> 음악 감상하기
                                </Link>
                                <Link to="/music/lab" className="bg-hud-bg-secondary border border-hud-border-secondary text-hud-text-primary px-5 py-2.5 rounded-lg font-medium flex items-center gap-2 hover:bg-hud-bg-hover transition-all">
                                    <Sparkles className="w-4 h-4" /> 새 추천 확인
                                </Link>
                            </div>
                        </div>
                        <div className="w-32 h-32 md:w-40 md:h-40 bg-gradient-to-br from-hud-accent-primary to-hud-accent-info rounded-2xl flex items-center justify-center">
                            <Music className="w-16 h-16 md:w-20 md:h-20 text-white" />
                        </div>
                    </div>
                </section>

                {/* Quick Stats */}
                <section className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                    {[
                        { label: '총 플레이리스트', value: '247', icon: Disc, color: 'hud-accent-primary' },
                        { label: '저장된 트랙', value: '3,492', icon: Music, color: 'hud-accent-secondary' },
                        { label: 'AI 추천 대기', value: '15', icon: Sparkles, color: 'hud-accent-warning' },
                        { label: '좋아요', value: '892', icon: Heart, color: 'hud-accent-danger' },
                    ].map((stat) => (
                        <div key={stat.label} className="hud-card hud-card-bottom rounded-xl p-4 text-center">
                            <stat.icon className={`w-6 h-6 mx-auto mb-2 text-${stat.color}`} />
                            <div className={`text-2xl font-bold text-${stat.color}`}>{stat.value}</div>
                            <div className="text-xs text-hud-text-muted">{stat.label}</div>
                        </div>
                    ))}
                </section>

                {/* Best Artists */}
                <section className="mb-8">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="text-xl font-bold text-hud-text-primary flex items-center gap-2">
                            <Users className="w-5 h-5 text-hud-accent-primary" /> 베스트 아티스트
                        </h2>
                        <a href="#" className="text-hud-accent-primary text-sm flex items-center gap-1 hover:underline">
                            전체보기 <ArrowRight className="w-4 h-4" />
                        </a>
                    </div>
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                        {['IU', 'BTS', 'NewJeans', 'Aespa', 'BLACKPINK'].map((artist, idx) => (
                            <div key={artist} className="hud-card hud-card-bottom rounded-xl p-4 text-center hover:scale-105 transition-transform cursor-pointer">
                                <div className="w-16 h-16 mx-auto mb-3 bg-gradient-to-br from-hud-accent-secondary to-hud-accent-primary rounded-full flex items-center justify-center text-white font-bold text-xl">
                                    {artist.charAt(0)}
                                </div>
                                <div className="font-medium text-hud-text-primary text-sm">{artist}</div>
                                <div className="text-xs text-hud-text-muted">#{idx + 1}</div>
                            </div>
                        ))}
                    </div>
                </section>

                {/* Platform Best 5 */}
                <section className="mb-8">
                    <h2 className="text-xl font-bold text-hud-text-primary flex items-center gap-2 mb-4">
                        <TrendingUp className="w-5 h-5 text-hud-accent-warning" /> 플랫폼별 베스트 5
                    </h2>
                    <div className="grid md:grid-cols-3 gap-4">
                        {[
                            { name: 'Tidal', color: 'from-blue-500 to-cyan-400', tracks: ['Butter - BTS', 'Dynamite - BTS', 'Super Shy - NewJeans', 'Hype Boy - NewJeans', 'Next Level - Aespa'] },
                            { name: 'YouTube Music', color: 'from-red-500 to-red-600', tracks: ['FLOWER - JISOO', 'OMG - NewJeans', 'Ditto - NewJeans', 'Pink Venom - BLACKPINK', 'ZZZ - BIBI'] },
                            { name: 'Apple Music', color: 'from-pink-500 to-rose-500', tracks: ['Celebrity - IU', 'Blueming - IU', 'Eight - IU', 'Lilac - IU', 'Palette - IU'] },
                        ].map((platform) => (
                            <div key={platform.name} className="hud-card hud-card-bottom rounded-xl overflow-hidden">
                                <div className={`bg-gradient-to-r ${platform.color} px-4 py-3 text-white font-semibold`}>
                                    {platform.name} Top 5
                                </div>
                                <div className="p-4 space-y-2">
                                    {platform.tracks.map((track, idx) => (
                                        <div key={track} className="flex items-center gap-3 text-sm">
                                            <span className="w-5 h-5 bg-hud-bg-secondary rounded-full flex items-center justify-center text-xs font-medium text-hud-text-muted">{idx + 1}</span>
                                            <span className="text-hud-text-primary truncate flex-1">{track}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                {/* Recommended Playlists */}
                <section className="mb-8">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="text-xl font-bold text-hud-text-primary flex items-center gap-2">
                            <Star className="w-5 h-5 text-hud-accent-success" /> 추천 플레이리스트 3선
                        </h2>
                        <Link to="/music/lab" className="text-hud-accent-primary text-sm flex items-center gap-1 hover:underline">
                            GMS에서 더보기 <ArrowRight className="w-4 h-4" />
                        </Link>
                    </div>
                    <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                        {[
                            { title: 'K-POP Hits 2024', score: 95, tracks: 42 },
                            { title: 'Chill & Study', score: 92, tracks: 35 },
                            { title: 'Morning Energy', score: 88, tracks: 28 },
                        ].map((playlist) => (
                            <div key={playlist.title} className="hud-card hud-card-bottom rounded-xl p-5 hover:scale-105 transition-transform cursor-pointer group">
                                <div className="w-full aspect-video bg-gradient-to-br from-hud-accent-success to-hud-accent-primary rounded-lg mb-4 flex items-center justify-center relative overflow-hidden">
                                    <Music className="w-12 h-12 text-white/50" />
                                    <div className="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                        <Play className="w-10 h-10 text-white" fill="white" />
                                    </div>
                                </div>
                                <h3 className="font-semibold text-hud-text-primary mb-1">{playlist.title}</h3>
                                <div className="flex items-center justify-between text-sm">
                                    <span className="text-hud-text-muted">{playlist.tracks} tracks</span>
                                    <span className="bg-hud-accent-success/20 text-hud-accent-success px-2 py-0.5 rounded-full text-xs font-semibold flex items-center gap-1">
                                        <Star className="w-3 h-3" fill="currentColor" /> {playlist.score}%
                                    </span>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                {/* Best of Best */}
                <section className="hud-card hud-card-bottom rounded-xl p-6 border-l-4 border-hud-accent-warning">
                    <h2 className="text-xl font-bold text-hud-accent-warning flex items-center gap-2 mb-6">
                        <Crown className="w-6 h-6" /> BEST OF BEST
                    </h2>
                    <div className="grid sm:grid-cols-3 gap-6">
                        {[
                            { type: '플레이리스트', name: 'K-POP Hits 2024', sub: '42 tracks' },
                            { type: '앨범', name: 'The Astronaut', sub: 'Jin' },
                            { type: '트랙', name: 'Super Shy', sub: 'NewJeans' },
                        ].map((item) => (
                            <div key={item.type} className="flex items-center gap-4">
                                <div className="w-16 h-16 bg-gradient-to-br from-hud-accent-warning to-orange-400 rounded-xl flex items-center justify-center">
                                    <Crown className="w-8 h-8 text-white" />
                                </div>
                                <div>
                                    <div className="text-xs text-hud-accent-warning font-semibold uppercase">{item.type}</div>
                                    <div className="font-semibold text-hud-text-primary">{item.name}</div>
                                    <div className="text-sm text-hud-text-muted">{item.sub}</div>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>
            </main>
        </div>
    )
}

export default MusicHome

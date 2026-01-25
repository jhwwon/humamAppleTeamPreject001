import { Play, Music, Star, MoreVertical, Edit2, Trash2, X } from 'lucide-react'
import { useState, useRef, useEffect } from 'react'

interface PlaylistCardProps {
    title: string
    trackCount: number
    confidenceScore?: number
    coverImage?: string
    icon?: React.ReactNode
    gradient?: string
    onClick?: () => void
    onEdit?: (e: React.MouseEvent) => void
    onDelete?: (e: React.MouseEvent) => void
}

const PlaylistCard = ({
    title,
    trackCount,
    confidenceScore = 95,
    coverImage,
    icon,
    gradient = 'from-hud-accent-primary to-hud-accent-info',
    onClick,
    onEdit,
    onDelete
}: PlaylistCardProps) => {
    const [showMenu, setShowMenu] = useState(false)
    const menuRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
                setShowMenu(false)
            }
        }
        document.addEventListener('mousedown', handleClickOutside)
        return () => document.removeEventListener('mousedown', handleClickOutside)
    }, [])

    const handleMenuClick = (e: React.MouseEvent) => {
        e.stopPropagation()
        setShowMenu(!showMenu)
    }

    return (
        <div
            onClick={onClick}
            className="hud-card hud-card-bottom rounded-xl p-5 cursor-pointer group transition-all hover:scale-105 relative"
        >
            {/* Menu Button */}
            {(onEdit || onDelete) && (
                <div className="absolute top-3 right-3 z-30" ref={menuRef}>
                    <button
                        onClick={handleMenuClick}
                        className="p-1.5 rounded-full bg-black/40 text-white/80 hover:bg-black/60 hover:text-white transition-colors opacity-0 group-hover:opacity-100"
                    >
                        <MoreVertical size={16} />
                    </button>

                    {showMenu && (
                        <div className="absolute right-0 mt-1 w-32 bg-hud-bg-card border border-hud-border-secondary rounded-lg shadow-xl overflow-hidden z-40 animate-in fade-in zoom-in-95 duration-200">
                            {onEdit && (
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation()
                                        setShowMenu(false)
                                        onEdit(e)
                                    }}
                                    className="w-full text-left px-3 py-2 text-sm text-hud-text-primary hover:bg-hud-bg-hover flex items-center gap-2"
                                >
                                    <Edit2 size={14} /> Edit
                                </button>
                            )}
                            {onDelete && (
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation()
                                        setShowMenu(false)
                                        onDelete(e)
                                    }}
                                    className="w-full text-left px-3 py-2 text-sm text-red-400 hover:bg-red-500/10 flex items-center gap-2"
                                >
                                    <Trash2 size={14} /> Delete
                                </button>
                            )}
                        </div>
                    )}
                </div>
            )}

            {/* Cover */}
            <div className={`w-full aspect-square bg-gradient-to-br ${gradient} rounded-lg mb-4 flex items-center justify-center text-white/40 relative overflow-hidden`}>
                {coverImage ? (
                    <img src={coverImage} alt={title} className="w-full h-full object-cover" />
                ) : (
                    icon || <Music className="w-12 h-12" />
                )}

                {/* Play Overlay */}
                <div className="absolute inset-0 bg-black/60 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <div className="w-14 h-14 bg-hud-accent-primary rounded-full flex items-center justify-center text-hud-bg-primary hover:scale-110 transition-transform">
                        <Play className="w-6 h-6 ml-0.5" fill="currentColor" />
                    </div>
                </div>
            </div>

            {/* Info */}
            <div>
                <h3 className="text-base font-semibold text-hud-text-primary mb-2 group-hover:text-hud-accent-primary transition-colors">{title}</h3>
                <div className="flex items-center justify-between text-sm">
                    <span className="text-hud-text-muted">{trackCount} tracks</span>
                    {confidenceScore && (
                        <span className="bg-hud-accent-success/10 text-hud-accent-success flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold">
                            <Star className="w-3 h-3" fill="currentColor" />
                            {confidenceScore}%
                        </span>
                    )}
                </div>
            </div>
        </div>
    )
}

export default PlaylistCard

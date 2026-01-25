import express from 'express'
import { optionalAuth } from '../middleware/auth.js'

const router = express.Router()

// GET /api/youtube/search - Search for a video (Smart Match)
router.get('/search', optionalAuth, async (req, res) => {
    try {
        const { query } = req.query
        if (!query) {
            return res.status(400).json({ error: 'Query is required' })
        }

        const apiKey = process.env.YOUTUBE_KEY
        if (!apiKey) {
            return res.status(503).json({ error: 'YouTube API key not configured' })
        }

        console.log(`[YouTube] Smart Match Search: ${query}`)

        const YOUTUBE_API_URL = 'https://www.googleapis.com/youtube/v3/search'
        const url = new URL(YOUTUBE_API_URL)
        url.searchParams.append('key', apiKey)
        url.searchParams.append('part', 'snippet')
        url.searchParams.append('q', query.toString())
        url.searchParams.append('type', 'video')
        url.searchParams.append('videoCategoryId', '10') // Music category
        url.searchParams.append('maxResults', '1')

        const response = await fetch(url.toString())
        if (!response.ok) {
            const errorText = await response.text()
            console.error('[YouTube] Search failed:', errorText)
            return res.status(response.status).json({ error: 'YouTube API error' })
        }

        const data = await response.json()
        const item = data.items?.[0]

        if (!item) {
            return res.status(404).json({ error: 'No video found' })
        }

        res.json({
            youtubeId: item.id.videoId,
            title: item.snippet.title,
            thumbnail: item.snippet.thumbnails?.high?.url
        })
    } catch (error) {
        console.error('[YouTube] Proxy error:', error)
        res.status(500).json({ error: error.message })
    }
})

export default router

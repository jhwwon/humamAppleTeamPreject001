-- 콘텐츠 통계 테이블 (플레이리스트, 트랙, 앨범)
CREATE TABLE IF NOT EXISTS content_stats (
    stat_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '통계 ID',
    content_type ENUM('playlist', 'track', 'album') NOT NULL COMMENT '콘텐츠 타입',
    content_id BIGINT NOT NULL COMMENT '콘텐츠 ID',
    view_count INT DEFAULT 0 COMMENT '조회수',
    play_count INT DEFAULT 0 COMMENT '재생수',
    like_count INT DEFAULT 0 COMMENT '좋아요 수',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    UNIQUE KEY uk_content (content_type, content_id),
    INDEX idx_view_count (content_type, view_count DESC),
    INDEX idx_play_count (content_type, play_count DESC)
) ENGINE=InnoDB COMMENT='콘텐츠별 조회/재생 통계';

-- 아티스트 통계 테이블
CREATE TABLE IF NOT EXISTS artist_stats (
    stat_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '통계 ID',
    artist_name VARCHAR(255) NOT NULL COMMENT '아티스트 이름',
    view_count INT DEFAULT 0 COMMENT '조회수',
    play_count INT DEFAULT 0 COMMENT '재생수',
    like_count INT DEFAULT 0 COMMENT '좋아요 수',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    UNIQUE KEY uk_artist (artist_name),
    INDEX idx_play_count (play_count DESC)
) ENGINE=InnoDB COMMENT='아티스트별 통계';

-- 일별 통계 로그 (트렌드 분석용)
CREATE TABLE IF NOT EXISTS daily_stats_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_date DATE NOT NULL COMMENT '날짜',
    content_type ENUM('playlist', 'track', 'album', 'artist') NOT NULL,
    content_id BIGINT COMMENT '콘텐츠 ID (아티스트는 NULL)',
    artist_name VARCHAR(255) COMMENT '아티스트 이름 (아티스트일 때만)',
    view_count INT DEFAULT 0,
    play_count INT DEFAULT 0,
    UNIQUE KEY uk_daily (log_date, content_type, content_id, artist_name),
    INDEX idx_date (log_date DESC)
) ENGINE=InnoDB COMMENT='일별 통계 로그';

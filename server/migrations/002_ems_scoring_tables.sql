-- =====================================================
-- MusicSpace - EMS API 지원 테이블 마이그레이션
-- EMS API에서 사용하는 평점, 점수 관련 테이블 추가
-- =====================================================

-- 1. tracks 테이블에 genre, audio_features 컬럼 추가 (MySQL 8.0 호환)
-- 컬럼이 이미 존재하면 에러 무시
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'genre');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `tracks` ADD COLUMN `genre` VARCHAR(255) DEFAULT NULL COMMENT ''장르 (콤마로 구분)''',
    'SELECT ''genre column already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'audio_features');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `tracks` ADD COLUMN `audio_features` JSON DEFAULT NULL COMMENT ''오디오 특성 (tempo, energy, danceability 등)''',
    'SELECT ''audio_features column already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 1-1. playlists 테이블에 ai_score 컬럼 추가 (analysis.js에서 사용)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'playlists' AND COLUMN_NAME = 'ai_score');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `playlists` ADD COLUMN `ai_score` DECIMAL(5,2) DEFAULT 0.00 COMMENT ''AI 추천 점수 (0-100)''',
    'SELECT ''ai_score column already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. 사용자 트랙 평가 테이블 (좋아요/싫어요)
CREATE TABLE IF NOT EXISTS `user_track_ratings` (
    `rating_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '평가 ID',
    `user_id` BIGINT NOT NULL COMMENT '사용자 ID',
    `track_id` BIGINT NOT NULL COMMENT '트랙 ID',
    `rating` TINYINT NOT NULL COMMENT '평점 (1: 좋아요, -1: 싫어요, 0: 중립)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '평가일시',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (`rating_id`),
    UNIQUE KEY `uk_user_track` (`user_id`, `track_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_track_id` (`track_id`),
    KEY `idx_rating` (`rating`),
    CONSTRAINT `fk_rating_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rating_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`track_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 트랙 평가 (좋아요/싫어요)';

-- 3. 트랙 AI 점수 테이블
CREATE TABLE IF NOT EXISTS `track_scored_id` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `track_id` BIGINT NOT NULL COMMENT '트랙 ID',
    `user_id` BIGINT NOT NULL COMMENT '사용자 ID (개인화 점수)',
    `ai_score` DECIMAL(5,2) DEFAULT 0.00 COMMENT 'AI 추천 점수 (0-100)',
    `score_type` VARCHAR(50) DEFAULT 'general' COMMENT '점수 타입 (general, personalized, trending)',
    `calculated_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '계산일시',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_track_user` (`track_id`, `user_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_ai_score` (`ai_score` DESC),
    CONSTRAINT `fk_track_score_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`track_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_track_score_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='트랙 AI 추천 점수';

-- 4. 플레이리스트 AI 점수 테이블
CREATE TABLE IF NOT EXISTS `playlist_scored_id` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `playlist_id` BIGINT NOT NULL COMMENT '플레이리스트 ID',
    `user_id` BIGINT NOT NULL COMMENT '사용자 ID',
    `ai_score` DECIMAL(5,2) DEFAULT 0.00 COMMENT 'AI 추천 점수 (0-100)',
    `score_type` VARCHAR(50) DEFAULT 'general' COMMENT '점수 타입',
    `calculated_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '계산일시',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_playlist_user` (`playlist_id`, `user_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_ai_score` (`ai_score` DESC),
    CONSTRAINT `fk_playlist_score_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `playlists` (`playlist_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_playlist_score_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플레이리스트 AI 추천 점수';

-- 5. 트랙 태그 테이블 (Last.fm 등에서 가져온 태그)
CREATE TABLE IF NOT EXISTS `track_tags` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `track_id` BIGINT NOT NULL COMMENT '트랙 ID',
    `tag` VARCHAR(100) NOT NULL COMMENT '태그명',
    `source` VARCHAR(50) DEFAULT 'lastfm' COMMENT '태그 출처 (lastfm, spotify, user)',
    `weight` INT DEFAULT 100 COMMENT '태그 가중치 (0-100)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_track_tag_source` (`track_id`, `tag`, `source`),
    KEY `idx_track_id` (`track_id`),
    KEY `idx_tag` (`tag`),
    CONSTRAINT `fk_tag_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`track_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='트랙 태그 정보';

-- =====================================================
-- 인덱스 추가 (성능 최적화)
-- =====================================================

-- tracks 테이블 인덱스 (MySQL 8.0 호환 - 에러 무시)
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_artist');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_artist` ON `tracks` (`artist`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_genre');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_genre` ON `tracks` (`genre`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- playlists 테이블 인덱스  
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'playlists' AND INDEX_NAME = 'idx_playlists_space_type');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_playlists_space_type` ON `playlists` (`space_type`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'playlists' AND INDEX_NAME = 'idx_playlists_user_space');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_playlists_user_space` ON `playlists` (`user_id`, `space_type`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =====================================================
-- 확인 쿼리
-- =====================================================
-- SHOW TABLES LIKE '%score%';
-- SHOW TABLES LIKE '%rating%';
-- DESCRIBE tracks;
-- DESCRIBE user_track_ratings;
-- DESCRIBE track_scored_id;
-- DESCRIBE playlist_scored_id;

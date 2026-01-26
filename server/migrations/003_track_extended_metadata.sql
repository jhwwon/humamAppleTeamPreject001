-- =====================================================
-- MusicSpace - 트랙 확장 메타데이터 마이그레이션
-- Spotify & Last.fm API에서 제공하는 추가 정보 저장
-- MySQL 8.0 호환
-- =====================================================

DELIMITER //

-- 1. tracks 테이블에 확장 컬럼 추가 (MySQL 8.0 호환)
DROP PROCEDURE IF EXISTS add_tracks_columns//
CREATE PROCEDURE add_tracks_columns()
BEGIN
    -- Spotify Track Info
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'popularity') THEN
        ALTER TABLE `tracks` ADD COLUMN `popularity` TINYINT UNSIGNED DEFAULT NULL COMMENT 'Spotify 인기도 (0-100)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'explicit') THEN
        ALTER TABLE `tracks` ADD COLUMN `explicit` TINYINT(1) DEFAULT 0 COMMENT '성인 컨텐츠 여부 (0: 아님, 1: 맞음)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'release_date') THEN
        ALTER TABLE `tracks` ADD COLUMN `release_date` DATE DEFAULT NULL COMMENT '발매일';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'track_number') THEN
        ALTER TABLE `tracks` ADD COLUMN `track_number` SMALLINT UNSIGNED DEFAULT NULL COMMENT '앨범 내 트랙 번호';
    END IF;
    
    -- Last.fm Stats
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'playcount') THEN
        ALTER TABLE `tracks` ADD COLUMN `playcount` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Last.fm 총 재생 횟수';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'listeners') THEN
        ALTER TABLE `tracks` ADD COLUMN `listeners` INT UNSIGNED DEFAULT NULL COMMENT 'Last.fm 청취자 수';
    END IF;
    
    -- Music IDs
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'mbid') THEN
        ALTER TABLE `tracks` ADD COLUMN `mbid` VARCHAR(36) DEFAULT NULL COMMENT 'MusicBrainz ID (UUID)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'spotify_id') THEN
        ALTER TABLE `tracks` ADD COLUMN `spotify_id` VARCHAR(22) DEFAULT NULL COMMENT 'Spotify Track ID';
    END IF;
    
    -- Spotify Audio Features (개별 컬럼)
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'tempo') THEN
        ALTER TABLE `tracks` ADD COLUMN `tempo` DECIMAL(6,3) DEFAULT NULL COMMENT 'BPM (30-300)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'music_key') THEN
        ALTER TABLE `tracks` ADD COLUMN `music_key` TINYINT DEFAULT NULL COMMENT '조성 (0=C, 1=C#, ... 11=B, -1=Unknown)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'mode') THEN
        ALTER TABLE `tracks` ADD COLUMN `mode` TINYINT(1) DEFAULT NULL COMMENT '0=Minor, 1=Major';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'time_signature') THEN
        ALTER TABLE `tracks` ADD COLUMN `time_signature` TINYINT DEFAULT NULL COMMENT '박자 (3, 4, 5, 6, 7)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'danceability') THEN
        ALTER TABLE `tracks` ADD COLUMN `danceability` DECIMAL(4,3) DEFAULT NULL COMMENT '춤추기 좋은 정도 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'energy') THEN
        ALTER TABLE `tracks` ADD COLUMN `energy` DECIMAL(4,3) DEFAULT NULL COMMENT '에너지 레벨 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'valence') THEN
        ALTER TABLE `tracks` ADD COLUMN `valence` DECIMAL(4,3) DEFAULT NULL COMMENT '긍정적 분위기 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'acousticness') THEN
        ALTER TABLE `tracks` ADD COLUMN `acousticness` DECIMAL(4,3) DEFAULT NULL COMMENT '어쿠스틱 정도 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'instrumentalness') THEN
        ALTER TABLE `tracks` ADD COLUMN `instrumentalness` DECIMAL(4,3) DEFAULT NULL COMMENT '보컬 없는 정도 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'liveness') THEN
        ALTER TABLE `tracks` ADD COLUMN `liveness` DECIMAL(4,3) DEFAULT NULL COMMENT '라이브 느낌 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'speechiness') THEN
        ALTER TABLE `tracks` ADD COLUMN `speechiness` DECIMAL(4,3) DEFAULT NULL COMMENT '말하는 정도 (0.0-1.0)';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND COLUMN_NAME = 'loudness') THEN
        ALTER TABLE `tracks` ADD COLUMN `loudness` DECIMAL(5,2) DEFAULT NULL COMMENT '음량 dB (-60 to 0)';
    END IF;
END//

DELIMITER ;

CALL add_tracks_columns();
DROP PROCEDURE IF EXISTS add_tracks_columns;

-- 2. 인덱스 추가 (검색/필터링 성능) - MySQL 8.0 호환
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_popularity');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_popularity` ON `tracks` (`popularity` DESC)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_release_date');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_release_date` ON `tracks` (`release_date`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_spotify_id');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_spotify_id` ON `tracks` (`spotify_id`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_mbid');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_mbid` ON `tracks` (`mbid`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_tempo');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_tempo` ON `tracks` (`tempo`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_energy');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_energy` ON `tracks` (`energy`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tracks' AND INDEX_NAME = 'idx_tracks_valence');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX `idx_tracks_valence` ON `tracks` (`valence`)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. 아티스트 테이블 (정규화)
CREATE TABLE IF NOT EXISTS `artists` (
    `artist_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '아티스트 ID',
    `name` VARCHAR(255) NOT NULL COMMENT '아티스트명',
    `spotify_id` VARCHAR(22) DEFAULT NULL COMMENT 'Spotify Artist ID',
    `mbid` VARCHAR(36) DEFAULT NULL COMMENT 'MusicBrainz ID',
    `genres` JSON DEFAULT NULL COMMENT '장르 목록 (JSON 배열)',
    `popularity` TINYINT UNSIGNED DEFAULT NULL COMMENT 'Spotify 인기도',
    `followers` INT UNSIGNED DEFAULT NULL COMMENT 'Spotify 팔로워 수',
    `image_url` VARCHAR(500) DEFAULT NULL COMMENT '아티스트 이미지 URL',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`artist_id`),
    UNIQUE KEY `uk_spotify_id` (`spotify_id`),
    KEY `idx_name` (`name`),
    KEY `idx_mbid` (`mbid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='아티스트 정보 테이블';

-- 4. 앨범 테이블 (정규화)
CREATE TABLE IF NOT EXISTS `albums` (
    `album_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '앨범 ID',
    `name` VARCHAR(255) NOT NULL COMMENT '앨범명',
    `artist_id` BIGINT DEFAULT NULL COMMENT '메인 아티스트 ID',
    `spotify_id` VARCHAR(22) DEFAULT NULL COMMENT 'Spotify Album ID',
    `mbid` VARCHAR(36) DEFAULT NULL COMMENT 'MusicBrainz ID',
    `album_type` ENUM('album', 'single', 'compilation', 'ep') DEFAULT 'album' COMMENT '앨범 타입',
    `release_date` DATE DEFAULT NULL COMMENT '발매일',
    `total_tracks` SMALLINT UNSIGNED DEFAULT NULL COMMENT '총 트랙 수',
    `image_url` VARCHAR(500) DEFAULT NULL COMMENT '앨범 커버 이미지 URL',
    `label` VARCHAR(255) DEFAULT NULL COMMENT '레이블/레코드사',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`album_id`),
    UNIQUE KEY `uk_spotify_id` (`spotify_id`),
    KEY `idx_name` (`name`),
    KEY `idx_artist` (`artist_id`),
    KEY `idx_release_date` (`release_date`),
    CONSTRAINT `fk_album_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='앨범 정보 테이블';

-- =====================================================
-- 필드 설명
-- =====================================================
-- 
-- [Spotify Audio Features]
-- - tempo: BPM (분당 비트 수)
-- - music_key: 조성 (C=0, C#/Db=1, D=2, ... B=11)
-- - mode: 장조(1)/단조(0)
-- - time_signature: 박자 (4/4박자면 4)
-- - danceability: 춤추기 좋은 정도
-- - energy: 에너지/강도
-- - valence: 긍정적/밝은 분위기 (높을수록 행복한 느낌)
-- - acousticness: 어쿠스틱 악기 사용 정도
-- - instrumentalness: 보컬 없는 정도 (높을수록 기악곡)
-- - liveness: 라이브 공연 느낌
-- - speechiness: 말하는 부분 비율 (높으면 팟캐스트/랩)
-- - loudness: 평균 음량 (dB)
--
-- [Last.fm Stats]
-- - playcount: 전체 재생 횟수
-- - listeners: 고유 청취자 수
-- - mbid: MusicBrainz 데이터베이스 ID
--
-- =====================================================

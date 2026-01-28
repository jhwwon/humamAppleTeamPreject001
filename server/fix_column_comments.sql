-- playlists 테이블
ALTER TABLE playlists MODIFY playlist_id BIGINT AUTO_INCREMENT COMMENT '플레이리스트 고유 ID';
ALTER TABLE playlists MODIFY user_id BIGINT NOT NULL COMMENT '사용자 ID';
ALTER TABLE playlists MODIFY title VARCHAR(200) NOT NULL COMMENT '플레이리스트 제목';
ALTER TABLE playlists MODIFY description TEXT COMMENT '플레이리스트 설명';
ALTER TABLE playlists MODIFY space_type ENUM('PMS', 'EMS', 'GMS') NOT NULL DEFAULT 'EMS' COMMENT '공간 타입 (PMS, EMS, GMS)';
ALTER TABLE playlists MODIFY status_flag ENUM('PTP', 'PRP', 'PFP') NOT NULL DEFAULT 'PTP' COMMENT '상태 플래그 (PTP:임시, PRP:정규, PFP:필터링됨)';
ALTER TABLE playlists MODIFY source_type ENUM('Platform', 'Upload', 'System') NOT NULL DEFAULT 'Platform' COMMENT '출처 타입 (Platform:스트리밍, Upload:파일업로드, System:시스템생성)';
ALTER TABLE playlists MODIFY external_id VARCHAR(255) COMMENT '외부 플랫폼에서의 플레이리스트 ID';
ALTER TABLE playlists MODIFY cover_image VARCHAR(500) COMMENT '커버 이미지 URL';
ALTER TABLE playlists MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';
ALTER TABLE playlists MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';
ALTER TABLE playlists MODIFY ai_score DECIMAL(5,2) DEFAULT 0.00 COMMENT 'AI 추천 점수 (0-100)';

-- users 테이블
ALTER TABLE users MODIFY user_id BIGINT AUTO_INCREMENT COMMENT '사용자 고유 ID';
ALTER TABLE users MODIFY email VARCHAR(255) NOT NULL COMMENT '이메일 (로그인 ID)';
ALTER TABLE users MODIFY password_hash VARCHAR(255) NOT NULL COMMENT '비밀번호 해시';
ALTER TABLE users MODIFY nickname VARCHAR(100) NOT NULL COMMENT '사용자 닉네임';
ALTER TABLE users MODIFY user_role ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER' COMMENT '사용자 역할';
ALTER TABLE users MODIFY streaming_services JSON DEFAULT NULL COMMENT '연결된 스트리밍 서비스 목록';
ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시';
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

-- tracks 테이블
ALTER TABLE tracks MODIFY track_id BIGINT AUTO_INCREMENT COMMENT '트랙 고유 ID';
ALTER TABLE tracks MODIFY title VARCHAR(255) NOT NULL COMMENT '곡 제목';
ALTER TABLE tracks MODIFY artist VARCHAR(255) NOT NULL COMMENT '아티스트';
ALTER TABLE tracks MODIFY album VARCHAR(255) COMMENT '앨범명';
ALTER TABLE tracks MODIFY duration INT COMMENT '재생 시간(초)';
ALTER TABLE tracks MODIFY isrc VARCHAR(50) COMMENT '국제 표준 녹음 코드';
ALTER TABLE tracks MODIFY external_metadata JSON COMMENT '외부 플랫폼별 상세 ID 및 메타데이터 (JSON)';
ALTER TABLE tracks MODIFY genre VARCHAR(500) COMMENT '음악 장르 (쉼표로 구분)';
ALTER TABLE tracks MODIFY audio_features JSON COMMENT '오디오 특성 (Spotify/Last.fm - JSON)';
ALTER TABLE tracks MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시';

-- playlist_tracks 테이블
ALTER TABLE playlist_tracks MODIFY map_id BIGINT AUTO_INCREMENT COMMENT '매핑 ID';
ALTER TABLE playlist_tracks MODIFY playlist_id BIGINT NOT NULL COMMENT '플레이리스트 ID';
ALTER TABLE playlist_tracks MODIFY track_id BIGINT NOT NULL COMMENT '트랙 ID';
ALTER TABLE playlist_tracks MODIFY order_index INT NOT NULL DEFAULT 0 COMMENT '플레이리스트 내 정렬 순서';
ALTER TABLE playlist_tracks MODIFY added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '추가된 일시';

-- user_platforms 테이블
ALTER TABLE user_platforms MODIFY platform_id BIGINT AUTO_INCREMENT COMMENT '플랫폼 연결 고유 ID';
ALTER TABLE user_platforms MODIFY user_id BIGINT NOT NULL COMMENT '사용자 ID';
ALTER TABLE user_platforms MODIFY platform_name ENUM('Tidal', 'YouTube Music', 'Apple Music') NOT NULL COMMENT '플랫폼 명';
ALTER TABLE user_platforms MODIFY access_token TEXT COMMENT '액세스 토큰';
ALTER TABLE user_platforms MODIFY refresh_token TEXT COMMENT '리프레시 토큰';
ALTER TABLE user_platforms MODIFY connected_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '연동일시';

-- user_track_ratings 테이블
ALTER TABLE user_track_ratings MODIFY rating TINYINT NOT NULL COMMENT '1:좋아요, 0:보통, -1:싫어요';

-- ai_analysis_logs 테이블
ALTER TABLE ai_analysis_logs MODIFY analysis_result JSON COMMENT '상세 분석 결과';

-- user_genres 테이블
ALTER TABLE user_genres MODIFY preference_level INT DEFAULT 1 COMMENT '선호도 (1-5)';

-- playlist_scored_id 테이블
ALTER TABLE playlist_scored_id MODIFY playlist_id BIGINT NOT NULL COMMENT '플레이리스트 ID';
ALTER TABLE playlist_scored_id MODIFY user_id BIGINT NOT NULL COMMENT '사용자 ID';
ALTER TABLE playlist_scored_id MODIFY ai_score DECIMAL(5,2) DEFAULT 0.00 COMMENT 'AI 추천/검증 점수';
ALTER TABLE playlist_scored_id MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';
ALTER TABLE playlist_scored_id MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

-- track_scored_id 테이블
ALTER TABLE track_scored_id MODIFY track_id BIGINT NOT NULL COMMENT '트랙 ID';
ALTER TABLE track_scored_id MODIFY user_id BIGINT NOT NULL COMMENT '사용자 ID';
ALTER TABLE track_scored_id MODIFY ai_score DECIMAL(5,2) DEFAULT 0.00 COMMENT 'AI 추천/검증 점수';
ALTER TABLE track_scored_id MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시';
ALTER TABLE track_scored_id MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시';

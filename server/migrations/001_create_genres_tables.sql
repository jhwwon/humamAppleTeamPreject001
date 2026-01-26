-- =====================================================
-- MusicSpace - Spotify 기반 음악 장르 테이블 마이그레이션
-- 실행: MySQL Workbench 또는 터미널에서 실행
-- =====================================================

-- 1. 장르 카테고리 테이블
CREATE TABLE IF NOT EXISTS `genre_categories` (
    `category_id` INT NOT NULL AUTO_INCREMENT COMMENT '카테고리 ID',
    `category_code` VARCHAR(50) NOT NULL COMMENT '카테고리 코드',
    `category_name_ko` VARCHAR(100) NOT NULL COMMENT '카테고리명 (한국어)',
    `category_name_en` VARCHAR(100) NOT NULL COMMENT '카테고리명 (영어)',
    `category_icon` VARCHAR(10) DEFAULT NULL COMMENT '카테고리 아이콘',
    `display_order` INT DEFAULT 0 COMMENT '표시 순서',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '활성화 여부',
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uk_category_code` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장르 카테고리 테이블';

-- 2. 음악 장르 마스터 테이블 (Spotify 기반)
CREATE TABLE IF NOT EXISTS `music_genres` (
    `genre_id` INT NOT NULL AUTO_INCREMENT COMMENT '장르 고유 ID',
    `category_id` INT DEFAULT NULL COMMENT '카테고리 ID',
    `genre_code` VARCHAR(50) NOT NULL COMMENT '장르 코드 (Spotify seed)',
    `genre_name_ko` VARCHAR(100) NOT NULL COMMENT '장르명 (한국어)',
    `genre_name_en` VARCHAR(100) NOT NULL COMMENT '장르명 (영어)',
    `genre_icon` VARCHAR(10) DEFAULT NULL COMMENT '장르 아이콘 (이모지)',
    `genre_color` VARCHAR(50) DEFAULT NULL COMMENT '장르 대표 색상 (Tailwind gradient)',
    `display_order` INT DEFAULT 0 COMMENT '표시 순서',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '활성화 여부',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    PRIMARY KEY (`genre_id`),
    UNIQUE KEY `uk_genre_code` (`genre_code`),
    KEY `idx_category` (`category_id`),
    CONSTRAINT `fk_genre_category` FOREIGN KEY (`category_id`) REFERENCES `genre_categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Spotify 기반 음악 장르 마스터 테이블';

-- 3. 사용자-장르 선호도 매핑 테이블
CREATE TABLE IF NOT EXISTS `user_genres` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '매핑 ID',
    `user_id` BIGINT NOT NULL COMMENT '사용자 ID',
    `genre_id` INT NOT NULL COMMENT '장르 ID',
    `preference_level` TINYINT DEFAULT 1 COMMENT '선호도 레벨 (1: 기본, 2: 좋아함, 3: 매우좋아함)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_genre` (`user_id`, `genre_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_genre_id` (`genre_id`),
    CONSTRAINT `fk_user_genres_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_user_genres_genre` FOREIGN KEY (`genre_id`) REFERENCES `music_genres` (`genre_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자별 선호 장르 매핑';

-- =====================================================
-- 4. 카테고리 데이터 삽입
-- =====================================================
INSERT INTO `genre_categories` (`category_code`, `category_name_ko`, `category_name_en`, `category_icon`, `display_order`) VALUES
('popular', '인기 장르', 'Popular', '', 1),
('electronic', '일렉트로닉', 'Electronic', '', 2),
('rock_metal', '락/메탈', 'Rock & Metal', '', 3),
('urban', '어반/힙합', 'Urban & Hip-Hop', '', 4),
('acoustic', '어쿠스틱/포크', 'Acoustic & Folk', '', 5),
('world', '월드뮤직', 'World Music', '', 6),
('mood', '분위기/무드', 'Mood & Vibes', '', 7)
ON DUPLICATE KEY UPDATE 
    `category_name_ko` = VALUES(`category_name_ko`),
    `category_name_en` = VALUES(`category_name_en`);

-- =====================================================
-- 5. Spotify 기반 장르 데이터 삽입
-- =====================================================

-- 인기 장르 (Popular)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'k-pop', 'K-POP', 'K-POP', '', 'from-pink-500 to-purple-500', 1),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'pop', '팝', 'Pop', '', 'from-blue-400 to-cyan-400', 2),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'j-pop', 'J-POP', 'J-POP', '', 'from-red-400 to-pink-400', 3),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'indie', '인디', 'Indie', '', 'from-green-400 to-teal-500', 4),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'indie-pop', '인디팝', 'Indie Pop', '', 'from-emerald-400 to-cyan-400', 5),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'anime', '애니메이션', 'Anime', '', 'from-violet-400 to-purple-500', 6),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'soundtracks', 'OST/사운드트랙', 'Soundtracks', '', 'from-amber-400 to-orange-400', 7),
((SELECT category_id FROM genre_categories WHERE category_code = 'popular'), 'disney', '디즈니', 'Disney', '', 'from-blue-500 to-indigo-500', 8)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 일렉트로닉 (Electronic)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'edm', 'EDM', 'EDM', '', 'from-cyan-400 to-blue-500', 10),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'house', '하우스', 'House', '', 'from-purple-500 to-pink-500', 11),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'deep-house', '딥하우스', 'Deep House', '', 'from-indigo-500 to-purple-500', 12),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'progressive-house', '프로그레시브 하우스', 'Progressive House', '', 'from-blue-500 to-violet-500', 13),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'techno', '테크노', 'Techno', '', 'from-gray-600 to-gray-800', 14),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'trance', '트랜스', 'Trance', '', 'from-cyan-500 to-blue-600', 15),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'dubstep', '덥스텝', 'Dubstep', '', 'from-purple-600 to-indigo-600', 16),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'drum-and-bass', '드럼앤베이스', 'Drum and Bass', '', 'from-orange-500 to-red-500', 17),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'electronic', '일렉트로닉', 'Electronic', '', 'from-violet-500 to-purple-600', 18),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'electro', '일렉트로', 'Electro', '', 'from-yellow-400 to-orange-500', 19),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'synth-pop', '신스팝', 'Synth Pop', '', 'from-pink-400 to-rose-500', 20),
((SELECT category_id FROM genre_categories WHERE category_code = 'electronic'), 'disco', '디스코', 'Disco', '', 'from-fuchsia-500 to-pink-500', 21)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 락/메탈 (Rock & Metal)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'rock', '락', 'Rock', '', 'from-red-500 to-orange-500', 30),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'alt-rock', '얼터너티브 락', 'Alternative Rock', '', 'from-slate-500 to-gray-600', 31),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'hard-rock', '하드락', 'Hard Rock', '', 'from-red-600 to-red-800', 32),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'punk', '펑크', 'Punk', '', 'from-lime-500 to-green-600', 33),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'punk-rock', '펑크락', 'Punk Rock', '', 'from-green-500 to-emerald-600', 34),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'grunge', '그런지', 'Grunge', '', 'from-stone-500 to-stone-700', 35),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'metal', '메탈', 'Metal', '', 'from-gray-700 to-gray-900', 36),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'heavy-metal', '헤비메탈', 'Heavy Metal', '', 'from-zinc-700 to-black', 37),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'metalcore', '메탈코어', 'Metalcore', '', 'from-red-700 to-gray-800', 38),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'emo', '이모', 'Emo', '', 'from-gray-600 to-purple-700', 39),
((SELECT category_id FROM genre_categories WHERE category_code = 'rock_metal'), 'goth', '고스', 'Goth', '', 'from-purple-800 to-gray-900', 40)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 어반/힙합 (Urban & Hip-Hop)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'hip-hop', '힙합', 'Hip-Hop', '', 'from-orange-500 to-red-500', 50),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'r-n-b', 'R&B', 'R&B', '', 'from-purple-500 to-pink-500', 51),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'soul', '소울', 'Soul', '', 'from-amber-500 to-orange-500', 52),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'funk', '펑크', 'Funk', '', 'from-yellow-500 to-orange-500', 53),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'gospel', '가스펠', 'Gospel', '', 'from-yellow-400 to-amber-500', 54),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'reggae', '레게', 'Reggae', '', 'from-green-500 to-yellow-400', 55),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'reggaeton', '레게톤', 'Reggaeton', '', 'from-red-500 to-yellow-500', 56),
((SELECT category_id FROM genre_categories WHERE category_code = 'urban'), 'dancehall', '댄스홀', 'Dancehall', '', 'from-green-400 to-lime-500', 57)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 어쿠스틱/포크 (Acoustic & Folk)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'acoustic', '어쿠스틱', 'Acoustic', '', 'from-amber-400 to-yellow-500', 60),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'folk', '포크', 'Folk', '', 'from-orange-400 to-amber-500', 61),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'singer-songwriter', '싱어송라이터', 'Singer-Songwriter', '', 'from-rose-400 to-pink-500', 62),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'country', '컨트리', 'Country', '', 'from-amber-600 to-orange-500', 63),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'bluegrass', '블루그래스', 'Bluegrass', '', 'from-green-600 to-teal-600', 64),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'blues', '블루스', 'Blues', '', 'from-blue-600 to-indigo-600', 65),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'jazz', '재즈', 'Jazz', '', 'from-amber-500 to-yellow-400', 66),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'classical', '클래식', 'Classical', '', 'from-slate-400 to-gray-500', 67),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'piano', '피아노', 'Piano', '', 'from-gray-400 to-slate-500', 68),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'guitar', '기타', 'Guitar', '', 'from-orange-500 to-amber-600', 69),
((SELECT category_id FROM genre_categories WHERE category_code = 'acoustic'), 'opera', '오페라', 'Opera', '', 'from-red-700 to-rose-800', 70)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 월드뮤직 (World Music)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'latin', '라틴', 'Latin', '', 'from-red-500 to-orange-400', 80),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'salsa', '살사', 'Salsa', '', 'from-red-500 to-yellow-500', 81),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'tango', '탱고', 'Tango', '', 'from-red-600 to-rose-600', 82),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'samba', '삼바', 'Samba', '', 'from-green-500 to-yellow-400', 83),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'brazil', '브라질', 'Brazil', '', 'from-green-500 to-yellow-500', 84),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'bossanova', '보사노바', 'Bossa Nova', '', 'from-teal-400 to-cyan-500', 85),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'afrobeat', '아프로비트', 'Afrobeat', '', 'from-orange-500 to-yellow-500', 86),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'indian', '인디안', 'Indian', '', 'from-orange-500 to-red-500', 87),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'turkish', '터키', 'Turkish', '', 'from-red-500 to-rose-500', 88),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'french', '프렌치', 'French', '', 'from-blue-500 to-red-500', 89),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'british', '브리티시', 'British', '', 'from-blue-600 to-red-600', 90),
((SELECT category_id FROM genre_categories WHERE category_code = 'world'), 'world-music', '월드뮤직', 'World Music', '', 'from-teal-500 to-emerald-500', 91)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- 분위기/무드 (Mood & Vibes)
INSERT INTO `music_genres` (`category_id`, `genre_code`, `genre_name_ko`, `genre_name_en`, `genre_icon`, `genre_color`, `display_order`) VALUES
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'chill', '칠', 'Chill', '', 'from-cyan-400 to-blue-400', 100),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'ambient', '앰비언트', 'Ambient', '', 'from-slate-400 to-blue-400', 101),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'new-age', '뉴에이지', 'New Age', '', 'from-purple-400 to-indigo-400', 102),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'romance', '로맨스', 'Romance', '', 'from-pink-400 to-rose-400', 103),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'sad', '감성', 'Sad', '', 'from-blue-500 to-indigo-500', 104),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'happy', '해피', 'Happy', '', 'from-yellow-400 to-orange-400', 105),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'party', '파티', 'Party', '', 'from-fuchsia-500 to-pink-500', 106),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'dance', '댄스', 'Dance', '', 'from-pink-500 to-purple-500', 107),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'club', '클럽', 'Club', '', 'from-violet-500 to-purple-600', 108),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'groove', '그루브', 'Groove', '', 'from-orange-400 to-red-400', 109),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'sleep', '수면', 'Sleep', '', 'from-indigo-400 to-purple-500', 110),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'study', '공부', 'Study', '', 'from-green-400 to-teal-400', 111),
((SELECT category_id FROM genre_categories WHERE category_code = 'mood'), 'work-out', '운동', 'Work Out', '', 'from-red-500 to-orange-500', 112)
ON DUPLICATE KEY UPDATE `genre_name_ko` = VALUES(`genre_name_ko`);

-- =====================================================
-- 확인 쿼리
-- =====================================================
-- SELECT c.category_name_ko, g.genre_code, g.genre_name_ko 
-- FROM music_genres g 
-- LEFT JOIN genre_categories c ON g.category_id = c.category_id 
-- ORDER BY c.display_order, g.display_order;

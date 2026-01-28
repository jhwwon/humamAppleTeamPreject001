# MusicSpace Docker 배포 가이드

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  frontend   │    │   backend   │    │     db      │     │
│  │   (Nginx)   │───▶│  (Node.js)  │───▶│  (MariaDB)  │     │
│  │   :80       │    │   :3001     │    │   :3306     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                            │                               │
│                   ┌────────┴────────┐                      │
│                   │ Volume: images  │                      │
│                   │ artists/covers/ │                      │
│                   └─────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. 사전 요구사항

### Ubuntu에 Docker 설치

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 현재 사용자를 docker 그룹에 추가 (로그아웃 후 재로그인 필요)
sudo usermod -aG docker $USER

# Docker Compose 설치 (최신 버전)
sudo apt install -y docker-compose-plugin

# 버전 확인
docker --version
docker compose version
```

---

## 2. 프로젝트 클론

```bash
cd /var/www
sudo git clone https://github.com/imorangepie20/humamAppleTeamPreject001.git musicspace
cd musicspace
sudo chown -R $USER:$USER /var/www/musicspace
```

---

## 3. 환경 변수 설정

```bash
# 환경 변수 파일 생성
cp .env.docker .env
nano .env
```

**.env 파일 수정:**

```env
# Database (원하는 비밀번호로 변경)
DB_ROOT_PASSWORD=your_secure_root_password
DB_NAME=music_space_db
DB_USER=musicspace
DB_PASSWORD=your_secure_password

# JWT Secret (필수 변경! 아래 명령어로 생성)
# openssl rand -base64 32
JWT_SECRET=생성된_랜덤_시크릿_키

# Tidal API
TIDAL_CLIENT_ID=your_tidal_client_id
TIDAL_CLIENT_SECRET=your_tidal_client_secret

# Spotify API
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret

# YouTube API
YOUTUBE_KEY=your_youtube_api_key

# Last.fm API
LASTFM_API_KEY=your_lastfm_api_key
```

---

## 4. Docker 빌드 및 실행

### 4.1 빌드 및 실행 (한 번에)

```bash
cd /var/www/musicspace

# 빌드 및 백그라운드 실행
docker compose up -d --build
```

### 4.2 개별 명령어

```bash
# 이미지 빌드만
docker compose build

# 컨테이너 시작
docker compose up -d

# 로그 확인
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f db
```

### 4.3 실행 확인

```bash
# 컨테이너 상태 확인
docker compose ps

# 예상 출력:
# NAME                  STATUS         PORTS
# musicspace-db         Up (healthy)   0.0.0.0:3306->3306/tcp
# musicspace-backend    Up             0.0.0.0:3001->3001/tcp
# musicspace-frontend   Up             0.0.0.0:80->80/tcp
```

---

## 5. 데이터베이스 초기화

DB 덤프 파일이 자동으로 로드됩니다. 수동으로 하려면:

```bash
# 컨테이너 내부에서 SQL 실행
docker compose exec db mysql -u musicspace -p music_space_db < /docker-entrypoint-initdb.d/init.sql

# 또는 호스트에서 직접
docker compose exec -T db mysql -u musicspace -p'your_password' music_space_db < music_space_db_dump.sql
```

---

## 6. 헬스체크

```bash
# API 헬스체크
curl http://localhost/api/health
# 응답: {"status":"ok","timestamp":"..."}

# 프론트엔드 확인
curl -I http://localhost
# HTTP/1.1 200 OK

# DB 연결 확인
docker compose exec db mysql -u musicspace -p -e "SELECT 1;"
```

---

## 7. 주요 명령어

| 작업 | 명령어 |
|------|--------|
| 시작 | `docker compose up -d` |
| 중지 | `docker compose down` |
| 재시작 | `docker compose restart` |
| 로그 | `docker compose logs -f` |
| 상태 | `docker compose ps` |
| 빌드 | `docker compose build` |
| 재빌드 후 시작 | `docker compose up -d --build` |
| 볼륨 포함 삭제 | `docker compose down -v` |
| 컨테이너 쉘 접속 | `docker compose exec backend sh` |
| DB 접속 | `docker compose exec db mysql -u musicspace -p` |

---

## 8. 업데이트 배포

```bash
cd /var/www/musicspace

# 최신 코드 가져오기
git pull origin main

# 재빌드 및 재시작
docker compose up -d --build

# 또는 특정 서비스만
docker compose up -d --build frontend
docker compose up -d --build backend
```

---

## 9. 볼륨 및 데이터

### 9.1 이미지 파일

이미지 파일은 호스트의 `./public/images/`에 저장됩니다:

```bash
ls -la ./public/images/
# artists/  - 아티스트 이미지
# covers/   - 플레이리스트 커버
# tracks/   - 트랙 아트워크
```

### 9.2 데이터베이스

DB 데이터는 Docker 볼륨에 저장됩니다:

```bash
# 볼륨 확인
docker volume ls

# 볼륨 상세 정보
docker volume inspect musicspace_mariadb_data
```

---

## 10. 백업

### 10.1 데이터베이스 백업

```bash
# 백업
docker compose exec db mysqldump -u musicspace -p'password' music_space_db > backup_$(date +%Y%m%d).sql

# 복원
docker compose exec -T db mysql -u musicspace -p'password' music_space_db < backup_20260128.sql
```

### 10.2 이미지 백업

```bash
tar -czf images_backup_$(date +%Y%m%d).tar.gz ./public/images/
```

---

## 11. 방화벽 설정

```bash
# UFW 사용 시
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw status
```

---

## 12. SSL 인증서 (HTTPS)

### Certbot + Nginx Proxy 방식

```bash
# Certbot 설치
sudo apt install -y certbot

# 인증서 발급 (standalone 모드 - 잠시 80 포트 중지 필요)
docker compose stop frontend
sudo certbot certonly --standalone -d your_domain.com
docker compose start frontend
```

### docker-compose.yml에 SSL 추가 (선택)

```yaml
frontend:
  # ...
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /etc/letsencrypt:/etc/letsencrypt:ro
```

---

## 13. 트러블슈팅

### 문제: 컨테이너가 시작되지 않음

```bash
# 로그 확인
docker compose logs db
docker compose logs backend

# 컨테이너 상태 확인
docker compose ps -a
```

### 문제: DB 연결 실패

```bash
# DB 컨테이너가 healthy인지 확인
docker compose ps

# DB 로그 확인
docker compose logs db

# 환경 변수 확인
docker compose exec backend env | grep DB
```

### 문제: 이미지가 안 보임

```bash
# 이미지 디렉토리 권한 확인
ls -la ./public/images/

# 백엔드 컨테이너에서 확인
docker compose exec backend ls -la /app/public/images/
```

### 문제: 502 Bad Gateway

```bash
# 백엔드 상태 확인
docker compose ps backend
docker compose logs backend

# 백엔드 재시작
docker compose restart backend
```

### 문제: 포트 충돌

```bash
# 사용 중인 포트 확인
sudo lsof -i :80
sudo lsof -i :3001
sudo lsof -i :3306

# 기존 프로세스 중지 후 재시작
docker compose down
docker compose up -d
```

---

## 14. 개발 환경 vs 프로덕션

### 개발 환경 (로컬)

```bash
# DB만 Docker로 실행
docker compose up -d db

# 백엔드/프론트엔드는 로컬에서
cd server && npm run dev
cd .. && npm run dev
```

### 프로덕션 환경

```bash
# 전체 스택 Docker로 실행
docker compose up -d --build
```

---

## 15. 리소스 모니터링

```bash
# 컨테이너 리소스 사용량
docker stats

# 디스크 사용량
docker system df

# 미사용 이미지/볼륨 정리
docker system prune -a
```

---

## 16. 최종 체크리스트

- [ ] Docker & Docker Compose 설치됨
- [ ] 프로젝트 클론됨
- [ ] .env 파일 설정됨 (비밀번호 변경!)
- [ ] `docker compose up -d --build` 실행
- [ ] 모든 컨테이너 running 상태
- [ ] `curl http://localhost/api/health` 응답 OK
- [ ] 웹 브라우저에서 접속 확인
- [ ] 이미지 로딩 확인
- [ ] 방화벽 포트 열림 (80)

---

## 빠른 시작 요약

```bash
# 1. Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# 2. 프로젝트 클론
cd /var/www && sudo git clone https://github.com/imorangepie20/humamAppleTeamPreject001.git musicspace && cd musicspace

# 3. 환경 변수 설정
cp .env.docker .env && nano .env

# 4. 실행
docker compose up -d --build

# 5. 확인
docker compose ps
curl http://localhost/api/health
```

---

**작성일:** 2026-01-28
**버전:** 1.0

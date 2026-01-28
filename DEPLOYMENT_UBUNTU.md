# MusicSpace Ubuntu Server 배포 가이드 (Docker)

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Ubuntu Server + Docker                   │
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

**컨테이너 구성:**
- `musicspace-frontend` - Nginx (프론트엔드 + 리버스 프록시) :80
- `musicspace-backend` - Node.js API 서버 :3001
- `musicspace-db` - MariaDB 데이터베이스 :3306

---

## 1. 사전 요구사항

### 1.1 Docker 설치

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 재로그인 또는
newgrp docker

# Docker Compose 설치
sudo apt install -y docker-compose-plugin

# 버전 확인
docker --version
docker compose version
```

---

## 2. 프로젝트 배포

### 2.1 프로젝트 클론

```bash
# 배포 디렉토리
cd /home/$USER
git clone https://github.com/imorangepie20/humamAppleTeamPreject001.git
cd humamAppleTeamPreject001
```

### 2.2 환경 변수 설정

```bash
cp .env.docker .env
nano .env
```

**.env 파일 내용:**

```env
# Database
DB_ROOT_PASSWORD=your_secure_root_password
DB_NAME=music_space_db
DB_USER=musicspace
DB_PASSWORD=your_secure_password

# JWT Secret (필수 변경!)
# 생성: openssl rand -base64 32
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

### 2.3 Docker 빌드 및 실행

```bash
# 빌드 및 백그라운드 실행
docker compose up -d --build

# 실행 확인
docker compose ps
```

---

## 3. 주요 명령어

### 3.1 컨테이너 관리

| 작업 | 명령어 |
|------|--------|
| 전체 시작 | `docker compose up -d` |
| 전체 중지 | `docker compose down` |
| 전체 재시작 | `docker compose restart` |
| 상태 확인 | `docker compose ps` |
| 로그 확인 | `docker compose logs -f` |

### 3.2 개별 서비스 관리

```bash
# Frontend (Nginx)
docker compose stop frontend
docker compose start frontend
docker compose restart frontend
docker compose logs -f frontend

# Backend (Node.js)
docker compose stop backend
docker compose start backend
docker compose restart backend
docker compose logs -f backend

# Database (MariaDB)
docker compose stop db
docker compose start db
docker compose logs -f db
```

### 3.3 컨테이너 접속

```bash
# 백엔드 쉘 접속
docker compose exec backend sh

# DB 접속
docker compose exec db mysql -u musicspace -p music_space_db
```

---

## 4. 업데이트 배포

```bash
cd ~/humamAppleTeamPreject001

# 최신 코드 가져오기
git pull origin main

# 재빌드 및 재시작
docker compose up -d --build
```

---

## 5. 헬스체크

```bash
# API 상태 확인
curl http://localhost/api/health

# 컨테이너 상태
docker compose ps

# 로그 확인
docker compose logs --tail=50
```

---

## 6. 방화벽 설정

```bash
# UFW 활성화
sudo ufw enable

# 포트 허용
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 상태 확인
sudo ufw status
```

---

## 7. SSL 인증서 (HTTPS)

### Let's Encrypt 발급

```bash
# Certbot 설치
sudo apt install -y certbot

# 프론트엔드 컨테이너 잠시 중지
docker compose stop frontend

# 인증서 발급
sudo certbot certonly --standalone -d your_domain.com

# 프론트엔드 재시작
docker compose start frontend
```

---

## 8. 백업

### 8.1 데이터베이스 백업

```bash
# 백업
docker compose exec db mysqldump -u musicspace -p'password' music_space_db > backup_$(date +%Y%m%d).sql

# 복원
docker compose exec -T db mysql -u musicspace -p'password' music_space_db < backup.sql
```

### 8.2 이미지 백업

```bash
tar -czf images_backup.tar.gz ./public/images/
```

---

## 9. 트러블슈팅

### 문제: 컨테이너가 시작되지 않음

```bash
# 로그 확인
docker compose logs backend
docker compose logs db

# 재빌드
docker compose up -d --build
```

### 문제: 502 Bad Gateway

```bash
# 백엔드 상태 확인
docker compose ps backend
docker compose logs backend

# 백엔드 재시작
docker compose restart backend
```

### 문제: DB 연결 실패

```bash
# DB 상태 확인
docker compose ps db
docker compose logs db

# DB 컨테이너가 healthy인지 확인
docker compose ps
```

### 문제: 포트 충돌 (80 포트 사용 중)

```bash
# 80번 포트 사용 프로세스 확인
sudo lsof -i :80

# Apache 중지 (사용 중이면)
sudo systemctl stop apache2
sudo systemctl disable apache2

# 또는 기존 Nginx 중지
sudo systemctl stop nginx
```

### 문제: 이미지가 안 보임

```bash
# 이미지 디렉토리 확인
ls -la ./public/images/

# 권한 설정
sudo chown -R $USER:$USER ./public/images/
```

---

## 10. 모니터링

```bash
# 컨테이너 리소스 사용량
docker stats

# 디스크 사용량
docker system df

# 미사용 리소스 정리
docker system prune -a
```

---

## 11. 빠른 시작 요약

```bash
# 1. Docker 설치
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker

# 2. 프로젝트 클론
git clone https://github.com/imorangepie20/humamAppleTeamPreject001.git
cd humamAppleTeamPreject001

# 3. 환경변수 설정
cp .env.docker .env && nano .env

# 4. 실행
docker compose up -d --build

# 5. 확인
docker compose ps
curl http://localhost/api/health
```

---

## 12. 체크리스트

- [ ] Docker & Docker Compose 설치됨
- [ ] 프로젝트 클론됨
- [ ] `.env` 파일 설정됨 (비밀번호 변경!)
- [ ] `docker compose up -d --build` 실행
- [ ] 모든 컨테이너 running 상태
- [ ] API 헬스체크 OK
- [ ] 웹 브라우저 접속 확인
- [ ] 방화벽 포트 열림 (80)

---

**작성일:** 2026-01-29
**버전:** 2.0 (Docker 기반)

# Backend Dockerfile
FROM node:20-alpine

WORKDIR /app

# 의존성 설치
COPY package*.json ./
RUN npm ci --only=production

# 소스 복사
COPY . .

# 이미지 디렉토리 생성
RUN mkdir -p /app/public/images/artists /app/public/images/covers /app/public/images/tracks

EXPOSE 3001

CMD ["node", "src/index.js"]

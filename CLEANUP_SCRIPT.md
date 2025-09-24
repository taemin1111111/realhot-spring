# 🧹 배포 전 정리 스크립트

## 제거해야 할 파일들

### 1. **개발용 업로드 파일들**
```bash
# 개발 중 업로드된 테스트 이미지들 (운영에서는 필요 없음)
rm -rf src/main/webapp/uploads/course/*.jpg
rm -rf src/main/webapp/uploads/course/*.png
rm -rf src/main/webapp/uploads/hpostsave/*.jpg
rm -rf src/main/webapp/uploads/hpostsave/*.png
rm -rf src/main/webapp/uploads/noticesave/*.png
rm -rf src/main/webapp/uploads/places/1/*.jpg
rm -rf src/main/webapp/uploads/places/1/*.png
rm -rf src/main/webapp/uploads/mdsave/*.png
```

### 2. **빌드 아티팩트**
```bash
# Maven 빌드 결과물 (재빌드 시 자동 생성)
rm -rf target/
rm -rf .mvn/wrapper/maven-wrapper.jar
```

### 3. **IDE 설정 파일들**
```bash
# IDE별 설정 파일들 (배포에 불필요)
rm -rf .idea/
rm -rf .vscode/
rm -rf *.iml
rm -rf .project
rm -rf .classpath
rm -rf .settings/
```

### 4. **로그 파일들**
```bash
# 로그 파일들 (운영에서는 별도 로그 서버 사용)
rm -rf logs/
rm -rf *.log
```

### 5. **임시 파일들**
```bash
# 임시 파일들
rm -rf *.tmp
rm -rf *.temp
rm -rf .DS_Store
rm -rf Thumbs.db
```

## 배포용 .gitignore 추가

```gitignore
# 개발용 파일들
src/main/webapp/uploads/
target/
.idea/
.vscode/
*.iml
.project
.classpath
.settings/
logs/
*.log
*.tmp
*.temp
.DS_Store
Thumbs.db

# 환경변수 파일
.env
.env.local
.env.production

# 백업 파일들
*.backup
*.bak
*.old
```

## 운영 환경 업로드 디렉토리 설정

운영 환경에서는 다음과 같이 설정해야 합니다:

```properties
# application-prod.properties
# 운영 환경 업로드 경로 (절대 경로 사용)
app.upload.dir=/var/www/uploads/hpostsave
file.upload.notice-path=/var/www/uploads/notices
file.upload.place-path=/var/www/uploads/places
file.upload.md-path=/var/www/uploads/mdphotos
file.upload.community-path=/var/www/uploads/community
file.upload.course-path=/var/www/uploads/course
```

## 권한 설정

```bash
# 업로드 디렉토리 생성 및 권한 설정
sudo mkdir -p /var/www/uploads/{hpostsave,notices,places,mdphotos,community,course}
sudo chown -R www-data:www-data /var/www/uploads/
sudo chmod -R 755 /var/www/uploads/
```

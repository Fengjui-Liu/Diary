# 日記應用後端 API (可選)

這是一個基於 Spring Boot 的 REST API 後端，作為 Firebase 的替代方案。

## 功能說明

此後端提供以下功能：
- 用戶註冊和登入（JWT 認證）
- 日記的 CRUD 操作
- 圖片上傳管理
- RESTful API 設計

## 技術棧

- Java 17
- Spring Boot 3.2.1
- Spring Security + JWT
- Spring Data JPA
- MySQL 資料庫
- Maven

## 快速開始

### 1. 環境要求

- JDK 17 或更高版本
- Maven 3.6+
- MySQL 8.0+

### 2. 資料庫設置

創建資料庫：
```sql
CREATE DATABASE diary_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 配置

編輯 `src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/diary_db
    username: your_username
    password: your_password

jwt:
  secret: your-secure-secret-key
```

或使用環境變數：
```bash
export DB_USERNAME=your_username
export DB_PASSWORD=your_password
export JWT_SECRET=your-secure-secret-key
```

### 4. 運行

```bash
# 編譯
mvn clean install

# 運行
mvn spring-boot:run

# 或使用 jar
java -jar target/diary-backend-1.0.0.jar
```

API 將運行在 http://localhost:8080/api

## API 端點

### 認證

```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
```

### 日記管理

```
GET    /api/diaries              - 獲取所有日記
GET    /api/diaries/{id}         - 獲取單個日記
POST   /api/diaries              - 創建日記
PUT    /api/diaries/{id}         - 更新日記
DELETE /api/diaries/{id}         - 刪除日記
GET    /api/diaries/date/{date}  - 按日期查詢
GET    /api/diaries/search?q=    - 搜尋日記
```

### 圖片管理

```
POST   /api/images/upload        - 上傳圖片
DELETE /api/images/{filename}    - 刪除圖片
```

## 資料模型

### DiaryEntry

```json
{
  "id": "uuid",
  "userId": "uuid",
  "date": "2024-01-15",
  "mood": "很棒",
  "weather": "晴朗",
  "content": "今天的日記內容...",
  "imagePath": "https://...",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

### User

```json
{
  "id": "uuid",
  "email": "user@example.com",
  "displayName": "使用者名稱",
  "photoUrl": "https://...",
  "createdAt": "2024-01-01T00:00:00",
  "active": true
}
```

## 部署

### Docker 部署

```bash
# 構建 Docker 映像
docker build -t diary-backend .

# 運行容器
docker run -d \
  -p 8080:8080 \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=password \
  -e JWT_SECRET=secret \
  diary-backend
```

### 雲端部署

支援部署到：
- Heroku
- AWS Elastic Beanstalk
- Google Cloud Platform
- Azure App Service

## 注意事項

1. **安全性**：
   - 生產環境請更改 JWT Secret
   - 使用 HTTPS
   - 設置正確的 CORS 配置

2. **性能優化**：
   - 啟用資料庫連接池
   - 使用 Redis 緩存
   - 配置 CDN 處理圖片

3. **監控**：
   - 集成 Spring Boot Actuator
   - 使用日誌聚合工具

## 授權

MIT License

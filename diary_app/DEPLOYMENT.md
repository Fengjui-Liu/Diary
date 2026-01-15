# 部署指南 🚀

本指南將幫助您將日記應用部署到各個平台。

## 目錄

- [Web 部署](#web-部署)
- [Android 部署](#android-部署)
- [iOS 部署](#ios-部署)
- [Firebase 設置](#firebase-設置)
- [後端部署（可選）](#後端部署)

---

## 📋 部署前準備

### 1. 完成 Firebase 配置

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 安裝 FlutterFire CLI
dart pub global activate flutterfire_cli

# 登入 Firebase
firebase login

# 配置專案
flutterfire configure
```

選擇或創建 Firebase 專案，這會自動配置：
- Android (`android/app/google-services.json`)
- iOS (`ios/Runner/GoogleService-Info.plist`)
- Web (更新 `lib/firebase_options.dart`)

### 2. 啟用 Firebase 服務

在 [Firebase Console](https://console.firebase.google.com/) 中：

1. **Authentication**
   - 啟用 Email/Password 登入方式

2. **Firestore Database**
   - 創建資料庫（選擇區域）
   - 設置安全規則：
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. **Storage**
   - 啟用 Cloud Storage
   - 設置安全規則：
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

---

## 🌐 Web 部署

### 方法 1: Firebase Hosting（推薦）

```bash
# 1. 構建 Web 版本
flutter build web --release

# 2. 初始化 Firebase Hosting
firebase init hosting

# 選擇以下配置：
# - Public directory: build/web
# - Configure as single-page app: Yes
# - Set up automatic builds: No
# - Overwrite index.html: No

# 3. 部署
firebase deploy --only hosting
```

部署成功後，應用將可在 `https://your-project.web.app` 訪問。

### 方法 2: Vercel

```bash
# 1. 安裝 Vercel CLI
npm i -g vercel

# 2. 構建應用
flutter build web --release

# 3. 部署
cd build/web
vercel --prod
```

### 方法 3: Netlify

1. 在 Netlify 控制台創建新站點
2. 連接 Git 倉庫
3. 設置構建命令：`flutter build web --release`
4. 設置發布目錄：`build/web`
5. 點擊部署

### 自定義域名

在 Firebase Hosting 或 Vercel/Netlify 控制台添加自定義域名並配置 DNS。

---

## 📱 Android 部署

### Google Play Store 上架

#### 1. 生成簽名密鑰

```bash
# 創建密鑰庫
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 記住密碼和別名！
```

#### 2. 配置簽名

創建 `android/key.properties`:

```properties
storePassword=你的密碼
keyPassword=你的密碼
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

編輯 `android/app/build.gradle`：

```gradle
// 在 android {} 區塊前添加
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 3. 構建 App Bundle

```bash
# 生成 App Bundle（推薦）
flutter build appbundle --release

# 或生成 APK
flutter build apk --release
```

輸出位置：
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

#### 4. 準備上架資料

需要準備：
- 應用圖標（512x512 PNG）
- 功能圖片（1024x500）
- 螢幕截圖（至少 2 張，手機和平板各一組）
- 應用說明（繁體中文）
- 隱私政策 URL

#### 5. 創建 Play Console 帳號

1. 前往 [Google Play Console](https://play.google.com/console/)
2. 支付 $25 一次性註冊費
3. 創建應用程式
4. 填寫應用資訊
5. 上傳 App Bundle
6. 提交審核

審核通常需要 1-3 天。

### 測試分發

使用 Firebase App Distribution 進行內部測試：

```bash
# 1. 安裝 Firebase CLI
npm install -g firebase-tools

# 2. 登入
firebase login

# 3. 構建 APK
flutter build apk --release

# 4. 上傳到 App Distribution
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers
```

---

## 🍎 iOS 部署

### App Store 上架

#### 1. 環境要求

- Mac 電腦（必需）
- Xcode 14+
- Apple Developer 帳號（$99/年）

#### 2. 配置 Xcode

```bash
# 1. 打開 Xcode 專案
open ios/Runner.xcworkspace

# 2. 在 Xcode 中配置：
# - Signing & Capabilities > Team（選擇你的團隊）
# - Bundle Identifier（例：com.yourcompany.diary）
# - Version 和 Build Number
```

#### 3. 配置應用資訊

編輯 `ios/Runner/Info.plist`，確保包含：
- Bundle display name
- Privacy 權限說明
- 支援的設備方向

#### 4. 準備圖標和啟動畫面

使用工具生成：
- App Icon（1024x1024）
- Launch Screen

可以使用 [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) 套件。

#### 5. 構建 Archive

```bash
# 1. 清理構建
flutter clean

# 2. 獲取依賴
flutter pub get

# 3. 構建 iOS 版本
flutter build ios --release

# 4. 在 Xcode 中創建 Archive
# Product > Archive

# 5. 上傳到 App Store Connect
# Window > Organizer > Distribute App
```

#### 6. App Store Connect 設置

1. 前往 [App Store Connect](https://appstoreconnect.apple.com/)
2. 創建新應用
3. 填寫應用資訊：
   - 名稱、副標題、描述
   - 螢幕截圖（iPhone 和 iPad）
   - 分類、年齡分級
   - 隱私政策 URL
4. 提交審核

審核通常需要 1-7 天。

### TestFlight 測試

在 App Store Connect 中：
1. 選擇應用
2. 前往 TestFlight 標籤
3. 添加測試人員
4. 分享測試連結

---

## 🔥 Firebase 設置細節

### 免費額度

Firebase 免費方案包含：
- Authentication: 無限制
- Firestore: 1GB 儲存，50K 讀取/天
- Storage: 5GB 儲存，1GB 下載/天
- Hosting: 10GB 流量/月

對於個人應用來說通常足夠。

### 安全規則優化

#### Firestore 規則

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用戶只能訪問自己的數據
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /diaries/{diaryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;

        // 限制文件大小
        allow create, update: if request.resource.size() < 1048576; // 1MB
      }
    }
  }
}
```

#### Storage 規則

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/images/{imageId} {
      // 只有所有者可以讀寫
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 限制文件大小和類型
      allow write: if request.resource.size < 10 * 1024 * 1024  // 10MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### 性能優化

1. **啟用持久化**
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

2. **使用索引**

在 Firebase Console 中為常用查詢創建索引。

3. **批次操作**

```dart
final batch = FirebaseFirestore.instance.batch();
// 批次寫入操作
await batch.commit();
```

---

## 🖥️ 後端部署（可選）

如果使用 Spring Boot 後端：

### Heroku 部署

```bash
# 1. 登入 Heroku
heroku login

# 2. 創建應用
heroku create your-app-name

# 3. 添加資料庫
heroku addons:create jawsdb:kitefin

# 4. 設置環境變數
heroku config:set JWT_SECRET=your-secret-key

# 5. 部署
git push heroku main
```

### Docker 部署

```dockerfile
FROM openjdk:17-slim
COPY target/diary-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```bash
docker build -t diary-backend .
docker run -d -p 8080:8080 diary-backend
```

---

## ✅ 上架前檢查清單

### 通用
- [ ] 更新版本號
- [ ] 測試所有功能
- [ ] 檢查錯誤處理
- [ ] 準備隱私政策
- [ ] 準備使用條款

### Android
- [ ] 配置簽名密鑰
- [ ] 測試 Release 版本
- [ ] 準備螢幕截圖
- [ ] 填寫商店描述
- [ ] 設置年齡分級

### iOS
- [ ] 配置 Apple Developer 帳號
- [ ] 設置 Bundle ID
- [ ] 準備 App Icon
- [ ] 測試 Archive
- [ ] 準備審核資訊

### Web
- [ ] 配置自定義域名
- [ ] 設置 HTTPS
- [ ] 優化 SEO
- [ ] 測試不同瀏覽器

---

## 🔧 常見問題

### Q: Firebase 配置錯誤？
檢查 `google-services.json` 和 `GoogleService-Info.plist` 是否正確放置。

### Q: iOS 構建失敗？
執行 `cd ios && pod install && cd ..`

### Q: Android 簽名失敗？
確認 `key.properties` 路徑和密碼正確。

### Q: Web 版本載入慢？
啟用 PWA 快取和預加載。

---

## 📊 監控和分析

### Firebase Analytics

已自動集成，查看數據：
1. 前往 Firebase Console
2. 選擇 Analytics
3. 查看用戶行為、留存率等

### Crashlytics

添加崩潰報告：
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.9
```

```dart
// main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

---

## 🎉 完成！

恭喜！您的日記應用現在已經可以上架了。

記得：
- 定期更新應用
- 回應用戶評論
- 監控性能和崩潰
- 持續改進功能

祝您的應用成功！ 🚀

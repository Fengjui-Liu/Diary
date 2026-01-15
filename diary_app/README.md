# 我的日記本 📔

一個功能完整的跨平台日記應用，支援 Web、iOS 和 Android。

## ✨ 功能特色

### 核心功能
- 📝 **日記編寫** - 記錄每天的心情、天氣和內容
- 📅 **日曆視圖** - 以日曆形式瀏覽所有日記
- 🖼️ **圖片上傳** - 為日記添加照片記憶
- 🔍 **搜尋功能** - 快速找到想看的日記
- 💾 **離線緩存** - 即使沒有網路也能查看日記
- 🔐 **雙重認證** - 支援本地密碼和雲端帳號登入

### 特色功能
- 😊 **心情記錄** - 5種心情選項（很棒、普通、超好、難過、爆炸了）
- ☀️ **天氣記錄** - 5種天氣狀態（晴朗、多雲、下雨、雷雨、下雪）
- 📊 **統計分析** - 心情和天氣的統計數據
- 🎨 **自適應主題** - 支援深色/淺色模式
- 📱 **響應式設計** - 適配各種螢幕尺寸

## 🛠️ 技術架構

### 前端技術
- **框架**: Flutter 3.0+
- **狀態管理**: Provider
- **UI組件**: Material Design 3
- **本地存儲**: SQLite + SharedPreferences
- **圖片處理**: image_picker, cached_network_image

### 後端技術
- **認證**: Firebase Authentication
- **資料庫**: Cloud Firestore
- **文件存儲**: Firebase Storage
- **備用方案**: Spring Boot REST API (可選)

### 支援平台
- 🌐 **Web** - PWA支援，可安裝到桌面
- 📱 **Android** - Android 5.0 (API 21) 以上
- 🍎 **iOS** - iOS 12.0 以上

## 📦 專案結構

```
diary_app/
├── lib/
│   ├── models/           # 資料模型
│   │   ├── diary_entry.dart
│   │   └── user_model.dart
│   ├── screens/          # 頁面
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── edit_diary_screen.dart
│   │   └── calendar_screen.dart
│   ├── services/         # 業務邏輯
│   │   ├── auth_service.dart
│   │   └── diary_service.dart
│   ├── widgets/          # 可重用組件
│   │   ├── mood_selector.dart
│   │   └── weather_selector.dart
│   ├── utils/            # 工具類
│   │   └── theme.dart
│   ├── firebase_options.dart
│   └── main.dart
├── android/              # Android 配置
├── ios/                  # iOS 配置
├── web/                  # Web 配置
├── assets/               # 資源文件
│   ├── fonts/
│   └── images/
└── pubspec.yaml          # 依賴配置
```

## 🚀 快速開始

### 環境要求

```bash
# Flutter SDK
flutter --version
# Flutter 3.0.0 或更高版本

# 檢查環境
flutter doctor
```

### 安裝步驟

1. **克隆專案**
```bash
git clone <repository-url>
cd diary_app
```

2. **安裝依賴**
```bash
flutter pub get
```

3. **配置 Firebase**

   a. 安裝 FlutterFire CLI
   ```bash
   dart pub global activate flutterfire_cli
   ```

   b. 登入 Firebase
   ```bash
   firebase login
   ```

   c. 配置專案
   ```bash
   flutterfire configure
   ```

   這會自動生成 `lib/firebase_options.dart` 文件

4. **運行應用**

   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d android

   # iOS (需要 Mac)
   flutter run -d ios
   ```

## 📱 打包部署

### Android APK

```bash
# 生成 APK
flutter build apk --release

# 生成 App Bundle (推薦用於 Google Play)
flutter build appbundle --release
```

APK 位置: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
# 需要在 Mac 上執行
flutter build ios --release

# 使用 Xcode 打開專案
open ios/Runner.xcworkspace
```

然後在 Xcode 中 Archive 並上傳到 App Store。

### Web 部署

```bash
# 構建 Web 版本
flutter build web --release

# 部署到 Firebase Hosting
firebase deploy --only hosting

# 或部署到其他平台（Vercel, Netlify, GitHub Pages等）
```

## 🔧 配置說明

### Firebase 設置

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 創建新專案或選擇現有專案
3. 啟用以下服務：
   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
4. 在專案設置中添加 Web、Android、iOS 應用
5. 下載配置文件並放置到相應位置

### 資料庫結構

```
users/
  {userId}/
    diaries/
      {diaryId}/
        - date: DateTime
        - mood: String
        - weather: String
        - content: String
        - imagePath: String
        - createdAt: DateTime
        - updatedAt: DateTime
```

### Storage 結構

```
users/
  {userId}/
    images/
      {timestamp}.jpg
```

## 📝 使用說明

### 首次使用

1. 打開應用
2. 選擇「使用雲端帳號登入」或設置本地密碼
3. 如果選擇雲端登入，需要註冊或登入 Firebase 帳號
4. 開始記錄您的第一篇日記！

### 新增日記

1. 點擊首頁的「新增日記」按鈕
2. 選擇日期（預設為今天）
3. 選擇心情和天氣
4. 輸入日記內容
5. （可選）添加圖片
6. 點擊「儲存日記」

### 查看日記

- **列表模式**: 在首頁向下滾動瀏覽所有日記
- **日曆模式**: 點擊右上角日曆圖標，以日曆形式查看
- **搜尋**: 使用搜尋框快速找到特定日記

### 編輯/刪除

- 點擊任意日記卡片即可編輯
- 在編輯頁面點擊刪除圖標可刪除日記

## 🎨 自定義

### 修改主題顏色

編輯 `lib/utils/theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6C63FF);  // 主色
static const Color secondaryColor = Color(0xFFFF6584); // 副色
static const Color accentColor = Color(0xFF4CAF50);   // 強調色
```

### 添加新的心情/天氣選項

編輯 `lib/models/diary_entry.dart`:

```dart
static const List<Map<String, String>> moodOptions = [
  {'emoji': '😊', 'label': '很棒'},
  // 添加更多...
];
```

## 🐛 常見問題

### Q: Firebase 配置失敗？
A: 確保已正確執行 `flutterfire configure` 並選擇了正確的 Firebase 專案。

### Q: 圖片上傳失敗？
A: 檢查 Firebase Storage 規則，確保已登入的用戶有寫入權限。

### Q: iOS 無法構建？
A: 需要 Mac 電腦和 Xcode，並確保已安裝 CocoaPods: `sudo gem install cocoapods`

### Q: Web 版本無法載入？
A: 確保已在 `web/index.html` 中正確配置 Firebase SDK。

## 📄 授權

此專案採用 MIT 授權條款。

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

## 📧 聯繫方式

如有問題或建議，請通過以下方式聯繫：
- Email: your-email@example.com
- GitHub Issues: [專案問題頁面]

## 🙏 致謝

- Flutter 團隊提供的優秀框架
- Firebase 提供的後端服務
- 所有開源貢獻者

---

**祝您使用愉快！記錄美好生活從現在開始 ✨**

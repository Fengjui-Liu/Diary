class DiaryEntry {
  final String? id;
  final DateTime date;
  final String mood;
  final String weather;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.weather,
    required this.content,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // 心情選項
  static const List<Map<String, String>> moodOptions = [
    {'emoji': '😊', 'label': '很棒'},
    {'emoji': '🙂', 'label': '普通'},
    {'emoji': '😀', 'label': '超好'},
    {'emoji': '😕', 'label': '難過'},
    {'emoji': '🤯', 'label': '爆炸了'},
  ];

  // 天氣選項
  static const List<Map<String, String>> weatherOptions = [
    {'emoji': '☀️', 'label': '晴朗'},
    {'emoji': '⛅', 'label': '多雲'},
    {'emoji': '🌧', 'label': '下雨'},
    {'emoji': '⛈', 'label': '雷雨'},
    {'emoji': '❄️', 'label': '下雪'},
  ];

  // 從JSON轉換
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      weather: json['weather'] as String,
      content: json['content'] as String,
      imagePath: json['imagePath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'weather': weather,
      'content': content,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 複製方法
  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? mood,
    String? weather,
    String? content,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 獲取心情emoji
  String getMoodEmoji() {
    return moodOptions.firstWhere(
      (m) => m['label'] == mood,
      orElse: () => moodOptions[0],
    )['emoji']!;
  }

  // 獲取天氣emoji
  String getWeatherEmoji() {
    return weatherOptions.firstWhere(
      (w) => w['label'] == weather,
      orElse: () => weatherOptions[0],
    )['emoji']!;
  }

  // 獲取背景顏色
  String getBackgroundColor() {
    // 根據心情和天氣返回顏色代碼
    if (mood == '超好') return '#FFE5B4';
    if (mood == '很棒') return '#E0F7FA';
    if (mood == '普通') return '#F0F0F0';
    if (mood == '難過') return '#E3F2FD';
    if (mood == '爆炸了') return '#FFEBEE';
    return '#FFFFFF';
  }
}

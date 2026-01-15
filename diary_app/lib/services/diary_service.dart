import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../models/diary_entry.dart';

class DiaryService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Database? _database;

  List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DiaryService() {
    _initLocalDatabase();
  }

  // 初始化本地資料庫
  Future<void> _initLocalDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'diary.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            mood TEXT NOT NULL,
            weather TEXT NOT NULL,
            content TEXT NOT NULL,
            imagePath TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // 從Firebase加載所有日記
  Future<void> loadDiaries(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .orderBy('date', descending: true)
          .get();

      _entries = querySnapshot.docs
          .map((doc) => DiaryEntry.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // 同步到本地資料庫
      await _syncToLocal(_entries);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加載日記失敗: $e';
      _isLoading = false;
      notifyListeners();

      // 如果網路失敗，嘗試從本地加載
      await _loadFromLocal();
    }
  }

  // 從本地資料庫加載
  Future<void> _loadFromLocal() async {
    if (_database == null) return;

    try {
      final List<Map<String, dynamic>> maps =
          await _database!.query('diary_entries', orderBy: 'date DESC');

      _entries = maps.map((map) => DiaryEntry.fromJson(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('從本地加載失敗: $e');
    }
  }

  // 同步到本地資料庫
  Future<void> _syncToLocal(List<DiaryEntry> entries) async {
    if (_database == null) return;

    try {
      // 清空舊資料
      await _database!.delete('diary_entries');

      // 插入新資料
      for (var entry in entries) {
        await _database!.insert('diary_entries', entry.toJson());
      }
    } catch (e) {
      debugPrint('同步到本地失敗: $e');
    }
  }

  // 新增或更新日記
  Future<String?> saveDiary(String userId, DiaryEntry entry) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries');

      if (entry.id == null) {
        // 新增
        final doc = await docRef.add(entry.toJson());
        final newEntry = entry.copyWith(id: doc.id);

        _entries.insert(0, newEntry);
      } else {
        // 更新
        await docRef.doc(entry.id).update(entry.toJson());

        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          _entries[index] = entry.copyWith(updatedAt: DateTime.now());
        }
      }

      // 同步到本地
      await _syncToLocal(_entries);

      notifyListeners();
      return null; // 成功
    } catch (e) {
      return '儲存失敗: $e';
    }
  }

  // 刪除日記
  Future<String?> deleteDiary(String userId, String diaryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diaryId)
          .delete();

      _entries.removeWhere((entry) => entry.id == diaryId);

      // 同步到本地
      await _syncToLocal(_entries);

      notifyListeners();
      return null; // 成功
    } catch (e) {
      return '刪除失敗: $e';
    }
  }

  // 上傳圖片到Firebase Storage
  Future<String?> uploadImage(String userId, File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('users/$userId/images/$fileName');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('上傳圖片失敗: $e');
      return null;
    }
  }

  // 根據日期獲取日記
  DiaryEntry? getDiaryByDate(DateTime date) {
    try {
      return _entries.firstWhere(
        (entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // 搜尋日記
  List<DiaryEntry> searchDiaries(String keyword) {
    if (keyword.isEmpty) return _entries;

    return _entries
        .where((entry) =>
            entry.content.contains(keyword) ||
            entry.mood.contains(keyword) ||
            entry.weather.contains(keyword))
        .toList();
  }

  // 獲取統計資料
  Map<String, int> getMoodStatistics() {
    final stats = <String, int>{};
    for (var entry in _entries) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getWeatherStatistics() {
    final stats = <String, int>{};
    for (var entry in _entries) {
      stats[entry.weather] = (stats[entry.weather] ?? 0) + 1;
    }
    return stats;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/auth_service.dart';
import '../services/diary_service.dart';
import '../models/diary_entry.dart';
import '../widgets/mood_selector.dart';
import '../widgets/weather_selector.dart';

class EditDiaryScreen extends StatefulWidget {
  final DateTime date;
  final DiaryEntry? entry;

  const EditDiaryScreen({
    super.key,
    required this.date,
    this.entry,
  });

  @override
  State<EditDiaryScreen> createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends State<EditDiaryScreen> {
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String _selectedMood = '很棒';
  String _selectedWeather = '晴朗';
  File? _selectedImage;
  String? _imageUrl;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;

    if (widget.entry != null) {
      _contentController = TextEditingController(text: widget.entry!.content);
      _selectedMood = widget.entry!.mood;
      _selectedWeather = widget.entry!.weather;
      _imageUrl = widget.entry!.imagePath;
    } else {
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入日記內容')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final diaryService = Provider.of<DiaryService>(context, listen: false);

    // 上傳圖片
    String? uploadedImageUrl = _imageUrl;
    if (_selectedImage != null && authService.currentUser != null) {
      uploadedImageUrl = await diaryService.uploadImage(
        authService.currentUser!.id,
        _selectedImage!,
      );
    }

    final entry = DiaryEntry(
      id: widget.entry?.id,
      date: _selectedDate,
      mood: _selectedMood,
      weather: _selectedWeather,
      content: _contentController.text.trim(),
      imagePath: uploadedImageUrl,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (authService.currentUser != null) {
      final error = await diaryService.saveDiary(
        authService.currentUser!.id,
        entry,
      );

      setState(() {
        _isSaving = false;
      });

      if (error == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('儲存成功')),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _deleteDiary() async {
    if (widget.entry == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除日記'),
        content: const Text('確定要刪除這篇日記嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final diaryService = Provider.of<DiaryService>(context, listen: false);

      if (authService.currentUser != null) {
        final error = await diaryService.deleteDiary(
          authService.currentUser!.id,
          widget.entry!.id!,
        );

        if (mounted) {
          if (error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('刪除成功')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日 EEEE', 'zh_TW');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? '新增日記' : '編輯日記'),
        actions: [
          if (widget.entry != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteDiary,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期選擇
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(dateFormat.format(_selectedDate)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // 心情選擇
            Text(
              '今天心情',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 16),

            // 天氣選擇
            Text(
              '天氣狀況',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            WeatherSelector(
              selectedWeather: _selectedWeather,
              onWeatherSelected: (weather) {
                setState(() {
                  _selectedWeather = weather;
                });
              },
            ),
            const SizedBox(height: 16),

            // 日記內容
            Text(
              '日記內容',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '寫下今天發生的事...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // 圖片
            Text(
              '添加圖片',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_selectedImage != null || _imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('更換圖片'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _imageUrl = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('選擇圖片'),
              ),
            ],
            const SizedBox(height: 32),

            // 儲存按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDiary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('儲存日記'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

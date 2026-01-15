import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/diary_service.dart';
import '../models/diary_entry.dart';
import 'edit_diary_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<DiaryEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaries() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final diaryService = Provider.of<DiaryService>(context, listen: false);

    if (authService.currentUser != null) {
      await diaryService.loadDiaries(authService.currentUser!.id);
    }
  }

  void _searchDiaries(String keyword) {
    final diaryService = Provider.of<DiaryService>(context, listen: false);
    setState(() {
      _filteredEntries = diaryService.searchDiaries(keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final diaryService = Provider.of<DiaryService>(context);

    final entries = _searchController.text.isEmpty
        ? diaryService.entries
        : _filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的日記'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              ).then((_) => _loadDiaries());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('登出'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋日記...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _filteredEntries = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: _searchDiaries,
            ),
          ),
          Expanded(
            child: diaryService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDiaries,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            return _buildDiaryCard(entries[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDiaryScreen(
                date: DateTime.now(),
              ),
            ),
          ).then((_) => _loadDiaries());
        },
        icon: const Icon(Icons.add),
        label: const Text('新增日記'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '還沒有日記',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '點擊下方按鈕開始記錄',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry entry) {
    final dateFormat = DateFormat('yyyy年M月d日 EEEE', 'zh_TW');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDiaryScreen(
                date: entry.date,
                entry: entry,
              ),
            ),
          ).then((_) => _loadDiaries());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(entry.date),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        entry.getMoodEmoji(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.getWeatherEmoji(),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (entry.imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    entry.imagePath!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

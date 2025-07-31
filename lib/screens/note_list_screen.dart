import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:note_app_flutter/models/category.dart';

import 'package:note_app_flutter/models/note.dart';

import 'package:note_app_flutter/screens/note_detail_screen.dart';

import 'package:note_app_flutter/utils/http_method.dart';

import 'package:note_app_flutter/widgets/category_filter_dialog.dart';

import 'package:note_app_flutter/widgets/note_card.dart';

import 'package:note_app_flutter/widgets/sort_options_dialog.dart';

import 'package:note_app_flutter/widgets/confirm_dialog.dart';

enum SortOption { createdAtDesc, modifiedAtDesc, titleAsc }

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  String _searchQuery = '';

  SortOption _currentSortOption = SortOption.modifiedAtDesc;

  String? _selectedCategoryId;

  String? _selectedTag;

  bool _showTrash = false;

  // Thêm biến state để lưu trữ ghi chú từ API

  List<Note> _notes = [];

  bool _isLoading = true; // Thêm biến để theo dõi trạng thái tải dữ liệu

  // Dữ liệu giả định cho danh mục (có thể thay bằng API sau này)

  final List<Category> _mockCategories = [
    Category(id: 'cat1', name: 'Cá nhân'),

    Category(id: 'cat2', name: 'Công việc'),

    Category(id: 'cat3', name: 'Nấu ăn'),

    Category(id: 'cat4', name: 'Khác'),
  ];

  // Hàm để lấy dữ liệu ghi chú từ Firebase

  void _fetchNotes() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải dữ liệu, hiển thị loading indicator
    });

    try {
      final response = await HttpMethod.get();

      if (response.statusCode >= 400) {
        // Xử lý lỗi nếu có

        print('Có lỗi xảy ra khi tải dữ liệu.');

        setState(() {
          _isLoading = false;
        });

        return;
      }

      if (response.body == 'null') {
        // Không có dữ liệu, gán danh sách rỗng

        setState(() {
          _notes = [];

          _isLoading = false;
        });

        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);

      final List<Note> loadedNotes = [];

      listData.forEach((key, value) {
        // Chuyển đổi dữ liệu từ Map sang đối tượng Note

        loadedNotes.add(
          Note(
            id: key,

            title: value['title'],

            content: value['content'],

            createdAt: DateTime.parse(value['createdAt']),

            modifiedAt: DateTime.parse(value['modifiedAt']),

            isPinned: value['isPinned'] ?? false,

            categoryName: value['categoryName'],

            tags: List<String>.from(value['tags'] ?? []),

            isDeleted: value['isDeleted'] ?? false,
          ),
        );
      });

      setState(() {
        _notes = loadedNotes;

        _isLoading = false;
      });
    } catch (e) {
      print('Đã xảy ra lỗi: $e');

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Gọi hàm fetchNotes() ngay khi màn hình được khởi tạo

    _fetchNotes();
  }

  // --- Các hàm và getters khác ---

  List<String> get _allMockTags {
    final Set<String> allTags = {};

    for (var note in _notes) {
      allTags.addAll(note.tags);
    }

    return allTags.toList();
  }

  List<Note> get _currentNotes {
    List<Note> notes = _notes
        .where((note) => note.isDeleted == _showTrash)
        .toList();

    // Lọc theo tìm kiếm

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final queryLower = _searchQuery.toLowerCase();

        return note.title.toLowerCase().contains(queryLower) ||
            note.content.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Lọc theo danh mục

    if (_selectedCategoryId != null) {
      final selectedCatName = _mockCategories
          .firstWhere((c) => c.id == _selectedCategoryId)
          .name;

      notes = notes
          .where((note) => note.categoryName == selectedCatName)
          .toList();
    }

    // Lọc theo tags

    if (_selectedTag != null) {
      notes = notes.where((note) => note.tags.contains(_selectedTag)).toList();
    }

    // Sắp xếp

    notes.sort((a, b) {
      switch (_currentSortOption) {
        case SortOption.createdAtDesc:
          return b.createdAt.compareTo(a.createdAt);

        case SortOption.modifiedAtDesc:
          return b.modifiedAt.compareTo(a.modifiedAt);

        case SortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    // Ghim ghi chú quan trọng lên đầu

    final pinnedNotes = notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    return [...pinnedNotes, ...unpinnedNotes];
  }

  void _navigateToNoteDetail({Note? note}) {
    Navigator.push(
      context,

      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
  }

  void _showSortOptions() async {
    final selected = await showDialog<SortOption>(
      context: context,

      builder: (context) =>
          SortOptionsDialog(currentSortOption: _currentSortOption),
    );

    if (selected != null) {
      setState(() {
        _currentSortOption = selected;
      });
    }
  }

  void _showFilterOptions() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,

      builder: (context) => CategoryFilterDialog(
        categories: _mockCategories,

        allTags: _allMockTags,

        selectedCategoryId: _selectedCategoryId,

        selectedTag: _selectedTag,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategoryId = result['categoryId'];

        _selectedTag = result['tag'];
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;

      _selectedTag = null;

      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showTrash ? 'Thùng rác' : 'Ghi chú của tôi'),

        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),

            onPressed: _showFilterOptions,
          ),

          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions),

          
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),

            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),

                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),

                  borderSide: BorderSide.none,
                ),

                filled: true,

                fillColor: Colors.blueGrey.shade50,
              ),

              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          if (_selectedCategoryId != null || _selectedTag != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),

              child: Row(
                children: [
                  if (_selectedCategoryId != null)
                    Chip(
                      label: Text(
                        'Danh mục: ${_mockCategories.firstWhere((c) => c.id == _selectedCategoryId).name}',
                      ),

                      onDeleted: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),

                  const SizedBox(width: 8),

                  if (_selectedTag != null)
                    Chip(
                      label: Text('Thẻ: $_selectedTag'),

                      onDeleted: () {
                        setState(() {
                          _selectedTag = null;
                        });
                      },
                    ),

                  const Spacer(),

                  TextButton(
                    onPressed: _clearFilters,

                    child: const Text('Xóa bộ lọc'),
                  ),
                ],
              ),
            ),

          Expanded(
            child:
                _isLoading // Kiểm tra trạng thái loading
                ? const Center(child: CircularProgressIndicator())
                : _currentNotes.isEmpty
                ? Center(
                    child: Text(
                      _showTrash
                          ? 'Thùng rác trống.'
                          : 'Không có ghi chú nào. Hãy tạo một ghi chú mới!',

                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentNotes.length,

                    itemBuilder: (context, index) {
                      final note = _currentNotes[index];

                      return Dismissible(
                        key: Key(note.id),

                        direction: DismissDirection.endToStart,

                        background: Container(
                          color: Colors.red,

                          alignment: Alignment.centerRight,

                          padding: const EdgeInsets.symmetric(horizontal: 20),

                          child: Icon(
                            _showTrash ? Icons.delete_forever : Icons.delete,

                            color: Colors.white,
                          ),
                        ),

                        confirmDismiss: (direction) async {
                          // Đây chỉ là UI, không xóa thật sự

                          return await showDialog<bool>(
                            context: context,

                            builder: (context) => ConfirmDialog(
                              title: _showTrash
                                  ? 'Xóa vĩnh viễn'
                                  : 'Chuyển vào thùng rác',

                              content: _showTrash
                                  ? 'Hành động này sẽ xóa vĩnh viễn ghi chú này.'
                                  : 'Hành động này sẽ chuyển ghi chú này vào thùng rác.',
                            ),
                          );
                        },

                        onDismissed: (direction) {
                          // Không làm gì cả vì đây chỉ là UI

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _showTrash
                                    ? 'Đã xóa ghi chú.'
                                    : 'Đã chuyển ghi chú vào thùng rác.',
                              ),

                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },

                        child: NoteCard(
                          note: note,

                          onTap: () => _navigateToNoteDetail(note: note),

                          onTogglePin: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  note.isPinned
                                      ? 'Đã bỏ ghim ghi chú.'
                                      : 'Đã ghim ghi chú.',
                                ),

                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },

                          onRestore: _showTrash
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã khôi phục ghi chú.'),

                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: _showTrash
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToNoteDetail(),

              child: const Icon(Icons.add),
            ),
    );
  }
}

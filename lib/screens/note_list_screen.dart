import 'package:flutter/material.dart';
import 'package:note_app_flutter/models/category.dart';
import 'package:note_app_flutter/models/note.dart';
import 'package:note_app_flutter/screens/note_detail_screen.dart';
import 'package:note_app_flutter/utils/http_method.dart';
import 'package:note_app_flutter/widgets/category_filter_dialog.dart';
import 'package:note_app_flutter/widgets/note_card.dart';
import 'package:note_app_flutter/widgets/sort_options_dialog.dart';
import 'package:note_app_flutter/widgets/confirm_dialog.dart';

enum SortOption {
  createdAtDesc,
  modifiedAtDesc,
  titleAsc,
}

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

@override
  void initState(){
    super.initState();
    HttpMethod.get();
    print('hehe');
  }

  // Dữ liệu giả định để hiển thị UI
  final List<Note> _mockNotes = [
    Note(
      id: '1',
      title: 'Kế hoạch cuối tuần',
      content: 'Đi siêu thị, dọn nhà, đọc sách.',
      createdAt: DateTime(2023, 1, 10, 10, 0),
      modifiedAt: DateTime(2023, 1, 12, 14, 30),
      isPinned: true,
      categoryName: 'Cá nhân',
      tags: ['mua sắm', 'nhà cửa'],
    ),
    Note(
      id: '2',
      title: 'Ý tưởng dự án mới',
      content: 'Phát triển ứng dụng quản lý tài chính cá nhân với Flutter.',
      createdAt: DateTime(2023, 1, 15, 9, 0),
      modifiedAt: DateTime(2023, 1, 15, 11, 0),
      categoryName: 'Công việc',
      tags: ['flutter', 'tài chính'],
    ),
    Note(
      id: '3',
      title: 'Công thức nấu ăn',
      content: 'Mì Ý sốt bò băm: thịt bò, cà chua, hành tây, tỏi, mì spaghetti.',
      createdAt: DateTime(2023, 1, 5, 18, 0),
      modifiedAt: DateTime(2023, 1, 5, 18, 0),
      categoryName: 'Nấu ăn',
      tags: ['món ăn', 'ý'],
    ),
    Note(
      id: '4',
      title: 'Ghi chú đã xóa',
      content: 'Ghi chú này đã được chuyển vào thùng rác.',
      createdAt: DateTime(2023, 1, 20, 8, 0),
      modifiedAt: DateTime(2023, 1, 20, 8, 0),
      isDeleted: true,
      categoryName: 'Khác',
    ),
     Note(
      id: '5',
      title: 'Mua sắm',
      content: 'Sữa, trứng, bánh mì',
      createdAt: DateTime(2023, 1, 25, 10, 0),
      modifiedAt: DateTime(2023, 1, 25, 10, 0),
      isPinned: false,
      categoryName: 'Cá nhân',
      tags: ['mua sắm'],
    ),
  ];

  final List<Category> _mockCategories = [
    Category(id: 'cat1', name: 'Cá nhân'),
    Category(id: 'cat2', name: 'Công việc'),
    Category(id: 'cat3', name: 'Nấu ăn'),
    Category(id: 'cat4', name: 'Khác'),
  ];

  List<String> get _allMockTags {
    final Set<String> allTags = {};
    for (var note in _mockNotes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList();
  }

  List<Note> get _currentNotes {
    List<Note> notes = _mockNotes.where((note) => note.isDeleted == _showTrash).toList();

    // Lọc theo tìm kiếm (chỉ UI)
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final queryLower = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(queryLower) ||
            note.content.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Lọc theo danh mục (chỉ UI)
    if (_selectedCategoryId != null) {
      final selectedCatName = _mockCategories.firstWhere((c) => c.id == _selectedCategoryId).name;
      notes = notes.where((note) => note.categoryName == selectedCatName).toList();
    }

    // Lọc theo tags (chỉ UI)
    if (_selectedTag != null) {
      notes = notes.where((note) => note.tags.contains(_selectedTag)).toList();
    }

    // Sắp xếp (chỉ UI)
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

    // Ghim ghi chú quan trọng lên đầu (chỉ UI)
    final pinnedNotes = notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    return [...pinnedNotes, ...unpinnedNotes];
  }

  void _navigateToNoteDetail({Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  void _showSortOptions() async {
    final selected = await showDialog<SortOption>(
      context: context,
      builder: (context) => SortOptionsDialog(
        currentSortOption: _currentSortOption,
      ),
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
        title: Text(_showTrash ? 'Thùng rác (UI)' : 'Ghi chú của tôi (UI)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _showTrash = value == 'trash';
                _clearFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'notes',
                child: Text('Ghi chú'),
              ),
              const PopupMenuItem(
                value: 'trash',
                child: Text('Thùng rác'),
              ),
            ],
          ),
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
                          'Danh mục: ${_mockCategories.firstWhere((c) => c.id == _selectedCategoryId).name}'),
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
                  )
                ],
              ),
            ),
          Expanded(
            child: _currentNotes.isEmpty
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
                              title: _showTrash ? 'Xóa vĩnh viễn (UI)' : 'Chuyển vào thùng rác (UI)',
                              content: _showTrash
                                  ? 'Hành động này sẽ xóa vĩnh viễn ghi chú này khỏi UI.'
                                  : 'Hành động này sẽ chuyển ghi chú này vào thùng rác trong UI.',
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          // Không làm gì cả vì đây chỉ là UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(_showTrash
                                    ? 'Đã xóa ghi chú khỏi UI.'
                                    : 'Đã chuyển ghi chú vào thùng rác trong UI.'),
                                duration: const Duration(seconds: 2)),
                          );
                        },
                        child: NoteCard(
                          note: note,
                          onTap: () => _navigateToNoteDetail(note: note),
                          onTogglePin: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(note.isPinned
                                      ? 'Đã bỏ ghim ghi chú (UI).'
                                      : 'Đã ghim ghi chú (UI).'),
                                  duration: const Duration(seconds: 1)),
                            );
                          },
                          onRestore: _showTrash
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Đã khôi phục ghi chú (UI).'),
                                        duration: Duration(seconds: 2)),
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
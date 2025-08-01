import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:note_app_flutter/datas/screen_state_notifier.dart';
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
  List<Note> _notes = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedCategories = await HttpMethod.getCategories();
      final response = await HttpMethod.get();

      final List<Note> loadedNotes = [];
      if (response.statusCode < 400 && response.body != 'null') {
        final Map<String, dynamic> listData = json.decode(response.body);
        listData.forEach((key, value) {
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
              isDeleted: false,
            ),
          );
        });
      }

      setState(() {
        _categories = fetchedCategories;
        _notes = loadedNotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Đã xảy ra lỗi khi tải dữ liệu: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  List<String> get _allTags {
    final Set<String> allTags = {};
    for (var note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList();
  }

  List<Note> get _currentNotes {
    List<Note> notes = _notes.toList();

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final queryLower = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(queryLower) ||
            note.content.toLowerCase().contains(queryLower);
      }).toList();
    }

    if (_selectedCategoryId != null) {
      final selectedCatName = _categories
          .firstWhere((c) => c.id == _selectedCategoryId)
          .name;
      notes = notes
          .where((note) => note.categoryName == selectedCatName)
          .toList();
    }

    if (_selectedTag != null) {
      notes = notes.where((note) => note.tags.contains(_selectedTag)).toList();
    }

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

    final pinnedNotes = notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    return [...pinnedNotes, ...unpinnedNotes];
  }

  void _navigateToNoteDetail({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
    _fetchData();
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
        categories: _categories,
        allTags: _allTags,
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
        title: const Text('Ghi chú của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions),
        ],
        leading: ValueListenableBuilder(
          valueListenable: currentScreenNotifier,
          builder: (context, screen, child) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                currentScreenNotifier.value = 0;
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
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
                fillColor: Color.fromARGB(255, 34, 28, 39),
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
                        'Danh mục: ${_categories.firstWhere((c) => c.id == _selectedCategoryId).name}',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentNotes.isEmpty
                ? Center(
                    child: Text(
                      'Không có ghi chú nào. Hãy tạo một ghi chú mới!',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView.builder(
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
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                title: 'Xóa ghi chú',
                                content:
                                    'Bạn có chắc chắn muốn xóa vĩnh viễn ghi chú "${note.title}" này không?',
                              ),
                            );
                          },
                          onDismissed: (direction) async {
                            setState(() {
                              _notes.removeWhere((n) => n.id == note.id);
                            });
                            await HttpMethod.delete(note.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã xóa vĩnh viễn ghi chú "${note.title}".',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: NoteCard(
                            note: note,
                            onTap: () => _navigateToNoteDetail(note: note),
                            onTogglePin: () async {
                              final updatedNote = note.copyWith(
                                isPinned: !note.isPinned,
                                modifiedAt: DateTime.now(),
                              );
                              await HttpMethod.patch(
                                note.id,
                                updatedNote.toJson(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    updatedNote.isPinned
                                        ? 'Đã ghim ghi chú "${updatedNote.title}".'
                                        : 'Đã bỏ ghim ghi chú "${updatedNote.title}".',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              _fetchData();
                            },
                            onRestore: null,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNoteDetail(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

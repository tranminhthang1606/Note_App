import 'package:flutter/material.dart';
import 'package:note_app_flutter/models/category.dart';
import 'package:note_app_flutter/models/note.dart';
import 'package:note_app_flutter/utils/http_method.dart';
import 'package:note_app_flutter/widgets/confirm_dialog.dart';
import 'package:note_app_flutter/widgets/tag_input_field.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategoryName;
  List<String> _tags = [];
  bool _isPinned = false;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedCategoryName = widget.note!.categoryName;
      _tags = List.from(widget.note!.tags);
      _isPinned = widget.note!.isPinned;
    }
    _fetchCategories(); 
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final fetchedCategories = await HttpMethod.getCategories();
      setState(() {
        _categories = fetchedCategories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Lỗi khi lấy danh mục: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _addCategoryDialog() async {
    String newCategoryName = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
          onChanged: (value) {
            newCategoryName = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newCategoryName.isNotEmpty) {
                
                await HttpMethod.createCategory(newCategoryName);
                
                
                await _fetchCategories();
                setState(() {
                  _selectedCategoryName = newCategoryName;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm danh mục "$newCategoryName".'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Ghi chú mới' : 'Chỉnh sửa ghi chú',
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () async {
                setState(() {
                  _isPinned = !_isPinned;
                });
                final updatedNote = widget.note!.copyWith(
                  isPinned: _isPinned,
                  modifiedAt: DateTime.now(),
                );
                await HttpMethod.patch(widget.note!.id, updatedNote.toJson());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isPinned ? 'Đã ghim ghi chú.' : 'Đã bỏ ghim ghi chú.',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Xóa ghi chú',
                    content: 'Bạn có chắc chắn muốn xóa vĩnh viễn ghi chú này không?',
                  ),
                );
                if (confirmed == true) {
                  if (widget.note != null && widget.note!.id.isNotEmpty) {
                    await HttpMethod.delete(widget.note!.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ghi chú đã được xóa vĩnh viễn!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể xóa ghi chú không có ID.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Nội dung ghi chú...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      expands: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryName,
                    decoration: InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Chọn danh mục'),
                    items: [
                      ..._categories.map(
                        (category) => DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'new_category',
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Thêm danh mục mới'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 'new_category') {
                        _addCategoryDialog();
                      } else {
                        setState(() {
                          _selectedCategoryName = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TagInputField(
                    initialTags: _tags,
                    onTagsChanged: (newTags) {
                      setState(() {
                        _tags = newTags;
                      });
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            
            final Map<String, dynamic> data = Note(
              id: widget.note?.id ?? '',
              title: _titleController.text,
              content: _contentController.text,
              categoryName: _selectedCategoryName,
              tags: _tags,
              isPinned: _isPinned,
              createdAt: widget.note?.createdAt ?? DateTime.now(),
              modifiedAt: DateTime.now(),
              isDeleted: false,
            ).toJson();

            if (widget.note == null) {
              await HttpMethod.post(data);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ghi chú đã được thêm mới!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              await HttpMethod.patch(widget.note!.id, data);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ghi chú đã được cập nhật!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            if (mounted) {
              Navigator.pop(context, true); 
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.note == null ? 'Lưu ghi chú mới' : 'Cập nhật ghi chú',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
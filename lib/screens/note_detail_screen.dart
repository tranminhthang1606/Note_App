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
  String? _selectedCategoryName; // Thay đổi từ categoryId sang categoryName cho UI
  List<String> _tags = [];
  bool _isPinned = false;

  // Dữ liệu giả định cho danh mục
  final List<Category> _mockCategories = [
    Category(id: 'cat1', name: 'Cá nhân'),
    Category(id: 'cat2', name: 'Công việc'),
    Category(id: 'cat3', name: 'Nấu ăn'),
    Category(id: 'cat4', name: 'Khác'),
  ];

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
  }

  Future<void> _addCategoryDialog() async {
    String newCategoryName = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới (UI)'),
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
            onPressed: () {
              if (newCategoryName.isNotEmpty) {
                // Không thêm thật sự, chỉ hiển thị thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đã thêm danh mục "$newCategoryName" vào UI.'),
                      duration: const Duration(seconds: 2)),
                );
                setState(() {
                  _selectedCategoryName = newCategoryName; // Chọn danh mục mới tạo trong UI
                });
                Navigator.pop(context);
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
        title: Text(widget.note == null ? 'Ghi chú mới (UI)' : 'Chỉnh sửa ghi chú (UI)'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_isPinned ? 'Đã ghim ghi chú (UI).' : 'Đã bỏ ghim ghi chú (UI).'),
                    duration: const Duration(seconds: 1)),
              );
            },
          ),
          if (widget.note != null && !widget.note!.isDeleted)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Xóa ghi chú (UI)',
                    content: 'Bạn có chắc chắn muốn chuyển ghi chú này vào thùng rác trong UI không?',
                  ),
                );
                if (confirmed == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã chuyển ghi chú vào thùng rác trong UI.'),
                        duration: Duration(seconds: 2)),
                  );
                  if (mounted) {
                    Navigator.pop(context); // Quay lại
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
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
            // Chọn danh mục
            DropdownButtonFormField<String>(
              value: _selectedCategoryName,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Chọn danh mục'),
              items: [
                ..._mockCategories.map((category) => DropdownMenuItem(
                      value: category.name,
                      child: Text(category.name),
                    )),
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
            // Thêm Tags
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
          onPressed: () {
            final Map<String, dynamic> data = Note(
              id: widget.note?.id ?? '',
              title: _titleController.text,
              content: _contentController.text,
              categoryName: _selectedCategoryName,
              tags: _tags,
              isPinned: _isPinned,
              createdAt: widget.note?.createdAt ?? DateTime.now(),
              modifiedAt: DateTime.now(),
            ).toJson();
            
            HttpMethod.post(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Ghi chú đã được lưu (chỉ UI).'),
                  duration: Duration(seconds: 2)),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Lưu và Thoát (UI)',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
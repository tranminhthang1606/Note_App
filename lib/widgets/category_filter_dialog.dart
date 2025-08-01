import 'package:flutter/material.dart';
import 'package:note_app_flutter/models/category.dart';

class CategoryFilterDialog extends StatefulWidget {
  final List<Category> categories;
  final List<String> allTags;
  final String? selectedCategoryId; 
  final String? selectedTag;

  const CategoryFilterDialog({
    super.key,
    required this.categories,
    required this.allTags,
    this.selectedCategoryId,
    this.selectedTag,
  });

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  String? _tempSelectedCategoryId;
  String? _tempSelectedTag;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategoryId = widget.selectedCategoryId;
    _tempSelectedTag = widget.selectedTag;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lọc ghi chú '),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lọc theo danh mục:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String?>(
              title: const Text('Tất cả danh mục'),
              value: null,
              groupValue: _tempSelectedCategoryId,
              onChanged: (value) {
                setState(() {
                  _tempSelectedCategoryId = value;
                });
              },
            ),
            ...widget.categories.map((category) => RadioListTile<String?>(
                  title: Text(category.name),
                  value: category.id, 
                  groupValue: _tempSelectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _tempSelectedCategoryId = value;
                    });
                  },
                )),
            const Divider(),
            const Text('Lọc theo thẻ (tags):', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String?>(
              title: const Text('Tất cả thẻ'),
              value: null,
              groupValue: _tempSelectedTag,
              onChanged: (value) {
                setState(() {
                  _tempSelectedTag = value;
                });
              },
            ),
            ...widget.allTags.map((tag) => RadioListTile<String?>(
                  title: Text(tag),
                  value: tag,
                  groupValue: _tempSelectedTag,
                  onChanged: (value) {
                    setState(() {
                      _tempSelectedTag = value;
                    });
                  },
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'categoryId': _tempSelectedCategoryId,
              'tag': _tempSelectedTag,
            });
          },
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
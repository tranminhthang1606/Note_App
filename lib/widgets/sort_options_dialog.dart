import 'package:flutter/material.dart';
import 'package:note_app_flutter/screens/note_list_screen.dart';

class SortOptionsDialog extends StatefulWidget {
  final SortOption currentSortOption;

  const SortOptionsDialog({super.key, required this.currentSortOption});

  @override
  State<SortOptionsDialog> createState() => _SortOptionsDialogState();
}

class _SortOptionsDialogState extends State<SortOptionsDialog> {
  late SortOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sắp xếp ghi chú theo '),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<SortOption>(
            title: const Text('Ngày tạo (mới nhất)'),
            value: SortOption.createdAtDesc,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          RadioListTile<SortOption>(
            title: const Text('Ngày sửa đổi (mới nhất)'),
            value: SortOption.modifiedAtDesc,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          RadioListTile<SortOption>(
            title: const Text('Tiêu đề (A-Z)'),
            value: SortOption.titleAsc,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
        ],
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
            Navigator.pop(context, _selectedOption);
          },
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
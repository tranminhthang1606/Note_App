import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmButtonText = 'Xác nhận',
    this.cancelButtonText = 'Hủy',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelButtonText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}

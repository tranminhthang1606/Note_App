import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app_flutter/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback? onRestore;
  // categoryName đã có sẵn trong Note model UI, không cần truyền riêng

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Ghi chú không tiêu đề',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!note.isDeleted)
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: note.isPinned ? Colors.blueGrey : Colors.grey,
                      ),
                      onPressed: onTogglePin,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content.isNotEmpty ? note.content : 'Không có nội dung',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  if (note.categoryName != null)
                    Chip(
                      label: Text(note.categoryName!),
                      backgroundColor: Colors.blueGrey.shade100,
                      labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ...note.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blueGrey.shade50,
                        labelStyle: TextStyle(color: Colors.blueGrey.shade600),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              if (onRestore != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore_from_trash, size: 18),
                    label: const Text('Khôi phục'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
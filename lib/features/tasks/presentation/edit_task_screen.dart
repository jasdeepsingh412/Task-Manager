import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/task_model.dart';
import 'task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedStatus;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);

    _selectedDate = widget.task.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate);
    _selectedStatus = widget.task.status;
  }

  Future<void> _updateTask() async {
    setState(() => _isUpdating = true);

    try {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedTask = Task(
        id: widget.task.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: _selectedStatus,
        dueDate: combinedDateTime,
      );

      await ref.read(taskProvider.notifier).updateTask(updatedTask);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Task",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateTask,
            child: _isUpdating
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
                : Text(
              "Save",
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel("TITLE", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: _inputDecoration("Edit title...", theme),
          ),

          const SizedBox(height: 24),
          _sectionLabel("DESCRIPTION", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: _inputDecoration("Edit description...", theme),
          ),

          const SizedBox(height: 24),
          _sectionLabel("STATUS", theme),
          const SizedBox(height: 12),
          _buildStatusSelector(theme),

          const SizedBox(height: 24),
          _sectionLabel("DUE DATE & TIME", theme),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _pickerTile(
                  DateFormat.yMMMd().format(_selectedDate),
                  Icons.calendar_today,
                  theme,
                      () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerTile(
                  _selectedTime.format(context),
                  Icons.access_time,
                  theme,
                      () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ThemeData theme) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
      color: theme.colorScheme.primary,
    ),
  );

  InputDecoration _inputDecoration(String hint, ThemeData theme) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      );

  Widget _buildStatusSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ["pending", "in progress", "done"].map((status) {
          final selected = _selectedStatus == status;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                  selected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pickerTile(
      String label, IconData icon, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
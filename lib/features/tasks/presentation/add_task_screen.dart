import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/task_model.dart';
import 'task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate = DateTime.now(); // Default to today
  TimeOfDay? _selectedTime = TimeOfDay.now(); // Default to now
  bool _isSaving = false;
  String _selectedStatus = "pending";

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final newTask = Task(
        id: '', // Firestore will generate this
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: _selectedStatus,
        dueDate: combinedDateTime,
      );

      await ref.read(taskProvider.notifier).addTask(newTask);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save task: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create New Task', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTask,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("Save", style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSectionLabel("TASK TITLE", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.poppins(),
              decoration: _inputDecoration("What needs to be done?", theme),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
            ),

            const SizedBox(height: 24),
            _buildSectionLabel("DESCRIPTION", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              style: GoogleFonts.poppins(),
              maxLines: 3,
              decoration: _inputDecoration("Add more details...", theme),
            ),

            const SizedBox(height: 24),
            _buildSectionLabel("STATUS", theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: ["pending", "in progress", "done"].map((status) {
                  final isSelected = _selectedStatus == status;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStatus = status),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionLabel("DUE DATE & TIME", theme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPickerTile(
                    label: _selectedDate == null ? "Select Date" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    icon: Icons.calendar_month,
                    theme: theme,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerTile(
                    label: _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                    icon: Icons.access_time,
                    theme: theme,
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: theme.colorScheme.primary.withOpacity(0.8),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildPickerTile({required String label, required IconData icon, required ThemeData theme, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
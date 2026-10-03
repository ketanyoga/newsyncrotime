import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import 'category_list_page.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF1C1C1E),
          ),
        );
        return;
      }

      final db = await AppDB.instance.database;
      await db.insert(
        'categories',
        CategoryModel(
          name: nameCtrl.text.trim(),
          color: const Color(0xFF007AFF).toARGB32(),
          startDate: _startDate!.toIso8601String(),
          endDate: _endDate!.toIso8601String(),
        ).toMap(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const CategoryListPage(),
            settings: const RouteSettings(name: 'CategoryListPage'),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Cozy background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF2F5F9)],
            stops: [0.0, 0.3],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _sectionLabel("SCHEDULE IDENTITY"),
                      _buildNameCard(),
                      const SizedBox(height: 32),
                      _sectionLabel("TIME DURATION"),
                      _buildDateCard(),
                      const SizedBox(height: 48),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF007AFF), size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "New Schedule",
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              "Define your session range",
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
            ),
          ],
        ),
        background: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 48,
              color: Color(0xFF007AFF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF8E8E93),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNameCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: TextFormField(
        controller: nameCtrl,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
        decoration: InputDecoration(
          labelText: 'Session Name',
          hintText: 'e.g. Summer 2026',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600, fontSize: 14),
          prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded, color: Color(0xFF007AFF)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF2F2F7), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FB),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _dateTile(
            label: "STARTING FROM",
            date: _startDate,
            icon: Icons.calendar_today,
            color: const Color(0xFF34C759), // iOS Green
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: _startDate ?? DateTime.now(),
              );
              if (date != null) setState(() => _startDate = date);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: Color(0xFFF2F2F7)),
          ),
          _dateTile(
            label: "ENDING ON",
            date: _endDate,
            icon: Icons.event_busy_rounded,
            color: const Color(0xFFFF3B30), // iOS Red
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: _startDate ?? DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: _endDate ?? _startDate ?? DateTime.now(),
              );
              if (date != null) setState(() => _endDate = date);
            },
          ),
        ],
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color, // Highlighted title
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date == null ? "Not Selected" : DateFormat('EEEE, d MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date == null ? const Color(0xFF8E8E93) : const Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Color(0xFF007AFF), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF005BCB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 24),
                SizedBox(width: 12),
                Text(
                  "CREATE SCHEDULE",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8E8E93)),
          child: const Text(
            "Cancel & Go Back",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

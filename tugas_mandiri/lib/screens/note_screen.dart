import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';
import 'note_detail_screen.dart';

/// Halaman manajemen Catatan Kuliah: tambah, edit, hapus, cari, & tampilkan daftar.
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _db = DatabaseService();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  CourseModel? _filterCourse;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ──────────────── DIALOG TAMBAH / EDIT ────────────────

  void _showNoteDialog({NoteModel? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteFormSheet(db: _db, note: note),
    );
  }

  // ──────────────── HAPUS CATATAN ────────────────

  Future<void> _deleteNote(NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Catatan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Catatan "${note.title}" akan dihapus permanen.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catatan dihapus.',
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ──────────────── UI ────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Catatan Kuliah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          IconButton(
            onPressed: () => _showNoteDialog(),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            tooltip: 'Tambah Catatan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                hintStyle: GoogleFonts.poppins(
                    color: cs.onSurfaceVariant.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          // ── Filter Chip Row (from courses stream) ──
          StreamBuilder<List<CourseModel>>(
            stream: _db.getCourses(),
            builder: (ctx, snap) {
              final courses = snap.data ?? [];
              if (courses.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      child: ChoiceChip(
                        label: Text('Semua', style: GoogleFonts.poppins(fontSize: 12)),
                        selected: _filterCourse == null,
                        onSelected: (_) =>
                            setState(() => _filterCourse = null),
                      ),
                    ),
                    ...courses.map(
                      (c) => Padding(
                        padding:
                            const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        child: ChoiceChip(
                          label: Text(c.name,
                              style: GoogleFonts.poppins(fontSize: 12)),
                          selected: _filterCourse?.id == c.id,
                          onSelected: (_) =>
                              setState(() => _filterCourse = c),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Notes List ──
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _filterCourse != null
                  ? _db.getNotesByCourse(_filterCourse!.id)
                  : _db.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: cs.error)),
                  );
                }

                var notes = snapshot.data ?? [];

                // Filter pencarian
                if (_searchQuery.isNotEmpty) {
                  notes = notes
                      .where((n) =>
                          n.title.toLowerCase().contains(_searchQuery) ||
                          n.content.toLowerCase().contains(_searchQuery) ||
                          n.courseName.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (notes.isEmpty) {
                  return _buildEmptyState(cs);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: notes.length,
                  itemBuilder: (ctx, i) => _buildNoteCard(notes[i], cs),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text('Tambah Catatan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.note_outlined, size: 64, color: cs.secondary),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'Catatan Tidak Ditemukan'
                : 'Belum Ada Catatan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Tekan tombol + untuk\nmenambahkan catatan baru',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, ColorScheme cs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(note.timestamp);
    final formatted = DateFormat('dd MMM yyyy, HH:mm', 'id').format(dt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(note: note),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.courseName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _showNoteDialog(note: note);
                        if (v == 'delete') _deleteNote(note);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 18, color: cs.primary),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  size: 18, color: cs.error),
                              const SizedBox(width: 8),
                              Text('Hapus',
                                  style: GoogleFonts.poppins(color: cs.error)),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.more_vert_rounded,
                          color: cs.onSurfaceVariant.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  note.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: cs.onSurfaceVariant.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      formatted,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: cs.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Form tambah / edit catatan (Bottom Sheet)
// ═══════════════════════════════════════════════════════

class _NoteFormSheet extends StatefulWidget {
  final DatabaseService db;
  final NoteModel? note;

  const _NoteFormSheet({required this.db, this.note});

  @override
  State<_NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<_NoteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  CourseModel? _selectedCourse;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih mata kuliah terlebih dahulu.',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.note!.copyWith(
          courseId: _selectedCourse?.id ?? widget.note!.courseId,
          courseName: _selectedCourse?.name ?? widget.note!.courseName,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
        await widget.db.updateNote(updated);
      } else {
        final note = NoteModel(
          id: '',
          courseId: _selectedCourse!.id,
          courseName: _selectedCourse!.name,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await widget.db.addNote(note);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e',
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing ? 'Edit Catatan' : 'Tambah Catatan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown Mata Kuliah
                StreamBuilder<List<CourseModel>>(
                  stream: widget.db.getCourses(),
                  builder: (ctx, snap) {
                    final courses = snap.data ?? [];

                    // Saat edit, cari course yang cocok
                    if (_isEditing && _selectedCourse == null) {
                      final match = courses.where(
                          (c) => c.id == widget.note!.courseId);
                      if (match.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedCourse = match.first);
                          }
                        });
                      }
                    }

                    return DropdownButtonFormField<CourseModel>(
                      key: ValueKey(_selectedCourse?.id),
                      initialValue: _selectedCourse,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Mata Kuliah',
                        prefixIcon:
                            Icon(Icons.book_outlined, color: cs.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: cs.outline.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: cs.primary, width: 2),
                        ),
                        filled: true,
                        fillColor:
                            cs.surfaceContainerHighest.withOpacity(0.3),
                        labelStyle:
                            GoogleFonts.poppins(color: cs.onSurfaceVariant),
                      ),
                      hint: Text(
                        courses.isEmpty
                            ? 'Belum ada mata kuliah'
                            : 'Pilih mata kuliah',
                        style: GoogleFonts.poppins(
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                            fontSize: 14),
                      ),
                      items: courses
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name,
                                    style: GoogleFonts.poppins(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: courses.isEmpty
                          ? null
                          : (v) => setState(() => _selectedCourse = v),
                      validator: (_) {
                        if (_selectedCourse == null && !_isEditing) {
                          return 'Pilih mata kuliah';
                        }
                        return null;
                      },
                      style:
                          GoogleFonts.poppins(color: cs.onSurface, fontSize: 14),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Judul
                TextFormField(
                  controller: _titleCtrl,
                  style: GoogleFonts.poppins(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Judul wajib diisi'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Judul Catatan',
                    hintText: 'Contoh: Firebase Realtime Database',
                    prefixIcon:
                        Icon(Icons.title_rounded, color: cs.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: cs.outline.withOpacity(0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    labelStyle:
                        GoogleFonts.poppins(color: cs.onSurfaceVariant),
                    hintStyle: GoogleFonts.poppins(
                        color: cs.onSurfaceVariant.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Isi Catatan
                TextFormField(
                  controller: _contentCtrl,
                  style: GoogleFonts.poppins(),
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Isi catatan wajib diisi'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan',
                    hintText: 'Tulis catatan kuliah di sini...',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.notes_rounded, color: cs.primary),
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: cs.outline.withOpacity(0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    labelStyle:
                        GoogleFonts.poppins(color: cs.onSurfaceVariant),
                    hintStyle: GoogleFonts.poppins(
                        color: cs.onSurfaceVariant.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_isEditing
                            ? Icons.update_rounded
                            : Icons.save_rounded),
                    label: Text(
                      _isSaving
                          ? 'Menyimpan...'
                          : (_isEditing ? 'Perbarui' : 'Simpan'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

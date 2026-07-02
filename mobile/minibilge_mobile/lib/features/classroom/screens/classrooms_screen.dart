import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom_models.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF4FACFE), Color(0xFF7B6FCD), Color(0xFF9B8FE8)],
);

BoxDecoration _glassCard({double radius = 20}) => BoxDecoration(
      color: const Color(0xFF1A0E52).withOpacity(0.22),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ],
    );

// ── Ana Ekran ────────────────────────────────────────────────────────────────

class ClassroomsScreen extends ConsumerStatefulWidget {
  const ClassroomsScreen({super.key});

  @override
  ConsumerState<ClassroomsScreen> createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends ConsumerState<ClassroomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classroomNotifierProvider.notifier).loadMine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomNotifierProvider);
    final isTeacher = ref.watch(selectedChildProvider)?.isTeacher ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        '🏫 Sınıflarım',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () =>
                          ref.read(classroomNotifierProvider.notifier).loadMine(),
                    ),
                  ],
                ),
              ),

              // ── İçerik ─────────────────────────────────────────────
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : state.classrooms.isEmpty
                        ? _EmptyState(
                            isTeacher: isTeacher,
                            onCreateTap: () => _showCreateDialog(context),
                            onJoinTap: () => _showJoinDialog(context),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF6A5ACD),
                            onRefresh: () => ref
                                .read(classroomNotifierProvider.notifier)
                                .loadMine(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: state.classrooms.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => _ClassroomCard(
                                classroom: state.classrooms[i],
                              ),
                            ),
                          ),
              ),

              // ── Alt Butonlar ───────────────────────────────────────
              if (!state.isLoading && state.classrooms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      if (isTeacher) ...[
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_rounded,
                            label: 'Sınıf Oluştur',
                            color: const Color(0xFF6A5ACD),
                            onTap: () => _showCreateDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.vpn_key_rounded,
                          label: 'Koda Katıl',
                          color: const Color(0xFF00BCD4),
                          onTap: () => _showJoinDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateClassroomSheet(
        onCreated: (classroom) {
          context.push('/classrooms/${classroom.id}');
        },
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _JoinClassroomSheet(),
    );
  }
}

// ── Boş Durum ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  final VoidCallback onJoinTap;
  final bool isTeacher;

  const _EmptyState({
    required this.onCreateTap,
    required this.onJoinTap,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏫', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'Henüz bir sınıfa katılmadın',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isTeacher) ...
              [
                _ActionButton(
                  icon: Icons.add_rounded,
                  label: 'Sınıf Oluştur',
                  color: const Color(0xFF6A5ACD),
                  onTap: onCreateTap,
                ),
                const SizedBox(height: 12),
              ],
            _ActionButton(
              icon: Icons.vpn_key_rounded,
              label: 'Koda Göre Katıl',
              color: const Color(0xFF00BCD4),
              onTap: onJoinTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sınıf Kartı ───────────────────────────────────────────────────────────────

class _ClassroomCard extends ConsumerWidget {
  final ClassroomDto classroom;
  const _ClassroomCard({required this.classroom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount =
        classroom.assignments.where((a) => !a.isCompleted).length;

    return GestureDetector(
      onTap: () => context.push('/classrooms/${classroom.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassCard(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: classroom.isOwner
                      ? [const Color(0xFF6A5ACD), const Color(0xFF9C27B0)]
                      : [const Color(0xFF00BCD4), const Color(0xFF4FACFE)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                classroom.isOwner ? Icons.school_rounded : Icons.people_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${classroom.memberCount} üye • '
                    '${classroom.isOwner ? "Öğretmen" : "Öğrenci"}',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (activeCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAB00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeCount ödev',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ── Sınıf Oluştur Sheet ───────────────────────────────────────────────────────

class _CreateClassroomSheet extends ConsumerStatefulWidget {
  final void Function(ClassroomDto) onCreated;
  const _CreateClassroomSheet({required this.onCreated});

  @override
  ConsumerState<_CreateClassroomSheet> createState() =>
      _CreateClassroomSheetState();
}

class _CreateClassroomSheetState
    extends ConsumerState<_CreateClassroomSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Sınıf adı boş olamaz.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final created =
        await ref.read(classroomNotifierProvider.notifier).createClassroom(name);
    if (!mounted) return;
    if (created != null) {
      Navigator.of(context).pop();
      widget.onCreated(created);
    } else {
      final raw = ref.read(classroomNotifierProvider).error ?? '';
      setState(() {
        _loading = false;
        _error = _friendlyError(raw);
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('401') || raw.contains('403')) return 'Yetkisiz işlem.';
    if (raw.contains('SocketException') || raw.contains('Connection')) {
      return 'Sunucuya bağlanılamadı.';
    }
    return raw.isNotEmpty ? raw : 'Bir hata oluştu.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2060),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yeni Sınıf Oluştur',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Sınıf adı (örn. 5-A Matematik)',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _create,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Oluştur',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Koda Katıl Sheet ──────────────────────────────────────────────────────────

class _JoinClassroomSheet extends ConsumerStatefulWidget {
  const _JoinClassroomSheet();

  @override
  ConsumerState<_JoinClassroomSheet> createState() =>
      _JoinClassroomSheetState();
}

class _JoinClassroomSheetState extends ConsumerState<_JoinClassroomSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Davet kodu 6 karakter olmalı.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final joined =
        await ref.read(classroomNotifierProvider.notifier).joinByCode(code);
    if (!mounted) return;
    if (joined != null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _error = ref.read(classroomNotifierProvider).error ?? 'Geçersiz kod.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2060),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sınıfa Katıl',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Öğretmeninden aldığın 6 haneli kodu gir.',
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 8),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w800),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _join,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Katıl',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ortak buton ───────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

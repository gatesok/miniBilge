import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/child_profile_dto.dart';
import '../models/create_child_profile_request.dart';
import '../models/update_child_profile_request.dart';
import '../models/grade_level.dart';
import '../models/english_level.dart';
import '../providers/child_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ChildProfileFormScreen extends ConsumerStatefulWidget {
  final String? profileId; // null = create, non-null = edit

  const ChildProfileFormScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<ChildProfileFormScreen> createState() => _ChildProfileFormScreenState();
}

class _ChildProfileFormScreenState extends ConsumerState<ChildProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  GradeLevel _selectedGradeLevel = GradeLevel.preSchool;
  EnglishLevel? _selectedEnglishLevel;
  int _podcastListeningMode = 1; // 0 = Offline, 1 = Online (default: Online)
  bool _isLoading = false;
  ChildProfileDto? _existingProfile;

  bool get isEditMode => widget.profileId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingProfile();
      });
    }
  }

  void _loadExistingProfile() {
    final state = ref.read(childProfileProvider);
    state.maybeWhen(
      loaded: (profiles) {
        final profile = profiles.where((p) => p.id == widget.profileId).firstOrNull;
        if (profile == null) return;

        _existingProfile = profile;
        setState(() {
          _nameController.text = profile.name;
          _selectedDate = profile.dateOfBirth;
          _selectedGradeLevel = profile.gradeLevelEnum ?? GradeLevel.preSchool;
          _selectedEnglishLevel = profile.englishLevelEnum;
          _podcastListeningMode = profile.podcastListeningMode;
        });
      },
      orElse: () {
        // Profiller henüz yüklenmemişse, yüklenince tekrar dene
        ref.read(childProfileProvider.notifier).loadProfiles().then((_) {
          if (mounted) _loadExistingProfile();
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 5);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Doğum Tarihini Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğum tarihi seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = isEditMode
          ? await ref.read(childProfileProvider.notifier).updateProfile(
                widget.profileId!,
                UpdateChildProfileRequest(
                  name: _nameController.text.trim(),
                  dateOfBirth: _selectedDate!,
                  gradeLevel: _selectedGradeLevel.value,
                  englishLevel: _selectedEnglishLevel?.value,
                  podcastListeningMode: _podcastListeningMode,
                ),
              )
          : await ref.read(childProfileProvider.notifier).createProfile(
                CreateChildProfileRequest(
                  name: _nameController.text.trim(),
                  dateOfBirth: _selectedDate!,
                  gradeLevel: _selectedGradeLevel.value,
                  englishLevel: _selectedEnglishLevel?.value,
                  podcastListeningMode: _podcastListeningMode,
                ),
              );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? 'Profil başarıyla güncellendi'
                    : 'Profil başarıyla oluşturuldu',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          // Error message is already set in state
          final errorMessage = ref.read(childProfileProvider).maybeWhen(
                error: (msg) => msg,
                orElse: () => 'Bir hata oluştu',
              );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)];
    const cardColor = Colors.white;
    const labelStyle = TextStyle(color: Color(0xFF5A4FCF), fontWeight: FontWeight.w700);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditMode ? 'Profil Düzenle' : 'Yeni Profil',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 1,
                        shadows: [Shadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar
                        Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7B61FF).withOpacity(0.28),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: () {
                                final key = _existingProfile?.avatarImageUrl;
                                if (key != null && key.isNotEmpty) {
                                  return Image.asset(
                                    'assets/avatar/characters/$key.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('🧒', style: TextStyle(fontSize: 48)),
                                    ),
                                  );
                                }
                                return const Center(
                                  child: Text('🧒', style: TextStyle(fontSize: 48)),
                                );
                              }(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Form card ──────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              _FieldLabel('Profil Adı'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                                decoration: _inputDecoration('Örn: Ahmet', Icons.person_outline_rounded),
                                textCapitalization: TextCapitalization.words,
                                enabled: !_isLoading,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Lütfen bir isim girin';
                                  if (value.trim().length < 2) return 'İsim en az 2 karakter olmalı';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Birth date
                              _FieldLabel('Doğum Tarihi'),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _isLoading ? null : _selectDate,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFD0C8F8)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF5A4FCF)),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDate == null
                                            ? 'Tarih seçin'
                                            : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w700,
                                          color: _selectedDate == null ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Grade level
                              _FieldLabel('Sınıf Seviyesi (Matematik)'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<GradeLevel>(
                                value: _selectedGradeLevel,
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.black87),
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration(null, Icons.school_rounded),
                                items: GradeLevel.values.map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    level.displayName,
                                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                )).toList(),
                                onChanged: _isLoading ? null : (v) { if (v != null) setState(() => _selectedGradeLevel = v); },
                              ),
                              const SizedBox(height: 20),

                              // English level
                              _FieldLabel('İngilizce Seviyesi'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<EnglishLevel?>(
                                value: _selectedEnglishLevel,
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.black87),
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration('isteğe bağlı', Icons.language_rounded),
                                items: [
                                  DropdownMenuItem<EnglishLevel?>(
                                    value: null,
                                    child: Text('İngilizce yok', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.black87)),
                                  ),
                                  ...EnglishLevel.values.map((level) => DropdownMenuItem<EnglishLevel?>(
                                    value: level,
                                    child: Text(level.displayName, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.black87)),
                                  )),
                                ],
                                onChanged: _isLoading ? null : (v) => setState(() => _selectedEnglishLevel = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Podcast modu card ───────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _podcastListeningMode == 1
                                      ? Icons.cloud_queue_rounded
                                      : Icons.headphones_rounded,
                                  color: const Color(0xFF5A4FCF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Podcast Modu',
                                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                                    Text(
                                      _podcastListeningMode == 0 ? 'Çevrimdışı — cihaz sesi' : 'Çevrimiçi — bulut TTS',
                                      style: GoogleFonts.nunito(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _podcastListeningMode == 1,
                                activeColor: const Color(0xFF5A4FCF),
                                onChanged: _isLoading
                                    ? null
                                    : (val) {
                                        setState(() => _podcastListeningMode = val ? 1 : 0);
                                        if (!val) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '⚠️ Çevrimdışı modda ses kalitesi cihaza göre düşebilir.',
                                                style: GoogleFonts.nunito(fontSize: 13),
                                              ),
                                              backgroundColor: const Color(0xFF5A4FCF),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit button ───────────────────────────
                        GestureDetector(
                          onTap: _isLoading ? null : _handleSubmit,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B5CF5), Color(0xFF5A4FCF)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF5A4FCF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    isEditMode ? 'Güncelle' : 'Profil Oluştur',
                                    style: GoogleFonts.nunito(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF5A4FCF), size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F3FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD0C8F8))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD0C8F8))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF5A4FCF), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF5A4FCF),
      ),
    );
  }
}

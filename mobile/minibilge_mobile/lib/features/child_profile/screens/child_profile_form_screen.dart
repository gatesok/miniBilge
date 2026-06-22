import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  int _podcastListeningMode = 0; // 0 = Offline, 1 = Online
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
      firstDate: DateTime(now.year - 15),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Profil Düzenle' : 'Yeni Profil Oluştur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.child_care,
                          size: 60,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Avatar özelleştirme yakında!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Çocuğun Adı',
                    hintText: 'Örn: Ahmet',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir isim girin';
                    }
                    if (value.trim().length < 2) {
                      return 'İsim en az 2 karakter olmalı';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Date of birth
                InkWell(
                  onTap: _isLoading ? null : _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Doğum Tarihi',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Tarih seçin'
                          : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: _selectedDate == null
                          ? theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            )
                          : theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Grade level
                DropdownButtonFormField<GradeLevel>(
                  value: _selectedGradeLevel,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf Seviyesi (Matematik)',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  items: GradeLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.displayName),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGradeLevel = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),

                // English level
                DropdownButtonFormField<EnglishLevel?>(
                  value: _selectedEnglishLevel,
                  decoration: const InputDecoration(
                    labelText: 'İngilizce Seviyesi (isteğe bağlı)',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<EnglishLevel?>(
                      value: null,
                      child: Text('İngilizce yok'),
                    ),
                    ...EnglishLevel.values.map((level) {
                      return DropdownMenuItem<EnglishLevel?>(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedEnglishLevel = value;
                          });
                        },
                ),
                const SizedBox(height: 32),

                // Podcast dinleme modu
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Podcast Dinleme Modu',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _podcastListeningMode == 0
                                        ? 'Çevrimdışı — cihaz sesi (internet gerekmez)'
                                        : 'Çevrimiçi — bulut TTS (daha doğal ses)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _podcastListeningMode == 1,
                              onChanged: _isLoading
                                  ? null
                                  : (val) => setState(
                                        () => _podcastListeningMode = val ? 1 : 0,
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditMode ? 'Güncelle' : 'Oluştur',
                          style: const TextStyle(fontSize: 16),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../services/api_service.dart';

import '../services/database_service.dart';

import '../providers/character_provider.dart';
import 'character_select_screen.dart';
import '../widgets/character_form_widgets.dart';
import '../widgets/design_colors.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  int _selectedStyleIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _backstoryController = TextEditingController();
  final TextEditingController _visualDescriptionController =
      TextEditingController();
  final TextEditingController _customStyleController =
      TextEditingController();

  bool _isCustomMode = false;
  bool _isGenerating = false;

  String _generatedAvatarUrl = '';

  String _ability1 = '';
  String _ability1Desc = '';
  String _ability2 = '';
  String _ability2Desc = '';

  String _achievement1 = '';
  String _achievement1Desc = '';
  String _achievement2 = '';
  String _achievement2Desc = '';

  bool _useLoreBasedStory = false;

  bool _needUpdateCharacter = false;
  bool _needRegenerateWorld = true;

  // Черновик skeleton, полученный после заполнения полей.
  Map<String, dynamic>? _draft;

  final List<Map<String, String>> _visualStyles = [
    {'name': 'Аниме', 'icon': '🎌'},
    {'name': 'Синема', 'icon': '🎬'},
    {'name': 'Dark Fantasy', 'icon': '🐉'},
    {'name': 'Cyberpunk', 'icon': '🌃'},
    {'name': 'Акварель', 'icon': '🖌️'},
  ];

  @override
  void initState() {
    super.initState();

    // Предыстория влияет на сам мир.
    _backstoryController.addListener(() {
      if (!_needRegenerateWorld && mounted) {
        setState(() => _needRegenerateWorld = true);
      }
    });

    // Остальные поля требуют только обновления персонажа
    // внутри уже существующего skeleton.
    _nameController.addListener(_markCharacterForUpdate);
    _visualDescriptionController.addListener(_markCharacterForUpdate);
    _customStyleController.addListener(_markCharacterForUpdate);
  }

  void _markCharacterForUpdate() {
    if (!_needUpdateCharacter && mounted) {
      setState(() => _needUpdateCharacter = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _backstoryController.dispose();
    _visualDescriptionController.dispose();
    _customStyleController.dispose();

    super.dispose();
  }

  Future<void> _fillMissingFields() async {
    final name = _nameController.text.trim();

    setState(() {
      _isGenerating = true;
    });

    try {
      final visualStyle = _isCustomMode
          ? _customStyleController.text.trim()
          : _visualStyles[_selectedStyleIndex]['name']!;

      final api = ApiService();

      final result = await api.fillmissing(
        characterTemplate: {
          'name': name.isEmpty ? null : name,
          'visual_style': visualStyle,
          'visual_description': _visualDescriptionController.text,
          'backstory': _backstoryController.text,
          'use_lore': _useLoreBasedStory,
          'skills': [
            {
              'name': _ability1,
              'description': _ability1Desc,
            },
            {
              'name': _ability2,
              'description': _ability2Desc,
            },
          ],
          'achievements': [
            {
              'name': _achievement1,
              'description': _achievement1Desc,
            },
            {
              'name': _achievement2,
              'description': _achievement2Desc,
            },
          ],
        },
      );

      final characterData =
          Map<String, dynamic>.from(result['character'] ?? {});

      setState(() {
        // Сохраняем весь результат как черновик.
        _draft = Map<String, dynamic>.from(result);

        if (name.isEmpty && characterData['name'] != null) {
          _nameController.text = characterData['name'] as String;
        }

        if (_backstoryController.text.isEmpty &&
            characterData['backstory'] != null) {
          _backstoryController.text =
              characterData['backstory'] as String;
        }

        if (_visualDescriptionController.text.isEmpty &&
            characterData['visual_description'] != null) {
          _visualDescriptionController.text =
              characterData['visual_description'] as String;
        }

        if (_generatedAvatarUrl.isEmpty &&
            characterData['avatar_url'] != null) {
          _generatedAvatarUrl =
              characterData['avatar_url'] as String;
        }

        final skills = characterData['skills'];

        if (skills is List && skills.isNotEmpty) {
          final skill1 = Map<String, dynamic>.from(skills[0]);

          _ability1 = skill1['name']?.toString() ?? '';
          _ability1Desc = skill1['description']?.toString() ?? '';

          if (skills.length > 1) {
            final skill2 = Map<String, dynamic>.from(skills[1]);

            _ability2 = skill2['name']?.toString() ?? '';
            _ability2Desc = skill2['description']?.toString() ?? '';
          }
        }

        final achievements = characterData['achievements'];

        if (achievements is List && achievements.isNotEmpty) {
          final achievement1 =
              Map<String, dynamic>.from(achievements[0]);

          _achievement1 =
              achievement1['name']?.toString() ?? '';
          _achievement1Desc =
              achievement1['description']?.toString() ?? '';

          if (achievements.length > 1) {
            final achievement2 =
                Map<String, dynamic>.from(achievements[1]);

            _achievement2 =
                achievement2['name']?.toString() ?? '';
            _achievement2Desc =
                achievement2['description']?.toString() ?? '';
          }
        }

        _needRegenerateWorld = false;
        _needUpdateCharacter = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пустые поля заполнены!'),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _generateAvatar() async {
    setState(() => _isGenerating = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _generatedAvatarUrl =
          'https://picsum.photos/300/300?random=$_selectedStyleIndex';
      _isGenerating = false;
    });
  }

  /// Сохраняет персонажа, его навыки, достижения и чат
  /// в локальную БД.
  Future<void> _saveCharacterWithRelations({
    required Character character,
    required String chatId,
    required String skeletonId,
    required String chatName,
  }) async {
    // TODO:
    // Раскомментировать после добавления правильного импорта
    // DatabaseService.
    /*
    final db = DatabaseService();

    await db.insertCharacter(character);

    await db.insertChat(
      id: chatId,
      characterId: character.id,
      skeletonId: skeletonId,
      name: chatName,
    );

    for (final skill in character.skills) {
      await db.insertSkill(
        character.id,
        skill['name'] ?? '',
        skill['description'] ?? '',
      );
    }

    for (final achievement in character.achievements) {
      await db.insertAchievement(
        character.id,
        achievement['name'] ?? '',
        achievement['description'] ?? '',
      );
    }
    */
  }

  /// Меняет стиль, очищает описание и генерирует новый аватар.
  void _regenerateCharacter() {
    setState(() {
      _generatedAvatarUrl = '';
      _selectedStyleIndex =
          (_selectedStyleIndex + 1) % _visualStyles.length;
      _visualDescriptionController.clear();
    });

    _generateAvatar();
  }

  /// Обновляет персонажа внутри существующего черновика skeleton.
  void _updateDraftFromFields() {
    if (_draft == null) return;

    final characterData =
        Map<String, dynamic>.from(
      _draft!['character_data'] ?? {},
    );

    characterData['name'] =
        _nameController.text.trim();

    characterData['visual_description'] =
        _visualDescriptionController.text.trim();

    characterData['visual_style'] = _isCustomMode
        ? _customStyleController.text.trim()
        : _visualStyles[_selectedStyleIndex]['name']!;

    characterData['skills'] = [
      {
        'name': _ability1,
        'description': _ability1Desc,
      },
      {
        'name': _ability2,
        'description': _ability2Desc,
      },
    ];

    characterData['achievements'] = [
      {
        'name': _achievement1,
        'description': _achievement1Desc,
      },
      {
        'name': _achievement2,
        'description': _achievement2Desc,
      },
    ];

    characterData['use_lore'] = _useLoreBasedStory;

    _draft!['character_data'] = characterData;
  }

  Future<void> _createCharacter() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Введите имя персонажа');
      return;
    }

    if (_backstoryController.text.trim().isEmpty) {
      _showError('Напишите предысторию');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final visualStyle = _isCustomMode
          ? _customStyleController.text.trim()
          : _visualStyles[_selectedStyleIndex]['name']!;

      final api = ApiService();

      final characterData = {
        'name': _nameController.text.trim(),
        'visual_style': visualStyle,
        'visual_description':
            _visualDescriptionController.text.trim(),
        'backstory': _backstoryController.text.trim(),
        'use_lore': _useLoreBasedStory,
        'skills': [
          {
            'name': _ability1,
            'description': _ability1Desc,
          },
          {
            'name': _ability2,
            'description': _ability2Desc,
          },
        ],
        'achievements': [
          {
            'name': _achievement1,
            'description': _achievement1Desc,
          },
          {
            'name': _achievement2,
            'description': _achievement2Desc,
          },
        ],
      };

      late Map<String, dynamic> result;

      if (_needRegenerateWorld) {
        // Изменилась предыстория/лор →
        // создаём новый skeleton.
        result = await api.generateWorld(
          characterTemplate: characterData,
          skelet: null,
        );
      } else if (_needUpdateCharacter) {
        // Изменились только незначительные поля →
        // используем существующий skeleton.
        _updateDraftFromFields();

        result = await api.generateWorld(
          characterTemplate: characterData,
          skelet: _draft?['skelet'],
        );

        _needUpdateCharacter = false;
        _needRegenerateWorld = true;
        _draft = null;
      } else {
        // Ничего не изменилось →
        // используем существующий skeleton.
        result = await api.generateWorld(
          characterTemplate: characterData,
          skelet: _draft?['skelet'],
        );

        _draft = null;
      }

      final character = Character(
        id: result['character_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: characterData['name'] as String,
        visualStyle:
            characterData['visual_style'] as String,
        backstory:
            characterData['backstory'] as String,
        visualDescription:
            characterData['visual_description'] as String,
        avatarUrl:
            _generatedAvatarUrl.isEmpty
                ? null
                : _generatedAvatarUrl,
        skills: (characterData['skills'] as List)
            .map(
              (e) => Map<String, String>.from(e as Map),
            )
            .toList(),
        achievements: (characterData['achievements'] as List)
            .map(
              (e) => Map<String, String>.from(e as Map),
            )
            .toList(),
      );

      await context
          .read<CharacterProvider>()
          .addCharacter(character);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CharacterSelectScreen(),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание персонажа'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regenerateCharacter,
            tooltip: 'Создать другого персонажа',
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  FillMissingButton(
                    onPressed: _fillMissingFields,
                  ),
                  const SizedBox(height: 16),

                  AvatarWidget(
                    avatarUrl: _generatedAvatarUrl,
                    styleName:
                        _visualStyles[_selectedStyleIndex]['name']!,
                    onTap: _generateAvatar,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '👤 ВИЗУАЛЬНОЕ ОПИСАНИЕ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  VisualDescriptionField(
                    controller: _visualDescriptionController,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '🎨 ВИЗУАЛЬНЫЙ СТИЛЬ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      _visualStyles.length,
                      (index) {
                        final style = _visualStyles[index];

                        final isSelected =
                            !_isCustomMode &&
                            _selectedStyleIndex == index;

                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                style['icon']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                style['name']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.background
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _isCustomMode = false;
                              _selectedStyleIndex = index;
                              _needUpdateCharacter = true;
                            });
                          },
                          backgroundColor:
                              AppTheme.surface,
                          selectedColor:
                              AppTheme.primary,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_isCustomMode) ...[
                    CustomStyleInput(
                      controller: _customStyleController,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    '📝 ИМЯ ПЕРСОНАЖА',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  CharacterNameField(
                    controller: _nameController,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '📖 ПРЕДЫСТОРИЯ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  BackstoryField(
                    controller: _backstoryController,
                  ),
                  const SizedBox(height: 16),

                  LoreCheckbox(
                    value: _useLoreBasedStory,
                    onChanged: (value) {
                      setState(() {
                        _useLoreBasedStory =
                            value ?? false;
                        _needRegenerateWorld = true;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '⚔️ СПОСОБНОСТИ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  SkillsSection(
                    ability1: _ability1,
                    ability1Desc: _ability1Desc,
                    ability2: _ability2,
                    ability2Desc: _ability2Desc,
                    onAbility1Changed: (v) {
                      setState(() {
                        _ability1 = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAbility1DescChanged: (v) {
                      setState(() {
                        _ability1Desc = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAbility2Changed: (v) {
                      setState(() {
                        _ability2 = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAbility2DescChanged: (v) {
                      setState(() {
                        _ability2Desc = v;
                        _needUpdateCharacter = true;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '🏆 ДОСТИЖЕНИЯ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AchievementsSection(
                    achievement1: _achievement1,
                    achievement1Desc: _achievement1Desc,
                    achievement2: _achievement2,
                    achievement2Desc: _achievement2Desc,
                    onAchievement1Changed: (v) {
                      setState(() {
                        _achievement1 = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAchievement1DescChanged: (v) {
                      setState(() {
                        _achievement1Desc = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAchievement2Changed: (v) {
                      setState(() {
                        _achievement2 = v;
                        _needUpdateCharacter = true;
                      });
                    },
                    onAchievement2DescChanged: (v) {
                      setState(() {
                        _achievement2Desc = v;
                        _needUpdateCharacter = true;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  CreateCharacterButton(
                    onPressed: _createCharacter,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
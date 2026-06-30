import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/api_service.dart';
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
  final TextEditingController _visualDescriptionController = TextEditingController();
  final TextEditingController _customStyleController = TextEditingController();
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
  bool _needRegenerateWorld = true;

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
    _backstoryController.addListener(() {
      if (_needRegenerateWorld == false) {
        setState(() => _needRegenerateWorld = true);
      }
    });
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
    setState(() => _isGenerating = true);

    try {
      final visualStyle = _isCustomMode
          ? _customStyleController.text.trim()
          : _visualStyles[_selectedStyleIndex]['name']!;

      final api = ApiService();
      final result = await api.generateWorld(
        characterTemplate: {
          'name': name.isEmpty ? null : name,
          'visual_style': visualStyle,
          'visual_description': _visualDescriptionController.text,
          'backstory': _backstoryController.text,
          'use_lore': _useLoreBasedStory,
          'skills': [
            {'name': _ability1, 'description': _ability1Desc},
            {'name': _ability2, 'description': _ability2Desc},
          ],
          'achievements': [
            {'name': _achievement1, 'description': _achievement1Desc},
            {'name': _achievement2, 'description': _achievement2Desc},
          ],
        },
      );

      final characterData = result['character'];

      setState(() {
        if (name.isEmpty && characterData['name'] != null) {
          _nameController.text = characterData['name'];
        }
        if (_backstoryController.text.isEmpty && characterData['backstory'] != null) {
          _backstoryController.text = characterData['backstory'];
        }
        if (_visualDescriptionController.text.isEmpty && characterData['visual_description'] != null) {
          _visualDescriptionController.text = characterData['visual_description'];
        }
        if (_generatedAvatarUrl.isEmpty && characterData['avatar_url'] != null) {
          _generatedAvatarUrl = characterData['avatar_url'];
        }

        if (characterData['skills'] != null && characterData['skills'].isNotEmpty) {
          _ability1 = characterData['skills'][0]['name'];
          _ability1Desc = characterData['skills'][0]['description'];
          if (characterData['skills'].length > 1) {
            _ability2 = characterData['skills'][1]['name'];
            _ability2Desc = characterData['skills'][1]['description'];
          }
        }

        if (characterData['achievements'] != null && characterData['achievements'].isNotEmpty) {
          _achievement1 = characterData['achievements'][0]['name'];
          _achievement1Desc = characterData['achievements'][0]['description'];
          if (characterData['achievements'].length > 1) {
            _achievement2 = characterData['achievements'][1]['name'];
            _achievement2Desc = characterData['achievements'][1]['description'];
          }
        }
        _needRegenerateWorld = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пустые поля заполнены!')),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _generateAvatar() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _generatedAvatarUrl = 'https://picsum.photos/300/300?random=$_selectedStyleIndex';
      _isGenerating = false;
    });
  }

  void _regenerateCharacter() {
    setState(() {
      _generatedAvatarUrl = '';
      _selectedStyleIndex = (_selectedStyleIndex + 1) % _visualStyles.length;
      _visualDescriptionController.clear();
    });
    _generateAvatar();
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
      Map<String, dynamic> result;

      final characterData = {
        'name': _nameController.text,
        'visual_style': visualStyle,
        'visual_description': _visualDescriptionController.text,
        'backstory': _backstoryController.text,
        'use_lore': _useLoreBasedStory,
        'skills': [
          {'name': _ability1, 'description': _ability1Desc},
          {'name': _ability2, 'description': _ability2Desc},
        ],
        'achievements': [
          {'name': _achievement1, 'description': _achievement1Desc},
          {'name': _achievement2, 'description': _achievement2Desc},
        ],
      };

      if (_needRegenerateWorld) {
        result = await api.generateWorld(characterTemplate: characterData);
      } else {
        result = await api.updateCharacter(characterTemplate: characterData);
        _needRegenerateWorld = true;
      }

      final character = Character(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: characterData['name'] as String,
        visualStyle: characterData['visual_style'] as String,
        backstory: characterData['backstory'] as String,
        visualDescription: characterData['visual_description'] as String,
        avatarUrl: _generatedAvatarUrl.isEmpty ? null : _generatedAvatarUrl,
        skills: (characterData['skills'] as List?)?.cast<Map<String, String>>() ?? [],
        achievements: (characterData['achievements'] as List?)?.cast<Map<String, String>>() ?? [],
      );

      await context.read<CharacterProvider>().addCharacter(character);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSelectScreen(),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание персонажа'),
        centerTitle: true,
        elevation: 0,
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FillMissingButton(onPressed: _fillMissingFields),
                  const SizedBox(height: 16),

                  AvatarWidget(
                    avatarUrl: _generatedAvatarUrl,
                    styleName: _visualStyles[_selectedStyleIndex]['name']!,
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
                  VisualDescriptionField(controller: _visualDescriptionController),
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
                    children: List.generate(_visualStyles.length, (index) {
                      final style = _visualStyles[index];
                      final isSelected = !_isCustomMode && _selectedStyleIndex == index;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(style['icon']!, style: const TextStyle(fontSize: 16)),
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
                            _isCustomMode = (style['name'] == 'Свой');
                            if (style['name'] != 'Свой') {
                              _selectedStyleIndex = index;
                            }
                          });
                        },
                        backgroundColor: AppTheme.surface,
                        selectedColor: AppTheme.primary,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.divider,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  if (_isCustomMode) ...[
                    CustomStyleInput(controller: _customStyleController),
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
                  CharacterNameField(controller: _nameController),
                  const SizedBox(height: 24),

                  const Text(
                    '📖 ПРЕДЫСТОРИЯ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BackstoryField(controller: _backstoryController),
                  const SizedBox(height: 16),

                  LoreCheckbox(
                    value: _useLoreBasedStory,
                    onChanged: (value) => setState(() {
                      _useLoreBasedStory = value ?? false;
                      _needRegenerateWorld = true;
                    }),
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
                    onAbility1Changed: (v) => _ability1 = v,
                    onAbility1DescChanged: (v) => _ability1Desc = v,
                    onAbility2Changed: (v) => _ability2 = v,
                    onAbility2DescChanged: (v) => _ability2Desc = v,
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
                    onAchievement1Changed: (v) => _achievement1 = v,
                    onAchievement1DescChanged: (v) => _achievement1Desc = v,
                    onAchievement2Changed: (v) => _achievement2 = v,
                    onAchievement2DescChanged: (v) => _achievement2Desc = v,
                  ),
                  const SizedBox(height: 24),

                  CreateCharacterButton(onPressed: _createCharacter),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../providers/character_provider.dart';
import 'character_select_screen.dart';
import 'package:provider/provider.dart';


class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  
  
  bool _isLoading = false;
  
  Character? _character;     
  int _selectedStyleIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _backstoryController = TextEditingController();
  final TextEditingController _visualDescriptionController = TextEditingController();
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
  bool _need_regenerate_world = false;

  final List<Map<String, String>> _visualStyles = [
    {'name': 'Аниме', 'icon': '🎌', 'prompt': 'anime style...'},
    {'name': 'Синема', 'icon': '🎬', 'prompt': 'cinematic lighting...'},
    {'name': 'Dark Fantasy', 'icon': '🐉', 'prompt': 'dark fantasy...'},
    {'name': 'Cyberpunk', 'icon': '🌃', 'prompt': 'cyberpunk...'},
    {'name': 'Акварель', 'icon': '🖌️', 'prompt': 'watercolor...'},
  ];

 

 @override
void initState() {
  super.initState();
  _loadCharacters();
  
  // Слушаем изменения предыстории
  _backstoryController.addListener(() {
    if (_needRegenerateWorld == false) {
      setState(() => _needRegenerateWorld = true);
    }
  });
}

 
Future<void> _fillMissingFields() async {
  final name = _nameController.text.trim();
  
  setState(() => _isGenerating = true);

  try {
    final visualStyle = _visualStyles[_selectedStyleIndex]['name']!;

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
    
    // Только заполняем поля, НЕ сохраняем
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


  Future<void> _loadCharacters() async {
  await Future.delayed(const Duration(milliseconds: 500));
  setState(() {
    _character = Character(
      id: '1',
      worldId: '',
      name: '',
      classType: '',
      backstory: '',
      visualDescription: '',
      useLoreBasedStory: true,
      createdAt: DateTime.now(),
      skills: [
        {'name': 'Нажми чтобы заполнить', 'description': 'Нажми чтобы заполнить'},
        {'name': 'Нажми чтобы заполнить', 'description': 'Нажми чтобы заполнить'},
      ],
      achievements: [
        {'name': 'Нажми чтобы заполнить', 'description': 'Нажми чтобы заполнить'},
        {'name': 'Нажми чтобы заполнить', 'description': 'Нажми чтобы заполнить'},
      ],
    );
    _isLoading = false;
    _updateUI();  
  });
}

 void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

 
 void _updateUI() {
  if (_character == null) return;
  _backstoryController.text = _character!.backstory;
  
  if (_character!.skills.isNotEmpty) {
    _ability1 = _character!.skills[0]['name'] ?? 'Навык 1';
    _ability1Desc = _character!.skills[0]['description'] ?? 'Описание';
    if (_character!.skills.length > 1) {
      _ability2 = _character!.skills[1]['name'] ?? 'Навык 2';
      _ability2Desc = _character!.skills[1]['description'] ?? 'Описание';
    }
  }
  
  if (_character!.achievements.isNotEmpty) {
    _achievement1 = _character!.achievements[0]['name'] ?? 'Достижение 1';
    _achievement1Desc = _character!.achievements[0]['description'] ?? 'Описание';
    if (_character!.achievements.length > 1) {
      _achievement2 = _character!.achievements[1]['name'] ?? 'Достижение 2';
      _achievement2Desc = _character!.achievements[1]['description'] ?? 'Описание';
    }
  }
  setState(() {});
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
    final visualStyle = _visualStyles[_selectedStyleIndex]['name']!;
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
      result = await api.generateWorld(characterData);
      _needRegenerateWorld = false;
    } else {
      result = await api.updateCharacter(characterData);
    }

    final worldId = result['world_id'];
    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      worldId: worldId,
      name: characterData['name'],
      visualStyle: characterData['visual_style'],
      backstory: characterData['backstory'],
      visualDescription: characterData['visual_description'],
      avatarUrl: _generatedAvatarUrl.isEmpty ? null : _generatedAvatarUrl,
      createdAt: DateTime.now(),
      useLoreBasedStory: characterData['use_lore'],
      skills: characterData['skills'],
      achievements: characterData['achievements'],
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


Widget _buildStyleChip({
    required int index,
    required String name,
    required String icon,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(name, style: TextStyle(color: isSelected ? const Color(0xFF0D1117) : const Color(0xFFE6EDF3))),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _isCustomMode = (name == 'Свой');
          if (name != 'Свой') {
            _selectedStyleIndex = index;
          } 
        });
      },
      backgroundColor: const Color(0xFF161B22),
      selectedColor: const Color(0xFFFBBF24),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF3D444D))),
    );
  }
}
 @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

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
        : SingleChildScrollView(  // ← заменил Expanded + ListView на SingleChildScrollView
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _regenerateCharacter,  
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: const Color(0xFF0D1117),
                  ),
                  child: const Text('🎲 Дополнить пустые поля'),
                ),
                 const SizedBox(height: 16),
                // Аватар
                GestureDetector(
                  onTap: _generateAvatar,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFBBF24), width: 2),
                      image: _generatedAvatarUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(_generatedAvatarUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _generatedAvatarUrl.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image, size: 60, color: Color(0xFF8B949E)),
                              const SizedBox(height: 12),
                              Text(
                                'Нажми, чтобы сгенерировать аватар\n(стиль: ${_visualStyles[_selectedStyleIndex]['name']})',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('👤 ВИЗУАЛЬНОЕ ОПИСАНИЕ', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _visualDescriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: Color(0xFFE6EDF3)),
                    decoration: const InputDecoration(
                      hintText: 'Опиши внешность персонажа...',
                      hintStyle: TextStyle(color: Color(0xFF8B949E)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('🎨 ВИЗУАЛЬНЫЙ СТИЛЬ', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_visualStyles.length, (index) {
                    final style = _visualStyles[index];
                    final isSelected = !_isCustomMode && _selectedStyleIndex == index;
                    return _buildStyleChip(
                      index: index,
                      name: style['name']!,
                      icon: style['icon']!,
                      isSelected: isSelected,
                    );
                  }),
                ),
                const SizedBox(height: 24),
                const Text('📝 ИМЯ ПЕРСОНАЖА', style: TextStyle(color: Color(0xFFFBBF24),fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xFFE6EDF3)),
                  decoration: const InputDecoration(
                    hintText: 'Введите имя персонажа',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('📖 ПРЕДЫСТОРИЯ', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _backstoryController,
                    maxLines: 5,
                    style: const TextStyle(color: Color(0xFFE6EDF3)),
                    decoration: const InputDecoration(
                      hintText: 'Напиши предысторию персонажа...',
                      hintStyle: TextStyle(color: Color(0xFF8B949E)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _useLoreBasedStory,
                      onChanged: (value) => setState(() => _useLoreBasedStory = value ?? false;  _needRegenerateWorld = true;),
                      activeColor: const Color(0xFFFBBF24),
                    ),
                    const Expanded(child: Text('Сюжет на основе лора персонажа', style: TextStyle(color: Color(0xFFE6EDF3)))),
                  ],
                ),
                const SizedBox(height: 24),
                // ⚔️ СПОСОБНОСТИ
                const Text('⚔️ СПОСОБНОСТИ', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _ability1),
                              onChanged: (v) => _ability1 = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Название',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _ability1Desc),
                              onChanged: (v) => _ability1Desc = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Описание',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF3D444D)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _ability2),
                              onChanged: (v) => _ability2 = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Название',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _ability2Desc),
                              onChanged: (v) => _ability2Desc = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Описание',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 🏆 ДОСТИЖЕНИЯ
                const Text('🏆 ДОСТИЖЕНИЯ', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _achievement1),
                              onChanged: (v) => _achievement1 = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Название',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _achievement1Desc),
                              onChanged: (v) => _achievement1Desc = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Описание',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF3D444D)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _achievement2),
                              onChanged: (v) => _achievement2 = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Название',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _achievement2Desc),
                              onChanged: (v) => _achievement2Desc = v,
                              style: const TextStyle(color: Color(0xFFE6EDF3)),
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Описание',
                                labelStyle: TextStyle(color: Color(0xFF8B949E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                 
                ElevatedButton(
                  onPressed: _createCharacter,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: const Color(0xFF0D1117),
                  ),
                  child: const Text('Создать персонажа'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
  );
}

  Widget _buildAbilityRow({
    required TextEditingController nameController,
    required TextEditingController descController,
    required Function(String) onNameChanged,
    required Function(String) onDescChanged,
    required String nameHint,
    required String descHint,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Название', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: nameController,
                onChanged: onNameChanged,
                style: const TextStyle(color: Color(0xFFE6EDF3)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  hintText: nameHint,
                  hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Описание', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: descController,
                onChanged: onDescChanged,
                style: const TextStyle(color: Color(0xFFE6EDF3)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  hintText: descHint,
                  hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleChip({
    required int index,
    required String name,
    required String icon,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(name, style: TextStyle(color: isSelected ? const Color(0xFF0D1117) : const Color(0xFFE6EDF3))),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _isCustomMode = (name == 'Свой');
          if (name != 'Свой') {
            _selectedStyleIndex = index;
          } 
        });
      },
      backgroundColor: const Color(0xFF161B22),
      selectedColor: const Color(0xFFFBBF24),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF3D444D))),
    );
  }
}
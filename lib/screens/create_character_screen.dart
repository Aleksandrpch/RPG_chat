import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<Character> _characters = [];
  bool _isLoading = true;

  int _selectedStyleIndex = 0;
  final TextEditingController _customStyleController = TextEditingController();
  final TextEditingController _backstoryController = TextEditingController();
  final TextEditingController _visualDescriptionController = TextEditingController();
  bool _isCustomMode = false;
  bool _isGenerating = false;
  String _generatedAvatarUrl = '';
  String _ability1 = 'Стальной удар';
  String _ability1Desc = 'Наносит +20% урона в ближнем бою';
  String _ability2 = 'Боевой клич';
  String _ability2Desc = 'Повышает силу союзников на 10%';
  String _achievement1 = 'Первый шаг';
  String _achievement1Desc = 'Сделал первое действие в игре';
  String _achievement2 = 'Говорун';
  String _achievement2Desc = 'Отправил 10 сообщений';
  bool _useLoreBasedStory = false;

  final List<Map<String, String>> _visualStyles = [
    {'name': 'Аниме', 'icon': '🎌', 'prompt': 'anime style...'},
    {'name': 'Синема', 'icon': '🎬', 'prompt': 'cinematic lighting...'},
    {'name': 'Dark Fantasy', 'icon': '🐉', 'prompt': 'dark fantasy...'},
    {'name': 'Cyberpunk', 'icon': '🌃', 'prompt': 'cyberpunk...'},
    {'name': 'Акварель', 'icon': '🖌️', 'prompt': 'watercolor...'},
    {'name': 'Свой', 'icon': '✏️', 'prompt': ''},
  ];

  final List<String> _backstoryTemplates = [
    'Опиши своего персонажа. Кто он? Откуда пришёл?',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCharacters();
    _updateBackstoryForStyle(0);
  }

  void _updateBackstoryForStyle(int index) {
    if (index < _backstoryTemplates.length) {
      _backstoryController.text = _backstoryTemplates[index];
    }
  }

  Future<void> _loadCharacters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _characters = [
        Character(
          id: '1',
          name: 'Эйнар',
          classType: 'воин',
          backstory: 'Твой отец пал от рук Теней...',
          visualDescription: '',
          useLoreBasedStory: true,
          createdAt: DateTime.now(),
          skills: [
            {'name': 'Удар грома', 'description': '+20% урона Теням'},
            {'name': 'Стойкость аса', 'description': '-15% урона'},
          ],
          achievements: [
            {'name': 'Первый шаг', 'description': 'Сделал первое действие'},
            {'name': 'Говорун', 'description': 'Отправил 10 сообщений'},
          ],
        ),
         Character(
          id: '2',
          name: 'Эльдарион',
          classType: 'маг',
          backstory: 'Хранитель древней библиотеки...',
          visualDescription: '',
          useLoreBasedStory: true,
          createdAt: DateTime.now(),
          skills: [
            {'name': 'Печать забвения', 'description': 'Запечатывает врага'},
            {'name': 'Зов предков', 'description': 'Призывает духа'},
          ],
          achievements: [
            {'name': 'Знаток', 'description': 'Нашёл 5 свитков'},
            {'name': 'Мудрец', 'description': 'Решил 3 загадки'},
          ],
        ),
        Character(
          id: '3',
          name: 'Лира',
          classType: 'вор',
          backstory: 'Тень из Сумеречных земель...',
          visualDescription: '',
          useLoreBasedStory: true,
          createdAt: DateTime.now(),
          skills: [
            {'name': 'Скрытность', 'description': '+30% к незаметности'},
            {'name': 'Отравленный клинок', 'description': 'Яд наносит урон'},
          ],
          achievements: [
            {'name': 'Невидимка', 'description': 'Прошёл мимо 5 врагов'},
            {'name': 'Карманник', 'description': 'Украл ценный предмет'},
          ],
        ),
      ];
      _isLoading = false;
      _updateUIForCharacter(0);
    });
  }

  void _updateUIForCharacter(int index) {
    final char = _characters[index];
    _backstoryController.text = char.backstory;
    if (char.skills.isNotEmpty) {
      _ability1 = char.skills[0]['name'] ?? 'Навык 1';
      _ability1Desc = char.skills[0]['description'] ?? 'Описание';
      if (char.skills.length > 1) {
        _ability2 = char.skills[1]['name'] ?? 'Навык 2';
        _ability2Desc = char.skills[1]['description'] ?? 'Описание';
      }
    }
    if (char.achievements.isNotEmpty) {
      _achievement1 = char.achievements[0]['name'] ?? 'Достижение 1';
      _achievement1Desc = char.achievements[0]['description'] ?? 'Описание';
      if (char.achievements.length > 1) {
        _achievement2 = char.achievements[1]['name'] ?? 'Достижение 2';
        _achievement2Desc = char.achievements[1]['description'] ?? 'Описание';
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

  Future<void> _createCharacter() async {
    setState(() => _isGenerating = true);
    final style = _visualStyles[_selectedStyleIndex];
    final visualStyle = _isCustomMode ? _customStyleController.text : style['name']!;

    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: visualStyle,
      classType: visualStyle,
      backstory: _backstoryController.text,
      visualDescription: _visualDescriptionController.text,
      avatarUrl: _generatedAvatarUrl.isEmpty ? null : _generatedAvatarUrl,
      createdAt: DateTime.now(),
      useLoreBasedStory: _useLoreBasedStory,
      skills: [
        {'name': _ability1, 'description': _ability1Desc},
        {'name': _ability2, 'description': _ability2Desc},
      ],
      achievements: [
        {'name': _achievement1, 'description': _achievement1Desc},
        {'name': _achievement2, 'description': _achievement2Desc},
      ],
    );

    await context.read<CharacterProvider>().addCharacter(character);
    if (mounted) Navigator.pop(context);
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
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _characters.length,
                    (index) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _updateUIForCharacter(index);
                      });
                    },
                    itemCount: _characters.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  onChanged: (value) => setState(() => _useLoreBasedStory = value ?? false),
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
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(16), // ← скруглённые углы
                            ),
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
                                        maxLines: null, // ← автоматическое расширение
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
                                        maxLines: null, // ← автоматическое расширение
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
                                        maxLines: null, // ← автоматическое расширение
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
                                        maxLines: null, // ← автоматическое расширение
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
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(16), // ← скруглённые углы
                            ),
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
                                        maxLines: null, // ← автоматическое расширение
                                        decoration: const InputDecoration(
                                          labelText: ' Название',
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
                                        maxLines: null, // ← автоматическое расширение
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
                                        maxLines: null, // ← автоматическое расширение
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
                                        maxLines: null, // ← автоматическое расширение
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
                      );
                    },
                  ),
                ),
              ],
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
            _updateBackstoryForStyle(index);
          } else {
            _backstoryController.text = _backstoryTemplates.last;
          }
        });
      },
      backgroundColor: const Color(0xFF161B22),
      selectedColor: const Color(0xFFFBBF24),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF3D444D))),
    );
  }
}
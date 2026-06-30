import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import 'create_character_screen.dart';
import '../widgets/character_form_widgets.dart';



class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  void _createNewCharacter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCharacterScreen()),
    );
  }

  void _startGame(BuildContext context, Character character, CharacterProvider provider) {
    provider.setCurrentCharacter(character);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Чат скоро будет')),
    );
  }

  void _confirmDelete(BuildContext context, Character character, CharacterProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить персонажа?'),
        content: Text('${character.name} будет удалён безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCharacter(character.id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatLastPlayed(DateTime? time) {
    if (time == null) return 'Нет сохранений';
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays} дн. назад';
    if (diff.inHours > 0) return '${diff.inHours} ч. назад';
    return '${diff.inMinutes} мин. назад';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPG Tower'),
        centerTitle: true,
      ),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          final characters = provider.characters;

          if (characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Нет созданных персонажей',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createNewCharacter(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text('Создать персонажа'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return GestureDetector(
                onTap: () => _startGame(context, character, provider),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            image: character.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(character.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: character.avatarUrl == null
                              ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
            
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _confirmDelete(context, character, provider),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewCharacter(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
    );
  }
}
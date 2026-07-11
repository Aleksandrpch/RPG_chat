import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import 'create_character_screen.dart';
import '../widgets/character_select_widgets.dart';
import 'chat_screen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
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
            return EmptyCharacterList(
              onCreatePressed: () => _createNewCharacter(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return CharacterCard(
                character: character,
                onTap: () => _startGame(context, character, provider),
                onDelete: () => _confirmDelete(context, character, provider),
              );
            },
          );
        },
      ),
      floatingActionButton: AddCharacterFAB(
        onPressed: () => _createNewCharacter(context),
      ),
    );  // ← закрывает Scaffold
  }      // ← закрывает build
}        // ← закрывает класс
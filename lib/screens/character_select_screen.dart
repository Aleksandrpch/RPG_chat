import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import '../services/database_service.dart';
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

  Future<void> _startGame(
    BuildContext context,
    Character character,
    CharacterProvider provider,
  ) async {
    try {
      // 1. Устанавливаем текущего персонажа в Provider
      provider.setCurrentCharacter(character);

      // 2. Ищем chat_id в локальной БД
      final db = DatabaseService();
      final chatId = await db.getChatIdByCharacter(character.id);

      if (chatId == null) {
        // Если чата нет — создаём новый
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Чат не найден')),
          );
        }
        return;
      }

      // 3. Переходим в ChatScreen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Character character,
    CharacterProvider provider,
  ) async {
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
            onPressed: () async {
              try {
                await provider.deleteCharacter(character.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
          // Показываем загрузку
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final characters = provider.characters;

          // Пустой список
          if (characters.isEmpty) {
            return EmptyCharacterList(
              onCreatePressed: () => _createNewCharacter(context),
            );
          }

          // Список персонажей
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
    );
  }
}
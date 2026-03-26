import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';
import '../models/character.dart';

class CharacterSelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RPG Tower'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          if (provider.characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Нет созданных персонажей'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createNewCharacter(context),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),  // увеличил отступы
                        textStyle: const TextStyle(fontSize: 18),  // размер текста
                        minimumSize: const Size(200, 48),  // минимальная ширина и высота
                    ),
                    child: Text('Создать персонажа'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.characters.length,
            itemBuilder: (context, index) {
              final character = provider.characters[index];
              return _buildCharacterCard(context, character, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewCharacter(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, Character character, CharacterProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setCurrentCharacter(character);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Аватар
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
              SizedBox(width: 16),
              // Имя и время
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      character.classType,
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatLastPlayed(character.lastPlayed),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Кнопка удаления (опционально)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _confirmDelete(context, character, provider),
              ),
            ],
          ),
        ),
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

  void _createNewCharacter(BuildContext context) {
    // TODO: открыть экран создания персонажа
    // пока просто заглушка
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Скоро здесь будет создание персонажа')),
    );
  }

  void _confirmDelete(BuildContext context, Character character, CharacterProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить персонажа?'),
        content: Text('${character.name} будет удалён безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCharacter(character.id);
              Navigator.pop(ctx);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
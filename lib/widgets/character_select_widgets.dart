import 'package:flutter/material.dart';
import '../models/character.dart';
import '../widgets/design_colors.dart';

// ============================================================
// 1. КНОПКА "СОЗДАТЬ ПЕРСОНАЖА" (для пустого списка)
// ============================================================
class CreateFirstCharacterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateFirstCharacterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        minimumSize: const Size(200, 48),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
      child: const Text('Создать персонажа'),
    );
  }
}

// ============================================================
// 2. КАРТОЧКА ПЕРСОНАЖА
// ============================================================
class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                    // Сюда можно чет вставить инфу про перса
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 3. ПУСТОЙ СПИСОК (нет персонажей)
// ============================================================
class EmptyCharacterList extends StatelessWidget {
  final VoidCallback onCreatePressed;
  const EmptyCharacterList({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Нет созданных персонажей',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          CreateFirstCharacterButton(onPressed: onCreatePressed),
        ],
      ),
    );
  }
}

// ============================================================
// 4. ПЛАВАЮЩАЯ КНОПКА (FAB)
// ============================================================
class AddCharacterFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const AddCharacterFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.background,
      elevation: 4,
      highlightElevation: 8,
    );
  }
}
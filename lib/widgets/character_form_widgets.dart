import 'package:flutter/material.dart';
import '../widgets/design_colors.dart';

// 1. Кнопка "Дополнить пустые поля"
class FillMissingButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FillMissingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text('🎲 Дополнить пустые поля'),
    );
  }
}

// 2. Аватар
class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final String styleName;
  final VoidCallback onTap;
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.styleName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary, width: 2),
          image: avatarUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: avatarUrl.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 60, color: AppTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'Нажми, чтобы сгенерировать аватар\n(стиль: $styleName)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

// 3. Визуальное описание
class VisualDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const VisualDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Опиши внешность персонажа...',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// 4. Кастомный стиль
class CustomStyleInput extends StatelessWidget {
  final TextEditingController controller;
  const CustomStyleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Введите свой стиль (например: "стимпанк, грубый рисунок")',
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        border: OutlineInputBorder(),
      ),
    );
  }
}

// 5. Имя персонажа
class CharacterNameField extends StatelessWidget {
  final TextEditingController controller;
  const CharacterNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Введите имя персонажа',
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        border: OutlineInputBorder(),
      ),
    );
  }
}

// 6. Предыстория
class BackstoryField extends StatelessWidget {
  final TextEditingController controller;
  const BackstoryField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Напиши предысторию персонажа...',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// 7. Чекбокс "Сюжет на основе лора"
class LoreCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const LoreCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
        Expanded(
          child: Text(
            'Сюжет на основе лора персонажа',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

// 8. Блок способностей
class SkillsSection extends StatelessWidget {
  final String ability1;
  final String ability1Desc;
  final String ability2;
  final String ability2Desc;
  final ValueChanged<String> onAbility1Changed;
  final ValueChanged<String> onAbility1DescChanged;
  final ValueChanged<String> onAbility2Changed;
  final ValueChanged<String> onAbility2DescChanged;

  const SkillsSection({
    super.key,
    required this.ability1,
    required this.ability1Desc,
    required this.ability2,
    required this.ability2Desc,
    required this.onAbility1Changed,
    required this.onAbility1DescChanged,
    required this.onAbility2Changed,
    required this.onAbility2DescChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSkillRow(
                name: ability1,
                desc: ability1Desc,
                onNameChanged: onAbility1Changed,
                onDescChanged: onAbility1DescChanged,
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.divider),
              const SizedBox(height: 16),
              _buildSkillRow(
                name: ability2,
                desc: ability2Desc,
                onNameChanged: onAbility2Changed,
                onDescChanged: onAbility2DescChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillRow({
    required String name,
    required String desc,
    required ValueChanged<String> onNameChanged,
    required ValueChanged<String> onDescChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Название', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: name)..addListener(() => onNameChanged(name)),
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
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
              Text('Описание', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: desc)..addListener(() => onDescChanged(desc)),
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 9. Блок достижений
class AchievementsSection extends StatelessWidget {
  final String achievement1;
  final String achievement1Desc;
  final String achievement2;
  final String achievement2Desc;
  final ValueChanged<String> onAchievement1Changed;
  final ValueChanged<String> onAchievement1DescChanged;
  final ValueChanged<String> onAchievement2Changed;
  final ValueChanged<String> onAchievement2DescChanged;

  const AchievementsSection({
    super.key,
    required this.achievement1,
    required this.achievement1Desc,
    required this.achievement2,
    required this.achievement2Desc,
    required this.onAchievement1Changed,
    required this.onAchievement1DescChanged,
    required this.onAchievement2Changed,
    required this.onAchievement2DescChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAchievementRow(
                name: achievement1,
                desc: achievement1Desc,
                onNameChanged: onAchievement1Changed,
                onDescChanged: onAchievement1DescChanged,
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.divider),
              const SizedBox(height: 16),
              _buildAchievementRow(
                name: achievement2,
                desc: achievement2Desc,
                onNameChanged: onAchievement2Changed,
                onDescChanged: onAchievement2DescChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRow({
    required String name,
    required String desc,
    required ValueChanged<String> onNameChanged,
    required ValueChanged<String> onDescChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Название', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: name)..addListener(() => onNameChanged(name)),
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
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
              Text('Описание', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: desc)..addListener(() => onDescChanged(desc)),
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 10. Кнопка "Создать персонажа"
class CreateCharacterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateCharacterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text('Создать персонажа'),
    );
  }
}
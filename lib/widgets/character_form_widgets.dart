import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// 1. Кнопка "Дополнить пустые поля"
class FillMissingButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FillMissingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.primaryButtonStyle,
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
        decoration: AppTheme.avatarDecoration(avatarUrl.isNotEmpty).copyWith(
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
                    style: AppTheme.hint.copyWith(fontSize: 12),
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
      decoration: AppTheme.cardDecoration,
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: AppTheme.body,
        decoration: AppTheme.inputDecoration(
          hintText: 'Опиши внешность персонажа...',
          isMultiline: true,
        ),
      ),
    );
  }
}

// 4. Выбор стиля
class StyleSelector extends StatelessWidget {
  final List<Map<String, String>> styles;
  final int selectedIndex;
  final bool isCustomMode;
  final Function(int) onStyleSelected;
  final Function(String) onStyleChipPressed;

  const StyleSelector({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.isCustomMode,
    required this.onStyleSelected,
    required this.onStyleChipPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(styles.length, (index) {
        final style = styles[index];
        final isSelected = !isCustomMode && selectedIndex == index;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(style['icon']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                style['name']!,
                style: TextStyle(
                  color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onStyleChipPressed(style['name']!),
          backgroundColor: AppTheme.surface,
          selectedColor: AppTheme.primary,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
            ),
          ),
        );
      }),
    );
  }
}

// 5. Кастомный стиль
class CustomStyleInput extends StatelessWidget {
  final TextEditingController controller;
  const CustomStyleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTheme.body,
      decoration: AppTheme.inputDecoration(
        hintText: 'Введите свой стиль (например: "стимпанк, грубый рисунок")',
      ),
    );
  }
}

// 6. Имя персонажа
class CharacterNameField extends StatelessWidget {
  final TextEditingController controller;
  const CharacterNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTheme.body,
      decoration: AppTheme.inputDecoration(hintText: 'Введите имя персонажа'),
    );
  }
}

// 7. Предыстория
class BackstoryField extends StatelessWidget {
  final TextEditingController controller;
  const BackstoryField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: AppTheme.body,
        decoration: AppTheme.inputDecoration(
          hintText: 'Напиши предысторию персонажа...',
          isMultiline: true,
        ),
      ),
    );
  }
}

// 8. Чекбокс "Сюжет на основе лора"
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
        const Expanded(
          child: Text(
            'Сюжет на основе лора персонажа',
            style: AppTheme.body,
          ),
        ),
      ],
    );
  }
}

// 9. Блок способностей
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
          decoration: AppTheme.cardDecoration,
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
              const Divider(color: AppTheme.divider),
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
          child: TextField(
            controller: TextEditingController(text: name)..addListener(() => onNameChanged(name)),
            style: AppTheme.body,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Название',
              labelStyle: AppTheme.hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: desc)..addListener(() => onDescChanged(desc)),
            style: AppTheme.body,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Описание',
              labelStyle: AppTheme.hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// 10. Блок достижений
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
          decoration: AppTheme.cardDecoration,
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
              const Divider(color: AppTheme.divider),
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
          child: TextField(
            controller: TextEditingController(text: name)..addListener(() => onNameChanged(name)),
            style: AppTheme.body,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Название',
              labelStyle: AppTheme.hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: desc)..addListener(() => onDescChanged(desc)),
            style: AppTheme.body,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Описание',
              labelStyle: AppTheme.hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// 11. Кнопка "Создать персонажа"
class CreateCharacterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateCharacterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.primaryButtonStyle,
      child: const Text('Создать персонажа'),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../widgets/design_colors.dart';

// ============================================================
// 1. ПУЗЫРЁК СООБЩЕНИЯ (Chat Bubble) С АВАТАРОМ
// ============================================================
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? avatarUrl;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(                    // ← ЗАМЕНА
                    text,
                    style: TextStyle(
                      color: isUser ? AppTheme.background : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isUser
                          ? AppTheme.background.withOpacity(0.7)
                          : AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.surface,
      backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
          ? NetworkImage(avatarUrl!)
          : null,
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: AppTheme.textSecondary,
            )
          : null,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================
// 2. ПОЛЕ ВВОДА СООБЩЕНИЯ (без прямоугольника)
// ============================================================
// ============================================================
// 2. ПОЛЕ ВВОДА СООБЩЕНИЯ (БЕЗ БОКСА, С ОТСТУПОМ)
// ============================================================
class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
    setState(() => _isComposing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // ← выравнивание по низу
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: AppTheme.textPrimary),
              maxLines: null,          // ← бесконечная высота
              minLines: 1,             // ← минимальная высота (одна строка)
              decoration: const InputDecoration(
                hintText: 'Что делаешь?',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (text) {
                setState(() => _isComposing = text.trim().isNotEmpty);
              },
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          // Кнопка отправки — всегда на одном уровне с последней строкой
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: AppTheme.background,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. ИНДИКАТОР ЗАГРУЗКИ (AI печатает)
// ============================================================
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'печатает...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
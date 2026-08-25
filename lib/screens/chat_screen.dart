import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/character_provider.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];

  final DatabaseService _db = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  /// Загружает последние сообщения этого чата из локальной БД.
  Future<void> _loadChatHistory() async {
    try {
      final history = await _db.getMessagesByChatId(widget.chatId);

      if (!mounted) return;

      setState(() {
        _messages.clear();

        for (final message in history) {
          _messages.add({
            'text': message['content'],
            'isUser': message['sender_id'] == 'hero',
            'timestamp': DateTime.parse(message['timestamp']),
            'senderName': message['sender_name'],
            'senderType': message['sender_type'],
            'avatarUrl': message['sender_avatar_url'],
          });
        }
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки истории: $e');
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final api = ApiService();

      final response = await api.sendMessage(
        chatId: widget.chatId,
        content: text,
      );

      if (!mounted) return;

      final answers = response['answers'];

      if (answers != null && answers.isNotEmpty) {
        for (final answer in answers) {
          setState(() {
            _messages.add({
              'text': answer['content'],
              'isUser': false,
              'timestamp': DateTime.parse(answer['timestamp']),
              'senderName': answer['sender_name'],
              'senderType': answer['sender_type'],
              'avatarUrl': answer['sender_avatar_url'],
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            'text': '🤔 Я не расслышал... Попробуй ещё раз.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('❌ Ошибка отправки сообщения: $e');

      setState(() {
        _messages.add({
          'text': '❌ Не удалось отправить сообщение.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCharacter =
        context.watch<CharacterProvider>().currentCharacter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RPG Tower'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Скоро здесь будут ключевые события'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.backpack),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Скоро здесь будет инвентарь'),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return const TypingIndicator();
                  }

                  final message = _messages[index];

                  return ChatBubble(
                    text: message['text'],
                    isUser: message['isUser'],
                    timestamp: message['timestamp'],
                    avatarUrl: message['isUser']
                        ? currentCharacter?.avatarUrl
                        : message['avatarUrl'],
                  );
                },
              ),
            ),
            MessageInput(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
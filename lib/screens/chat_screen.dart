import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/design_colors.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  
  const ChatScreen({
    super.key,
    required this.chatId,  // ← обязательно передавать
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  
    // Загружаем историю чата из локальной БД
    Future<void> _loadChatHistory() async {
      final history = await _db.getMessagesByChatId(widget.chatId);
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
    }
  }

  void _sendMessage(String text) async {
  // 1. Добавляем сообщение пользователя в UI
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
    // 2. Отправляем запрос на бекенд
    final api = ApiService();
    final response = await api.sendMessage(
      chatId: widget.chatId,  // ← ID чата (нужно передать в ChatScreen)
      content: text,
    );

    // 3. Обрабатываем ответ от LLM
    if (response['answers'] != null && response['answers'].isNotEmpty) {
      for (var answer in response['answers']) {
        setState(() {
          _messages.add({
            'text': answer['content'],
            'isUser': false,
            'timestamp': DateTime.parse(answer['timestamp']),
            'senderName': answer['sender_name'],
            'senderType': answer['sender_type'],
          });
        });
      }
    } else {
      // fallback, если ответ пустой
      setState(() {
        _messages.add({
          'text': '🤔 Я не расслышал... Попробуй ещё раз.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
    }
  } catch (e) {
    // 4. Обработка ошибки
    setState(() {
      _messages.add({
        'text': '❌ Ошибка: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  } finally {
    setState(() => _isLoading = false);
    _scrollToBottom();
  }
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
Widget build(BuildContext context) {
  final currentCharacter = context.watch<CharacterProvider>().currentCharacter;

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
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Скоро здесь будут ключевые события')),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.backpack),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Скоро здесь будет инвентарь')),
          ),
        ),
      ],
    ),
    body: GestureDetector(
      onTap: () {
        // Скрываем клавиатуру при тапе на пустое место
        FocusScope.of(context).unfocus();
      },
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
                final msg = _messages[index];
                return ChatBubble(
                  text: msg['text'],
                  isUser: msg['isUser'],
                  timestamp: msg['timestamp'],
                  avatarUrl: msg['isUser'] 
                      ? currentCharacter?.avatarUrl 
                      : null,
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
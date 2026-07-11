import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/design_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
    _messages.add({
      'text': 'Добро пожаловать в мир приключений! Что будешь делать?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': 'Ты сказал: "$text". Пока это заглушка. Скоро здесь будет ИИ-генерация сюжета!',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
        _scrollToBottom();
      });
    });

    _scrollToBottom();
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
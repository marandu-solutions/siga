import 'package:flutter/material.dart';

// O modelo de dados permanece o mesmo.
class Message {
  final String text;
  final bool isMe;
  final String time;
  Message({required this.text, required this.isMe, required this.time});
}

class ChatPage extends StatefulWidget {
  final String nome;
  final String numero;
  final String fotoUrl;

  const ChatPage({
    super.key,
    required this.nome,
    required this.numero,
    required this.fotoUrl,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    // Mensagens de exemplo para visualização
    Message(text: 'Olá! Gostaria de saber sobre o status do meu pedido.', isMe: false, time: '14:30'),
    Message(text: 'Claro! Só um momento enquanto verifico para você.', isMe: true, time: '14:31'),
  ];
  final ScrollController _scrollController = ScrollController();

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    final now = TimeOfDay.now();
    final formatted = now.format(context);
    setState(() {
      _messages.insert(0, Message(text: text, isMe: true, time: formatted));
    });
    _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chatBackgroundColor = theme.brightness == Brightness.light
        ? const Color(0xFFEFE7DE)
        : const Color(0xFF111B21);

    return Scaffold(
      backgroundColor: chatBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 1,
        leading: BackButton(color: cs.onPrimary),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.fotoUrl),
              radius: 20,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.nome, style: theme.textTheme.labelLarge?.copyWith(color: cs.onPrimary)),
                Text('online', style: theme.textTheme.bodySmall?.copyWith(color: cs.onPrimary.withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return ChatBubble(text: msg.text, isMe: msg.isMe, time: msg.time);
              },
            ),
          ),
          ChatInputBar(onSend: _handleSend),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const ChatBubble({super.key, required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3))
        : (isDark ? const Color(0xFF202C33) : cs.surface);
    final textColor = isMe
        ? (isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF111B21))
        : (isDark ? Colors.white.withOpacity(0.9) : cs.onSurface);

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ]
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          children: [
            Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.4)),
            Text(time, style: theme.textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class ChatInputBar extends StatefulWidget {
  final void Function(String) onSend;
  const ChatInputBar({super.key, required this.onSend});

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Estilo que será aplicado ao TextField
    final inputDecoration = InputDecoration(
      hintText: 'Mensagem',
      filled: true,
      fillColor: cs.surface, // Cor de fundo que se adapta ao tema
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      prefixIcon: Icon(Icons.sentiment_satisfied_alt_outlined, color: cs.onSurfaceVariant),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.of(context).padding.bottom),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: cs.onSurface), // Cor do texto digitado
              decoration: inputDecoration,
              maxLines: 5,
              minLines: 1,
              onSubmitted: _send,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: cs.primary,
            radius: 24,
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: cs.onPrimary),
              onPressed: _hasText ? () => _send(_controller.text.trim()) : null,
              disabledColor: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _send(String text) {
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }
}

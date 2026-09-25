import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/messaging_api.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const purple = Color(0xFF896AFB);

  final messageController = TextEditingController();

  final scrollController = ScrollController();

  List<ChatMessage> messages = [];

  bool loading = true;
  bool sending = false;

  String? error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final result = await MessagingApi.getMessages(
        conversationId: widget.conversation.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        messages = result;
        loading = false;
        error = null;
      });

      try {
        await MessagingApi.markRead(conversationId: widget.conversation.id);
      } catch (_) {}

      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _send() async {
    final text = messageController.text.trim();

    if (text.isEmpty || sending) {
      return;
    }

    setState(() {
      sending = true;
    });

    try {
      final message = await MessagingApi.sendMessage(
        conversationId: widget.conversation.id,
        message: text,
      );

      if (!mounted) {
        return;
      }

      messageController.clear();

      setState(() {
        messages.add(message);
        sending = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        sending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.host.fullName,
              style: GoogleFonts.urbanist(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.conversation.property.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: purple));
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            'Send a message to ${widget.conversation.host.firstName}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: purple,
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          final mine = message.senderId == widget.conversation.guest.id;

          return _MessageBubble(message: message, mine: mine);
        },
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                minLines: 1,
                maxLines: 5,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Message host...',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: purple),
              onPressed: sending ? null : _send,
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;

  const _MessageBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: mine ? const Color(0xFF896AFB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: mine ? null : Border.all(color: const Color(0xFFE8E8EB)),
        ),
        child: Text(
          message.message,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.35,
            color: mine ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

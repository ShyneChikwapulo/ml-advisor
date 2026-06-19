import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.uid ?? "anonymous_session";

    context.read<ChatProvider>().sendMessage(text, userId).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI ADVISOR',
                        style: TextStyle(
                          color: goldAccent.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white60, size: 24),
                    onPressed: () => context.read<ChatProvider>().clearChat(),
                  ),
                ],
              ),
            ),

            // ── INFO BANNER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hub_outlined, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Powered by 26+ research papers',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── MESSAGES ──
            Expanded(
              child: chat.messages.isEmpty
                  ? const _EmptyChat()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: chat.messages.length + (chat.loading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == chat.messages.length) {
                          return const _TypingIndicator();
                        }
                        final msg = chat.messages[i];
                        return _MessageBubble(message: msg);
                      },
                    ),
            ),
            
            // ── INPUT ──
            Container(
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
              ),
              color: Colors.transparent, 
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                        cursorColor: AppTheme.primary,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Ask about ML models...',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13),
                          filled: false, 
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: chat.loading ? null : _send,
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                        ),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY STATE ──
class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Icon(Icons.chat_outlined, size: 48, color: AppTheme.accent),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ask the AI Advisor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask questions about ML models for bug prediction. Responses are grounded in 26 research papers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                'Which model has the highest accuracy?',
                'When should I use Random Forest?',
                'What is class imbalance?',
                'Compare LSTM vs XGBoost',
              ].map((q) => ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Material(
                  color: Colors.white.withOpacity(0.03),
                  child: InkWell(
                    onTap: () {
                      final auth = context.read<AuthProvider>();
                      final userId = auth.user?.uid ?? "anonymous_session";
                      context.read<ChatProvider>().sendMessage(q, userId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Text(
                        q,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MESSAGE BUBBLE ──
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser 
              ? AppTheme.primary.withOpacity(0.15) 
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser 
                ? AppTheme.accent.withOpacity(0.3) 
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: isUser 
            ? Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  em: TextStyle(color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic),
                  listBullet: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  code: TextStyle(
                    color: Colors.amberAccent, 
                    backgroundColor: Colors.black.withOpacity(0.3),
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    );
  }
}

// ── TYPING INDICATOR ──
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thinking...',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
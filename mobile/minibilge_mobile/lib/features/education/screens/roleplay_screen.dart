import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/roleplay_models.dart';
import '../services/roleplay_service.dart';
import '../../../core/network/dio_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class RolePlayScreen extends ConsumerStatefulWidget {
  final ScenarioDto scenario;
  final String level;
  final String childProfileId;

  const RolePlayScreen({
    super.key,
    required this.scenario,
    required this.level,
    required this.childProfileId,
  });

  @override
  ConsumerState<RolePlayScreen> createState() => _RolePlayScreenState();
}

class _RolePlayScreenState extends ConsumerState<RolePlayScreen> {
  static const _bgColor    = Color(0xFF0D1B2A);
  static const _cardColor  = Color(0xFF1A2A3A);
  static const _accentColor = Color(0xFF7C4DFF);
  static const _userBubbleColor = Color(0xFF1A5276);
  static const _aiBubbleColor   = Color(0xFF1A2A3A);

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isLoading = true;          // ilk yükleme
  bool _isSending = false;         // tur gönderiliyor
  bool _isEnding = false;          // oturum bitiriliyor
  bool _maxTurnsReached = false;
  bool _ttsEnabled = true;

  String? _sessionId;
  final List<ChatMessage> _messages = [];

  late final RolePlayService _service;

  @override
  void initState() {
    super.initState();
    _service = RolePlayService(ref.read(dioProvider));
    _initSpeech();
    _initTts();
    _startSession();
  }

  @override
  void dispose() {
    _tts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() { if (mounted) setState(() {}); });
  }

  Future<void> _speak(String text) async {
    if (!_ttsEnabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (s) { if ((s == 'done' || s == 'notListening') && mounted) setState(() => _isListening = false); },
      onError:  (_) { if (mounted) setState(() => _isListening = false); },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _startSession() async {
    try {
      final response = await _service.startSession(
        childProfileId: widget.childProfileId,
        scenarioKey: widget.scenario.key,
        level: widget.level,
      );
      if (!mounted) return;
      setState(() {
        _sessionId = response.sessionId;
        _messages.add(ChatMessage(
          role: 'assistant',
          content: response.assistantMessage,
          createdAt: DateTime.now(),
        ));
        _isLoading = false;
      });
      _speak(response.assistantMessage);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sessionId == null || _isSending) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text, createdAt: DateTime.now()));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _service.sendTurn(sessionId: _sessionId!, userMessage: text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: response.assistantMessage,
          grammarNote: response.grammarNote,
          createdAt: DateTime.now(),
        ));
        _isSending = false;
        _maxTurnsReached = response.maxTurnsReached;
      });
      _scrollToBottom();
      _speak(response.assistantMessage);

      if (response.maxTurnsReached) _endSession();
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj gönderilemedi, tekrar dene.')),
        );
      }
    }
  }

  Future<void> _endSession() async {
    if (_sessionId == null || _isEnding) return;
    setState(() => _isEnding = true);

    try {
      final result = await _service.endSession(
        sessionId: _sessionId!,
        childProfileId: widget.childProfileId.isNotEmpty ? widget.childProfileId : null,
      );
      if (!mounted) return;
      context.pushReplacementNamed('roleplay-result', extra: {
        'result': result,
        'scenario': widget.scenario,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isEnding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oturum tamamlanamadı, tekrar dene.')),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    await _tts.stop(); // TTS konuşurken mikrofon açılmasın
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (mounted) _textController.text = result.recognizedWords;
      },
      localeId: 'en_US',
    );
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
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: _cardColor,
                title: Text('Çıkmak istiyor musun?',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
                content: Text('Konuşmandan çıkman sonuçları kaybedeceğin anlamına gelir.',
                    style: GoogleFonts.nunito(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal', style: GoogleFonts.nunito(color: Colors.white60)),
                  ),
                  TextButton(
                    onPressed: () { Navigator.pop(context); context.pop(); },
                    child: Text('Çık', style: GoogleFonts.nunito(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.scenario.title,
              style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            Text(
              '${widget.scenario.emoji} ${widget.scenario.characterName} • ${widget.scenario.characterRole}',
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // TTS aç/kapat
          IconButton(
            icon: Icon(
              _ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _ttsEnabled ? Colors.white70 : Colors.white30,
            ),
            onPressed: () async {
              if (_ttsEnabled) await _tts.stop();
              setState(() => _ttsEnabled = !_ttsEnabled);
            },
          ),
          // Konuşmayı Bitir butonu
          TextButton(
            onPressed: _isEnding ? null : () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: _cardColor,
                  title: Text('Konuşmayı bitir?',
                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
                  content: Text('Değerlendirme ve ödüllerini almak için oturumu tamamla.',
                      style: GoogleFonts.nunito(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Devam Et', style: GoogleFonts.nunito(color: Colors.white60)),
                    ),
                    TextButton(
                      onPressed: () { Navigator.pop(context); _endSession(); },
                      child: Text('Bitir', style: GoogleFonts.nunito(color: _accentColor, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              _isEnding ? '...' : 'Bitir',
              style: GoogleFonts.nunito(color: _accentColor, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accentColor))
          : Column(
              children: [
                // Mesaj listesi
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) return _TypingIndicator();
                      return _MessageBubble(message: _messages[i]);
                    },
                  ),
                ),
                // Input alanı
                _InputArea(
                  controller: _textController,
                  speechAvailable: _speechAvailable,
                  isListening: _isListening,
                  isSending: _isSending,
                  onSend: _sendMessage,
                  onMic: _toggleListening,
                ),
              ],
            ),
    );
  }
}

// ─── Mesaj Balonu ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showGrammar = false;

  static const _userBubbleColor = Color(0xFF1A5276);
  static const _aiBubbleColor   = Color(0xFF1A2A3A);
  static const _grammarColor    = Color(0xFFFFF9C4);

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    return Padding(
      padding: EdgeInsets.only(
        top: 6, bottom: 6,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? _userBubbleColor : _aiBubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              widget.message.content,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, height: 1.5),
            ),
          ),
          // Gramer notu (sadece AI mesajları için)
          if (!isUser && widget.message.grammarNote != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _showGrammar = !_showGrammar),
              child: Row(
                children: [
                  Icon(
                    _showGrammar ? Icons.keyboard_arrow_up : Icons.lightbulb_outline,
                    color: Colors.amber.shade300,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showGrammar ? 'Grameri gizle' : 'Gramer notu',
                    style: GoogleFonts.nunito(color: Colors.amber.shade300, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_showGrammar)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
                ),
                child: Text(
                  widget.message.grammarNote!,
                  style: GoogleFonts.nunito(color: Colors.amber.shade100, fontSize: 12, height: 1.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Yazıyor göstergesi ───────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2A3A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
  );
}

// ─── Input Alanı ──────────────────────────────────────────────────────────────

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool speechAvailable;
  final bool isListening;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _InputArea({
    required this.controller,
    required this.speechAvailable,
    required this.isListening,
    required this.isSending,
    required this.onSend,
    required this.onMic,
  });

  static const _bgColor   = Color(0xFF0D1B2A);
  static const _cardColor = Color(0xFF1A2A3A);
  static const _accentColor = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          // Mikrofon
          if (speechAvailable) ...[
            GestureDetector(
              onTap: onMic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isListening ? Colors.red.shade700 : _cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: isListening ? Colors.red : Colors.white24, width: 1.5),
                ),
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: isListening ? Colors.white : Colors.white70,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 3,
              minLines: 1,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Yanıtını yaz...',
                hintStyle: GoogleFonts.nunito(color: Colors.white38),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          // Gönder
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSending ? Colors.white12 : _accentColor,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

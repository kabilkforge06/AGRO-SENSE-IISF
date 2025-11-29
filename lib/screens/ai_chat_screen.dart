import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../widgets/voice_input_widget.dart';
import 'ai_chat_debug_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  bool _showVoiceInput = false;
  String _currentLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Add welcome message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your AI farming assistant. Ask me anything about farming, crops, diseases, weather, or agricultural practices. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    // Test API connection in background
    _testApiConnection();
  }

  Future<void> _testApiConnection() async {
    try {
      if (_geminiService.isApiKeyConfigured()) {
        final isConnected = await _geminiService.testConnection();
        if (!isConnected) {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text:
                      "⚠️ Note: AI service connection test failed. Responses will be in demo mode. Please check your internet connection or contact support if you need full AI assistance.",
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text:
                      "✅ AI service is ready! You can ask me anything about farming.",
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                text:
                    "⚙️ AI service is running in demo mode. Responses will be simulated examples. For full AI capabilities, please configure the API key.",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
        }
      }
    } catch (e) {
      // Silent fail - don't interrupt user experience
      debugPrint('API connection test error: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      debugPrint(
        '📤 Sending message to Gemini: ${message.substring(0, message.length > 50 ? 50 : message.length)}...',
      );
      final response = await _geminiService.sendMessage(message);
      debugPrint('📥 Received response from Gemini');

      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('💥 Error in _sendMessage: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "I apologize, but I'm experiencing technical difficulties. Please try again in a moment, or check your internet connection. Error details have been logged for debugging.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _handleVoiceResult(String text) {
    // Treat all voice input as chat messages
    _messageController.text = text;
    _sendMessage();
  }

  void _toggleVoiceInput() {
    setState(() {
      _showVoiceInput = !_showVoiceInput;
    });
  }

  void _changeLanguage(String language) async {
    setState(() {
      _currentLanguage = language;
    });
    // Update language in GeminiService
    await _geminiService.setLanguage(language);
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
      appBar: AppBar(
        title: const Text('AI Farming Assistant'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Voice input toggle
          IconButton(
            icon: Icon(
              _showVoiceInput ? Icons.keyboard : Icons.mic,
              color: _showVoiceInput ? Colors.red : Colors.white,
            ),
            onPressed: _toggleVoiceInput,
            tooltip: _showVoiceInput ? 'Hide Voice Input' : 'Show Voice Input',
          ),
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    text:
                        "Hello! I'm your AI farming assistant. Ask me anything about farming, crops, diseases, weather, or agricultural practices. How can I help you today?",
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
            tooltip: 'Clear Chat',
          ),
          // Debug button (only shown in debug mode)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIChatDebugScreen(),
                  ),
                );
              },
              tooltip: 'Debug AI Chat',
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Voice Input Area
          if (_showVoiceInput)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: VoiceInputWidget(
                onVoiceResult: _handleVoiceResult,
                currentLanguage: _currentLanguage,
                onLanguageChanged: _changeLanguage,
                enabled: !_isLoading,
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _showVoiceInput
                          ? 'Type or use voice input above...'
                          : 'Ask about farming, crops, diseases...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  mini: true,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 16,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AI is thinking...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AIChatDebugScreen extends StatefulWidget {
  const AIChatDebugScreen({super.key});

  @override
  State<AIChatDebugScreen> createState() => _AIChatDebugScreenState();
}

class _AIChatDebugScreenState extends State<AIChatDebugScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  String _debugInfo = 'Initializing debug screen...';
  String _lastResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDebugTests();
  }

  Future<void> _runDebugTests() async {
    setState(() {
      _debugInfo = 'Running debug tests...\n';
    });

    // Test 1: API Key Configuration
    final apiKeyConfigured = _geminiService.isApiKeyConfigured();
    setState(() {
      _debugInfo += '✅ API Key Configured: $apiKeyConfigured\n';
    });

    // Test 1.5: Current Model Information
    final currentModel = _geminiService.getCurrentModel();
    setState(() {
      _debugInfo += '🤖 Current Model: $currentModel\n';
    });

    // Test 1.6: Available Models (if API key is configured)
    if (apiKeyConfigured) {
      setState(() {
        _debugInfo += '🔄 Fetching available models...\n';
      });

      final availableModels = await _geminiService.getAvailableModels();
      setState(() {
        _debugInfo += '📋 Available Models: ${availableModels.length}\n';
        if (availableModels.isNotEmpty) {
          _debugInfo += '   Flash Models:\n';
          for (final model in availableModels) {
            if (model['name']?.toLowerCase().contains('flash') == true) {
              _debugInfo += '   • ${model['name']} - ${model['displayName']}\n';
            }
          }
        }
      });
    }

    // Test 2: Speech Service Initialization
    final speechInitialized = await _geminiService.initializeSpeech();
    setState(() {
      _debugInfo += '✅ Speech Service Initialized: $speechInitialized\n';
    });

    // Test 3: API Connection Test
    setState(() {
      _debugInfo += '🔄 Testing API connection...\n';
    });

    final connectionWorking = await _geminiService.testConnection();
    setState(() {
      _debugInfo += '✅ API Connection Test: $connectionWorking\n';
    });

    // Test 4: Sample message
    setState(() {
      _debugInfo += '🔄 Sending test message...\n';
    });

    try {
      final testResponse = await _geminiService.sendMessage(
        'Hello, can you help me with farming?',
      );
      setState(() {
        _debugInfo += '✅ Test Message Response Received\n';
        _debugInfo += 'Response Length: ${testResponse.length} characters\n';
        _debugInfo +=
            'Response Preview: ${testResponse.substring(0, testResponse.length > 100 ? 100 : testResponse.length)}...\n\n';
        _lastResponse = testResponse;
      });
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Test Message Failed: $e\n\n';
      });
    }

    setState(() {
      _debugInfo += 'Debug tests completed.\n';
    });
  }

  Future<void> _sendTestMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _debugInfo += '\n📤 Sending: "$message"\n';
    });

    try {
      final response = await _geminiService.sendMessage(message);
      setState(() {
        _debugInfo += '📥 Response: $response\n\n';
        _lastResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Error: $e\n\n';
        _isLoading = false;
      });
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Debug'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDebugTests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Debug Info
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last Response
            if (_lastResponse.isNotEmpty)
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last AI Response:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_lastResponse),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Test Message Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter test message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendTestMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendTestMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

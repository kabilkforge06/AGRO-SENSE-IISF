import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/gemini_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceResult;
  final String? currentLanguage;
  final Function(String)? onLanguageChanged;
  final bool enabled;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceResult,
    this.currentLanguage,
    this.onLanguageChanged,
    this.enabled = true,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _hasPermission = false;
  String _lastWords = '';
  String _statusText = 'Ready to listen';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final GeminiService _geminiService = GeminiService();

  // Get supported languages from GeminiService
  Map<String, String> get supportedLanguages =>
      GeminiService.supportedLanguages;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkPermission();
    _initializeSpeechService();
  }

  Future<void> _initializeSpeechService() async {
    await _geminiService.initializeSpeech();
    if (widget.currentLanguage != null) {
      await _geminiService.setLanguage(widget.currentLanguage!);
    }
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });

    if (!_hasPermission) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission'),
          content: const Text(
            'This app needs microphone permission to use voice input. '
            'Please enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _startListening() async {
    if (!widget.enabled || _isListening) return;

    if (!_hasPermission) {
      await _requestPermission();
      return;
    }

    setState(() {
      _isListening = true;
      _statusText = 'Starting...';
      _lastWords = '';
    });

    _animationController.repeat(reverse: true);

    // Use GeminiService for speech recognition
    await _geminiService.startListening(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _lastWords = result;
            _statusText = 'Speech recognized';
            _isListening = false;
          });
          _animationController.stop();
          _animationController.reset();

          if (_lastWords.isNotEmpty) {
            widget.onVoiceResult(_lastWords);
          }
        }
      },
      onPartialResult: (partial) {
        if (mounted) {
          setState(() {
            _lastWords = partial;
            _statusText =
                'Listening... "${partial.length > 30 ? '${partial.substring(0, 30)}...' : partial}"';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusText = 'Error occurred';
          });
          _animationController.stop();
          _animationController.reset();
        }
      },
    );

    // Update status after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && _isListening) {
      setState(() {
        _statusText = 'Listening...';
      });
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _geminiService.stopListening();
      setState(() {
        _isListening = false;
        _statusText = _lastWords.isEmpty
            ? 'No speech detected'
            : 'Processing...';
      });

      _animationController.stop();
      _animationController.reset();
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Select Voice Language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: supportedLanguages.entries
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.value),
                          subtitle: Text(entry.key),
                          selected: widget.currentLanguage == entry.key,
                          onTap: () async {
                            await _geminiService.setLanguage(entry.key);
                            widget.onLanguageChanged?.call(entry.key);
                            Navigator.pop(context);
                          },
                          trailing: widget.currentLanguage == entry.key
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice input status
        if (_isListening || _lastWords.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.check_circle,
                  size: 16,
                  color: _isListening ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _statusText,
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

        // Voice input controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language selector
            if (widget.onLanguageChanged != null)
              IconButton(
                onPressed: _showLanguageSelector,
                icon: Icon(Icons.language, color: Colors.grey.shade600),
                tooltip: 'Select Language',
              ),

            // Voice input button
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _scaleAnimation.value : 1.0,
                  child: GestureDetector(
                    onTapDown: (_) => _startListening(),
                    onTapUp: (_) => _stopListening(),
                    onTapCancel: () => _stopListening(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? Colors.red : Colors.green,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Hold to speak instruction
            if (!_isListening) const SizedBox(width: 8),
            if (!_isListening)
              Text(
                'Hold to speak',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _geminiService.dispose();
    super.dispose();
  }
}

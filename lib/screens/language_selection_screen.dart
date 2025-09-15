import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Select Language'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Language selection instruction
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.language, size: 48, color: Colors.blue.shade600),
                  const SizedBox(height: 12),
                  Text(
                    'Choose Your Language',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your preferred language for the app interface',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Language options
            Expanded(
              child: ListView.builder(
                itemCount: AppStateService.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final language = AppStateService.supportedLanguages.keys
                      .elementAt(index);
                  final languageCode =
                      AppStateService.supportedLanguages[language]!;

                  return Consumer<AppStateService>(
                    builder: (context, appState, child) {
                      final isSelected = appState.selectedLanguage == language;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.green.shade600
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.translate,
                              color: isSelected
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                          title: Text(
                            language,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.green.shade800
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Language Code: $languageCode',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.green.shade600
                                  : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                  size: 24,
                                )
                              : const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                          onTap: () async {
                            await appState.setLanguage(language);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Continue button
            Consumer<AppStateService>(
              builder: (context, appState, child) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigation will be handled automatically by main.dart Consumer
                          // No need to manually navigate here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getContinueText(appState.selectedLanguage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Navigation will be handled automatically by main.dart Consumer
                        // No need to manually navigate here
                      },
                      child: Text(
                        _getSkipText(appState.selectedLanguage),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getContinueText(String language) {
    switch (language) {
      case 'Hindi':
        return 'जारी रखें';
      case 'Tamil':
        return 'தொடரவும்';
      case 'Telugu':
        return 'కొనసాగించు';
      default:
        return 'Continue';
    }
  }

  String _getSkipText(String language) {
    switch (language) {
      case 'Hindi':
        return 'छोड़ें और इंग्लिश में जारी रखें';
      case 'Tamil':
        return 'தவிர்த்து ஆங்கிலத்தில் தொடரவும்';
      case 'Telugu':
        return 'దాటవేసి ఆంగ్లంలో కొనసాగించండి';
      default:
        return 'Skip and continue in English';
    }
  }
}

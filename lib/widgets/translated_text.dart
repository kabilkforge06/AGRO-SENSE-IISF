import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state_service.dart';

/// Widget that displays translated text based on current locale
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateService>(context);
    return Text(
      appState.translate(translationKey),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Extension to easily get translations in any widget
extension BuildContextTranslation on BuildContext {
  String tr(String key) {
    final appState = Provider.of<AppStateService>(this, listen: false);
    return appState.translate(key);
  }
}

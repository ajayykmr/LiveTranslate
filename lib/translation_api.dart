import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationApi {
  static Future<String?> translateText(String inputText) async {
    try {
      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final languageCode = await languageIdentifier.identifyLanguage(inputText);
      languageIdentifier.close();

      final translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.values
              .firstWhere((element) => element.bcpCode == languageCode),
          targetLanguage: TranslateLanguage.english);

      final translatedText = await translator.translateText(inputText);
      translator.close();
      return translatedText;
    } catch (e) {
      return null;
    }
  }
}

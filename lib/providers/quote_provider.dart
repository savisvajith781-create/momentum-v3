import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_model.dart';
import 'core_providers.dart';

class QuoteNotifier extends StateNotifier<QuoteModel> {
  QuoteNotifier(super.initialState);

  void next(QuoteModel Function() getNext) {
    state = getNext();
  }

  void setQuote(QuoteModel quote) {
    state = quote;
  }
}

final quoteProvider = StateNotifierProvider<QuoteNotifier, QuoteModel>((ref) {
  final service = ref.read(quoteServiceProvider);
  return QuoteNotifier(service.currentQuote);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_automat/storage/data_repository.dart';
import 'package:snack_automat/storage/snack_service.dart';
import 'package:snack_automat/storage/supabase.dart';

const bool kUseSupabase = bool.fromEnvironment(
  'USE_SUPABASE',
  defaultValue: false,
);

final dataRepositoryProvider = Provider<DataRepository>((ref) {
  if (kUseSupabase) {
    return SupabaseDataRepository();
  }
  return MockDataRepository();
});

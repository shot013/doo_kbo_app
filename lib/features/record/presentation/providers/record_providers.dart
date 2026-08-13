import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/record_remote_data_source.dart';
import '../../data/repositories/record_repository_impl.dart';
import '../../domain/entities/batter_record.dart';
import '../../domain/entities/pitcher_record.dart';
import '../../domain/entities/record_category.dart';
import '../../domain/repositories/record_repository.dart';
import '../../domain/usecases/get_batter_records.dart';
import '../../domain/usecases/get_pitcher_records.dart';

final recordRemoteDataSourceProvider = Provider<RecordRemoteDataSource>((ref) {
  return RecordRemoteDataSourceImpl(ref.watch(dioProvider));
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepositoryImpl(
    ref.watch(recordRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getBatterRecordsProvider = Provider<GetBatterRecords>((ref) {
  return GetBatterRecords(ref.watch(recordRepositoryProvider));
});

final getPitcherRecordsProvider = Provider<GetPitcherRecords>((ref) {
  return GetPitcherRecords(ref.watch(recordRepositoryProvider));
});

final batterRecordListProvider =
    AsyncNotifierProvider<BatterRecordListNotifier, List<BatterRecord>>(
      BatterRecordListNotifier.new,
    );

class BatterRecordListNotifier extends AsyncNotifier<List<BatterRecord>> {
  @override
  Future<List<BatterRecord>> build() async {
    final result = await ref
        .read(getBatterRecordsProvider)
        .call(const GetBatterRecordsParams());
    return switch (result) {
      Ok<List<BatterRecord>>(:final value) => value,
      Err<List<BatterRecord>>(:final failure) => throw failure,
    };
  }
}

final pitcherRecordListProvider =
    AsyncNotifierProvider<PitcherRecordListNotifier, List<PitcherRecord>>(
      PitcherRecordListNotifier.new,
    );

class PitcherRecordListNotifier extends AsyncNotifier<List<PitcherRecord>> {
  @override
  Future<List<PitcherRecord>> build() async {
    final result = await ref
        .read(getPitcherRecordsProvider)
        .call(const GetPitcherRecordsParams());
    return switch (result) {
      Ok<List<PitcherRecord>>(:final value) => value,
      Err<List<PitcherRecord>>(:final failure) => throw failure,
    };
  }
}

final recordCategoryProvider =
    NotifierProvider<RecordCategoryNotifier, RecordCategory>(
      RecordCategoryNotifier.new,
    );

class RecordCategoryNotifier extends Notifier<RecordCategory> {
  @override
  RecordCategory build() => RecordCategory.batting;

  void select(RecordCategory category) {
    state = category;
  }
}

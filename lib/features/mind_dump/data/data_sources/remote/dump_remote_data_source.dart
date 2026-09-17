import '../../models/dump_entry_model.dart';

abstract class DumpRemoteDataSource {
  Stream<List<DumpEntryModel>> watchEntries();

  Future<void> addEntry(DumpEntryModel entry);

  Future<void> deleteEntries(List<String> ids);

  Future<void> reorderEntries(List<String> orderedIds);
}

import 'package:on_chain_bridge/database/database.dart';

class APPDatabaseConst {
  static const String mainTableName = "onchain";
  static const int defaultStorageId = 0;

  static const int appSettingStorage = 1;

  static const int serviceProvideresStorageId = 100;

  static const ITableReadStructA appSettingQuery = ITableReadStructA(
      tableName: mainTableName,
      storage: appSettingStorage,
      storageId: defaultStorageId);
}

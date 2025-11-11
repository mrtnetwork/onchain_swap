import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_bridge/database/database.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:onchain_swap_example/api/services/types/types.dart';
import 'package:onchain_swap_example/app/constants/storage_key.dart';
import 'package:onchain_swap_example/app/native_impl/core/core.dart';
import 'package:onchain_swap_example/app/serialization/cbor/cbor.dart';
import 'package:onchain_swap_example/app/utils/platform/utils.dart';

mixin NetworkRepository {
  CosmosSdkChainChains? _cosmosChains;
  String get tableId => APPDatabaseConst.mainTableName;

  Future<bool> insertStorage(
      {required int storage,
      int storageId = APPDatabaseConst.defaultStorageId,
      String? key,
      String? keyA,
      required CborSerializable value,
      DateTime? createdAt}) async {
    final statement = ITableInsertOrUpdateStructA(
        storage: storage,
        storageId: storageId,
        key: key,
        keyA: keyA,
        data: value.toCbor().encode(),
        tableName: tableId,
        createdAt: createdAt);
    return await AppNativeMethods.platform.writeDb(statement);
  }

  Future<bool> insertStorages(
      List<ITableInsertOrUpdateStructA> storages) async {
    return await AppNativeMethods.platform.writeAllDb(storages);
  }

  Future<ITableDataStructA?> queryStorage({
    required int storage,
    int storageId = APPDatabaseConst.defaultStorageId,
    String? key,
    String? keyA,
  }) async {
    ITableReadStructA query = ITableReadStructA(
        tableName: tableId,
        storage: storage,
        storageId: storageId,
        key: key,
        keyA: keyA);
    final data = await AppNativeMethods.platform.readDb(query);
    return data;
  }

  Future<List<int>?> queryStorageData({
    required int storage,
    int storageId = APPDatabaseConst.defaultStorageId,
    String? key,
    String? keyA,
  }) async {
    final data = await queryStorage(
        key: key, keyA: keyA, storage: storage, storageId: storageId);
    return data?.data;
  }

  Future<List<ITableDataStructA>> queriesStorage({
    required int storage,
    int? storageId = APPDatabaseConst.defaultStorageId,
    String? key,
    String? keyA,
    int? limit,
    int? offset,
    int? createdAtLt,
    int? createdAtGt,
    IDatabaseQueryOrdering ordering = IDatabaseQueryOrdering.desc,
  }) async {
    ITableReadStructA query = ITableReadStructA(
        tableName: tableId,
        storage: storage,
        storageId: storageId,
        key: key,
        keyA: keyA,
        limit: limit,
        offset: offset,
        createdAtGt: createdAtLt,
        createdAtLt: createdAtGt,
        ordering: ordering);
    final data = await AppNativeMethods.platform.readAllDb(query);
    return data;
  }

  Future<List<List<int>>> queriesStorageData({
    required int storage,
    int? storageId = APPDatabaseConst.defaultStorageId,
    String? key,
    String? keyA,
    int? limit,
    int? offset,
    int? createdAtLt,
    int? createdAtGt,
    IDatabaseQueryOrdering ordering = IDatabaseQueryOrdering.desc,
  }) async {
    final data = await queriesStorage(
        createdAtGt: createdAtGt,
        createdAtLt: createdAtLt,
        key: key,
        keyA: keyA,
        limit: limit,
        offset: offset,
        ordering: ordering,
        storage: storage,
        storageId: storageId);
    return data.map((e) => e.data).toList();
  }

  Future<bool> removeStorage(
      {required int storage,
      int? storageId = APPDatabaseConst.defaultStorageId,
      String? key,
      String? keyA}) async {
    final statement = ITableRemoveStructA(
        storage: storage,
        storageId: storageId,
        key: key,
        keyA: keyA,
        tableName: tableId);
    return await AppNativeMethods.platform.removeDb(statement);
  }

  Future<bool> removeStorages(
      {required List<ITableRemoveStructA> statements}) async {
    return await AppNativeMethods.platform.removeAllDb(statements);
  }

  Future<void> removeAllStorage(List<ITableRemoveStructA> items) async {
    await AppNativeMethods.platform.removeAllDb(items);
  }

  Future<void> insertAllStorage(List<ITableInsertOrUpdateStructA> items) async {
    await AppNativeMethods.platform.writeAllDb(items);
  }

  Future<void> saveAppSetting(CborSerializable value) async {
    await insertStorage(
        storage: APPDatabaseConst.appSettingStorage,
        storageId: APPDatabaseConst.defaultStorageId,
        value: value);
  }

  Future<ServiceInfo?> loadServiceProvider(SwapNetwork network) async {
    final data = await queryStorageData(
      key: network.identifier,
      storage: APPDatabaseConst.appSettingStorage,
      storageId: APPDatabaseConst.serviceProvideresStorageId,
    );
    if (data == null) return null;
    return ServiceInfo.deserialize(bytes: data);
  }

  Future<void> saveServiceProvider(
      {required SwapNetwork network, required ServiceInfo service}) async {
    await insertStorage(
        key: network.identifier,
        storage: APPDatabaseConst.appSettingStorage,
        storageId: APPDatabaseConst.serviceProvideresStorageId,
        value: service);
  }

  Future<CosmosSdkChainChains> loadCosmosChains() async {
    Future<CosmosSdkChainChains> loadChains() async {
      try {
        final json = await PlatformUtils.loadJson<Map<String, dynamic>>(
            "assets/chains.json",
            package: "cosmos_sdk");
        return CosmosSdkChainChains.fromJson(json);
      } catch (_) {
        return CosmosSdkChainChains(mainnet: [], testnet: []);
      }
    }

    return _cosmosChains ??= await loadChains();
  }
}

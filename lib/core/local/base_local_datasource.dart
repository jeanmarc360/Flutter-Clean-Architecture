import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract class BaseLocalDatasource<E> {
  static const _defaultKey = 'default';
  static const _encryptionKeyName = 'hive_aes_key';

  String get keyBox;
  bool get isSecure;

  Future<Box<E>> openBox() => isSecure ? _openSecureBox() : _openPlainBox();

  Future<void> save(E? model) async {
    final box = await openBox();
    if (model == null) {
      await box.delete(_defaultKey);
    } else {
      await box.put(_defaultKey, model);
    }
  }

  Future<E?> get() async {
    final box = await openBox();
    return box.get(_defaultKey);
  }

  Future<void> deleteBox() => Hive.deleteBoxFromDisk(keyBox);

  Future<Box<E>> _openSecureBox() async {
    try {
      final key = await _getOrCreateEncryptionKey();
      return await Hive.openBox<E>(keyBox, encryptionCipher: HiveAesCipher(key));
    } catch (_) {
      await Hive.deleteBoxFromDisk(keyBox);
      final key = await _getOrCreateEncryptionKey();
      return await Hive.openBox<E>(keyBox, encryptionCipher: HiveAesCipher(key));
    }
  }

  Future<Box<E>> _openPlainBox() async {
    try {
      return await Hive.openBox<E>(keyBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(keyBox);
      return await Hive.openBox<E>(keyBox);
    }
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    const storage = FlutterSecureStorage();
    var keyStr = await storage.read(key: _encryptionKeyName);
    if (keyStr == null) {
      final key = Hive.generateSecureKey();
      keyStr = base64UrlEncode(key);
      await storage.write(key: _encryptionKeyName, value: keyStr);
    }
    return base64Url.decode(keyStr);
  }
}

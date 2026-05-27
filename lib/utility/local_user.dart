import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class LocalUser {
  static const String _boxName = 'moshimoshi';
  static const String _uidKey = 'localUid';

  static String ensureUid() {
    final box = Hive.box(_boxName);
    final existing = box.get(_uidKey);
    if (existing is String && existing.isNotEmpty) {
      return existing;
    }

    final fresh = const Uuid().v4();
    box.put(_uidKey, fresh);

    return fresh;
  }

  static String? currentUid() {
    final box = Hive.box(_boxName);
    final value = box.get(_uidKey);

    return value is String && value.isNotEmpty ? value : null;
  }

  static Future<void> clear() async {
    final box = Hive.box(_boxName);
    await box.delete(_uidKey);
  }
}

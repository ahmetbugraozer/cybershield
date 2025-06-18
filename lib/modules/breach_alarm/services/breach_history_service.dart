import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'email_breach_service.dart';

@HiveType(typeId: 0)
class StoredBreachResult extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  bool hasBreaches;

  @HiveField(2)
  List<String> breachNames;

  @HiveField(3)
  DateTime lastChecked;

  @HiveField(4)
  String message;

  @HiveField(5)
  int breachCount;

  StoredBreachResult({
    required this.email,
    required this.hasBreaches,
    required this.breachNames,
    required this.lastChecked,
    required this.message,
    required this.breachCount,
  });

  factory StoredBreachResult.fromEmailBreachResult(EmailBreachResult result) {
    return StoredBreachResult(
      email: result.email,
      hasBreaches: result.hasBreaches,
      breachNames: result.breaches.map((b) => b.name).toList(),
      lastChecked: result.lastChecked,
      message: result.message,
      breachCount: result.breaches.length,
    );
  }
}

class BreachHistoryService {
  static const String _boxName = 'breach_history';
  Box<StoredBreachResult>? _box;
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized && _box != null) return true;

    try {
      // Hive adapter'ını register et (sadece bir kez)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(StoredBreachResultAdapter());
      }

      // Box'ı aç
      _box = await Hive.openBox<StoredBreachResult>(_boxName);
      _isInitialized = true;
      debugPrint('Hive box initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Hive initialization error: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<void> saveResult(EmailBreachResult result) async {
    if (!_isInitialized || _box == null) {
      await init(); // Eğer initialize edilmemişse, tekrar dene
    }

    if (_box != null) {
      final stored = StoredBreachResult.fromEmailBreachResult(result);
      await _box!.put(result.email.toLowerCase(), stored);
      debugPrint('Result saved to Hive for: ${result.email}');
    }
  }

  StoredBreachResult? getLastResult(String email) {
    try {
      if (_box == null || !_isInitialized) return null;
      return _box!.get(email.toLowerCase());
    } catch (e) {
      debugPrint('Error getting from Hive: $e');
      return null;
    }
  }

  List<StoredBreachResult> getAllResults() {
    try {
      if (_box == null || !_isInitialized) return [];
      return _box!.values.toList()
        ..sort((a, b) => b.lastChecked.compareTo(a.lastChecked));
    } catch (e) {
      debugPrint('Error getting all results from Hive: $e');
      return [];
    }
  }

  Future<void> deleteResult(String email) async {
    try {
      await _ensureInitialized();
      if (_box != null) {
        await _box!.delete(email.toLowerCase());
      }
    } catch (e) {
      debugPrint('Error deleting from Hive: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _ensureInitialized();
      if (_box != null) {
        await _box!.clear();
      }
    } catch (e) {
      debugPrint('Error clearing Hive: $e');
    }
  }

  bool shouldCheckAgain(
    String email, {
    Duration threshold = const Duration(days: 7),
  }) {
    try {
      final lastResult = getLastResult(email);
      if (lastResult == null) return true;

      final now = DateTime.now();
      final difference = now.difference(lastResult.lastChecked);
      return difference > threshold;
    } catch (e) {
      debugPrint('Error checking shouldCheckAgain: $e');
      return true; // Hata durumunda yeniden kontrol et
    }
  }

  List<StoredBreachResult> getRecentBreaches({int days = 30}) {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return getAllResults()
          .where(
            (result) =>
                result.hasBreaches && result.lastChecked.isAfter(cutoff),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting recent breaches: $e');
      return [];
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        throw NotInitializedError('Hive veritabanı başlatılamadı');
      }
    }

    if (_box == null) {
      throw NotInitializedError('Hive box null durumda');
    }
  }
}

// NotInitializedError sınıfı oluşturalım
class NotInitializedError extends Error {
  final String message;

  NotInitializedError(this.message);

  @override
  String toString() => 'NotInitializedError: $message';
}

// Hive adapter'ı
class StoredBreachResultAdapter extends TypeAdapter<StoredBreachResult> {
  @override
  final int typeId = 0;

  @override
  StoredBreachResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredBreachResult(
      email: fields[0] as String? ?? '',
      hasBreaches: fields[1] as bool? ?? false,
      breachNames: (fields[2] as List?)?.cast<String>() ?? [],
      lastChecked: fields[3] as DateTime? ?? DateTime.now(),
      message: fields[4] as String? ?? '',
      breachCount: fields[5] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, StoredBreachResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.hasBreaches)
      ..writeByte(2)
      ..write(obj.breachNames)
      ..writeByte(3)
      ..write(obj.lastChecked)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.breachCount);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredBreachResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

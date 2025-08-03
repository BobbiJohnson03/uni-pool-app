import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:meta/meta.dart';
part 'vote_model.g.dart';

/// Reprezentuje pojedynczy głos oddany przez użytkownika.
/// Zawiera identyfikator sesji, urządzenia i użytkownika,
/// przechowuje odpowiedzi (zaszyfrowane),
/// zapisuje datę głosowania oraz generuje podpis (hash),
/// aby zapewnić integralność danych.

@HiveType(typeId: 2)
class VoteModel extends HiveObject {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String encryptedAnswers;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String deviceId;

  @HiveField(5)
  final String voteSignature;

  /// Główny konstruktor – szyfruje odpowiedzi i generuje podpis
  VoteModel({
    required this.sessionId,
    this.userId,
    required Map<String, dynamic> answers,
    required this.timestamp,
    required this.deviceId,
    required String encryptionKey,
  }) : encryptedAnswers = _encryptAnswers(answers, encryptionKey),
       voteSignature = _generateSignature(sessionId, deviceId, answers);

  /// Konstruktor pomocniczy do Hive Adaptera – dane już zaszyfrowane
  @visibleForTesting
  VoteModel.raw({
    required this.sessionId,
    this.userId,
    required this.encryptedAnswers,
    required this.timestamp,
    required this.deviceId,
    required this.voteSignature,
  });

  /// Szyfrowanie odpowiedzi (klucze typu String!)
  static String _encryptAnswers(Map<String, dynamic> answers, String secret) {
    final json = jsonEncode(answers);
    final key = encrypt.Key.fromUtf8(secret.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(json, iv: iv).base64;
  }

  /// Deszyfrowanie odpowiedzi z typu String -> Map
  static Map<String, dynamic> decryptAnswers(String encrypted, String secret) {
    final key = encrypt.Key.fromUtf8(secret.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encrypted, iv: iv);
    return Map<String, dynamic>.from(jsonDecode(decrypted));
  }

  /// Generowanie podpisu na podstawie zawartości
  static String _generateSignature(
    String sessionId,
    String deviceId,
    Map<String, dynamic> answers,
  ) {
    final raw = "$sessionId-$deviceId-${jsonEncode(answers)}";
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Walidacja głosu – sprawdzenie integralności
  bool validate(String encryptionKey) {
    final decrypted = decryptAnswers(encryptedAnswers, encryptionKey);
    final expected = _generateSignature(sessionId, deviceId, decrypted);
    return expected == voteSignature;
  }

  /// Serializacja do JSON (np. do WebSocket)
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'encryptedAnswers': encryptedAnswers,
    'timestamp': timestamp.toIso8601String(),
    'deviceId': deviceId,
    'voteSignature': voteSignature,
  };

  /// Deserializacja z JSON (np. przy odbiorze z sieci)
  factory VoteModel.fromJson(Map<String, dynamic> json, String encryptionKey) {
    final decryptedAnswers = decryptAnswers(
      json['encryptedAnswers'],
      encryptionKey,
    );

    return VoteModel(
      sessionId: json['sessionId'],
      userId: json['userId'],
      answers: decryptedAnswers,
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      encryptionKey: encryptionKey,
    );
  }
}

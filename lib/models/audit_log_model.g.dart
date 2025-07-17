// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuditLogModelAdapter extends TypeAdapter<AuditLogModel> {
  @override
  final int typeId = 6;

  @override
  AuditLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuditLogModel(
      action: fields[0] as String,
      sessionId: fields[1] as String,
      deviceId: fields[2] as String,
      timestamp: fields[3] as DateTime,
      details: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuditLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.action)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.deviceId)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

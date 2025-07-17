// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 0;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isAnonymous: fields[2] as bool,
      questions: (fields[3] as List).cast<QuestionModel>(),
      createdAt: fields[4] as DateTime,
      endsAt: fields[5] as DateTime?,
      isActive: fields[6] as bool,
      adminDeviceId: fields[7] as String,
      autoClose: fields[8] as bool,
      maxParticipants: fields[9] as int?,
      showResultsAfterVoting: fields[10] as bool,
      participantDeviceIds: (fields[11] as List).cast<String>(),
      isValid: fields[12] as bool,
      lastModified: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isAnonymous)
      ..writeByte(3)
      ..write(obj.questions)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.endsAt)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.adminDeviceId)
      ..writeByte(8)
      ..write(obj.autoClose)
      ..writeByte(9)
      ..write(obj.maxParticipants)
      ..writeByte(10)
      ..write(obj.showResultsAfterVoting)
      ..writeByte(11)
      ..write(obj.participantDeviceIds)
      ..writeByte(12)
      ..write(obj.isValid)
      ..writeByte(13)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

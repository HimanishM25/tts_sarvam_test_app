import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/domain/entities/transcript_entity.dart';

class TranscriptModel extends TranscriptEntity {
  const TranscriptModel({
    required super.id,
    required super.timestamp,
    required super.transcripts,
  });

  factory TranscriptModel.fromEntity(TranscriptEntity entity) {
    return TranscriptModel(
      id: entity.id,
      timestamp: entity.timestamp,
      transcripts: entity.transcripts,
    );
  }

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      transcripts: List<String>.from(json['transcripts'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'transcripts': transcripts,
    };
  }
}

class TranscriptModelAdapter extends TypeAdapter<TranscriptModel> {
  @override
  final int typeId = 0;

  @override
  TranscriptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptModel(
      id: fields[0] as String,
      timestamp: DateTime.parse(fields[1] as String),
      transcripts: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp.toIso8601String())
      ..writeByte(2)
      ..write(obj.transcripts);
  }
}

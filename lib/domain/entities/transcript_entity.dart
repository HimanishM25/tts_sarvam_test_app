class TranscriptEntity {
  final String id;
  final DateTime timestamp;
  final List<String> transcripts;

  const TranscriptEntity({
    required this.id,
    required this.timestamp,
    required this.transcripts,
  });
}

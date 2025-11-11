class ChatModel {
  final String id;
  final String title;
  final List<dynamic> participants;

  ChatModel({required this.id, required this.title, required this.participants});

  factory ChatModel.fromJson(Map<String, dynamic> j) {
    return ChatModel(
      id: j['_id'] ?? j['id'] ?? '',
      title: j['title'] ?? j['name'] ?? 'Chat',
      participants: j['participants'] ?? [],
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String fileUrl;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.fileUrl,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    return MessageModel(
      id: j['_id'] ?? j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: j['chatId'] ?? j['chat_id'] ?? '',
      senderId: j['senderId'] ?? j['sender_id'] ?? j['sender'] ?? '',
      content: j['content'] ?? '',
      messageType: j['messageType'] ?? j['type'] ?? 'text',
      fileUrl: j['fileUrl'] ?? j['file_url'] ?? '',
      createdAt: DateTime.tryParse(j['createdAt'] ?? j['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chatId": chatId,
      "senderId": senderId,
      "content": content,
      "messageType": messageType,
      "fileUrl": fileUrl,
    };
  }
}

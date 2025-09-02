class ChatMessageDto {
  final String? conversationId;
  final String? message;
  final String? imageBase64;
  final String? audioBase64;
  final ChatMessageType messageType;
  final List<ConversationHistoryDto>? conversationHistory;

  ChatMessageDto({
    this.conversationId,
    this.message,
    this.imageBase64,
    this.audioBase64,
    required this.messageType,
    this.conversationHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'message': message,
      'imageBase64': imageBase64,
      'audioBase64': audioBase64,
      'messageType': messageType.value,
      'conversationHistory': conversationHistory?.map((e) => e.toJson()).toList(),
    };
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      conversationId: json['conversationId'],
      message: json['message'],
      imageBase64: json['imageBase64'],
      audioBase64: json['audioBase64'],
      messageType: ChatMessageType.fromValue(json['messageType']),
      conversationHistory: json['conversationHistory'] != null
          ? (json['conversationHistory'] as List)
              .map((e) => ConversationHistoryDto.fromJson(e))
              .toList()
          : null,
    );
  }
}

class ChatResponseDto {
  final String message;
  final String messageType;
  final String timestamp;
  final String conversationId;

  ChatResponseDto({
    required this.message,
    required this.messageType,
    required this.timestamp,
    required this.conversationId,
  });

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatResponseDto(
      message: json['message'],
      messageType: json['messageType'],
      timestamp: json['timestamp'],
      conversationId: json['conversationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'messageType': messageType,
      'timestamp': timestamp,
      'conversationId': conversationId,
    };
  }
}

class ConversationHistoryDto {
  final String role;
  final String content;

  ConversationHistoryDto({
    required this.role,
    required this.content,
  });

  factory ConversationHistoryDto.fromJson(Map<String, dynamic> json) {
    return ConversationHistoryDto(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

enum ChatMessageType {
  text('text'),
  voice('voice'),
  image('image');

  const ChatMessageType(this.value);
  final String value;

  static ChatMessageType fromValue(String value) {
    return ChatMessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChatMessageType.text,
    );
  }
}

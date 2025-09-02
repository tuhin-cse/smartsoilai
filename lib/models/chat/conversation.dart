import 'chat_message.dart' show ChatMessageType;

class ConversationListDto {
  final String id;
  final String? title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;
  final String? lastMessage;

  ConversationListDto({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessage,
  });

  factory ConversationListDto.fromJson(Map<String, dynamic> json) {
    return ConversationListDto(
      id: json['id'],
      title: json['title'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      messageCount: json['messageCount'],
      lastMessage: json['lastMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'messageCount': messageCount,
      'lastMessage': lastMessage,
    };
  }
}

class ConversationDto {
  final String id;
  final String userId;
  final String? title;
  final String createdAt;
  final String updatedAt;
  final List<ConversationMessageDto> messages;

  ConversationDto({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      messages:
          (json['messages'] as List)
              .map((e) => ConversationMessageDto.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}

class ConversationMessageDto {
  final String id;
  final String userMessage;
  final String assistantMessage;
  final ChatMessageType messageType;
  final String createdAt;

  ConversationMessageDto({
    required this.id,
    required this.userMessage,
    required this.assistantMessage,
    required this.messageType,
    required this.createdAt,
  });

  factory ConversationMessageDto.fromJson(Map<String, dynamic> json) {
    return ConversationMessageDto(
      id: json['id'],
      userMessage: json['userMessage'],
      assistantMessage: json['assistantMessage'],
      messageType: ChatMessageType.fromValue(json['messageType']),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userMessage': userMessage,
      'assistantMessage': assistantMessage,
      'messageType': messageType.value,
      'createdAt': createdAt,
    };
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class ChatMessage {
  final int? id;
  final String content;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'sender_avatar')
  final String? senderAvatar;
  @JsonKey(name: 'recipient_id')
  final int? recipientId;
  @JsonKey(name: 'recipient_name')
  final String? recipientName;
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @JsonKey(name: 'channel_name')
  final String? channelName;
  final String type; // 'private', 'channel', 'broadcast'
  @JsonKey(name: 'message_type')
  final String messageType; // 'text', 'image', 'file', 'location', 'emergency'
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'is_emergency')
  final bool isEmergency;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ChatMessage({
    this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.recipientId,
    this.recipientName,
    this.channelId,
    this.channelName,
    required this.type,
    this.messageType = 'text',
    this.metadata,
    this.isRead = false,
    this.isEmergency = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    int? id,
    String? content,
    int? senderId,
    String? senderName,
    String? senderAvatar,
    int? recipientId,
    String? recipientName,
    String? channelId,
    String? channelName,
    String? type,
    String? messageType,
    Map<String, dynamic>? metadata,
    bool? isRead,
    bool? isEmergency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      type: type ?? this.type,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isPrivateMessage => type == 'private';
  bool get isChannelMessage => type == 'channel';
  bool get isBroadcastMessage => type == 'broadcast';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

@JsonSerializable()
class ChatChannel {
  final String id;
  final String name;
  final String description;
  final String type; // 'public', 'private', 'emergency'
  @JsonKey(name: 'created_by')
  final int createdBy;
  @JsonKey(name: 'created_by_name')
  final String createdByName;
  final List<int> members;
  @JsonKey(name: 'member_names')
  final List<String> memberNames;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'last_message')
  final ChatMessage? lastMessage;
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ChatChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.createdByName,
    required this.members,
    required this.memberNames,
    this.isActive = true,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatChannel.fromJson(Map<String, dynamic> json) =>
      _$ChatChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatChannelToJson(this);

  ChatChannel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? createdBy,
    String? createdByName,
    List<int>? members,
    List<String>? memberNames,
    bool? isActive,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      members: members ?? this.members,
      memberNames: memberNames ?? this.memberNames,
      isActive: isActive ?? this.isActive,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isPublic => type == 'public';
  bool get isPrivate => type == 'private';
  bool get isEmergency => type == 'emergency';
}

@JsonSerializable()
class SendMessageRequest {
  final String content;
  @JsonKey(name: 'recipient_id')
  final int? recipientId;
  @JsonKey(name: 'channel_id')
  final String? channelId;
  final String type; // 'private', 'channel', 'broadcast'
  @JsonKey(name: 'message_type')
  final String messageType;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'is_emergency')
  final bool isEmergency;

  const SendMessageRequest({
    required this.content,
    this.recipientId,
    this.channelId,
    required this.type,
    this.messageType = 'text',
    this.metadata,
    this.isEmergency = false,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class CreateChannelRequest {
  final String name;
  final String description;
  final String type;
  final List<int> members;

  const CreateChannelRequest({
    required this.name,
    required this.description,
    required this.type,
    required this.members,
  });

  factory CreateChannelRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChannelRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChannelRequestToJson(this);
}

@JsonSerializable()
class ChatUser {
  final int id;
  final String name;
  final String? avatar;
  final String role;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);

  ChatUser copyWith({
    int? id,
    String? name,
    String? avatar,
    String? role,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  String get statusText {
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSeen!);
      
      if (difference.inDays > 0) {
        return 'Last seen ${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return 'Last seen ${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else {
        return 'Last seen just now';
      }
    }
    return 'Offline';
  }
}
class StatusHistoryEntry {
  final String status;
  final DateTime timestamp;
  final String note;

  StatusHistoryEntry({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp,
      'note': note,
    };
  }
}

class AdminResponse {
  final String message;
  final String respondedBy;
  final String respondedByTitle;
  final DateTime respondedAt;
  final bool verified;

  AdminResponse({
    required this.message,
    required this.respondedBy,
    required this.respondedByTitle,
    required this.respondedAt,
    this.verified = false,
  });

  factory AdminResponse.fromJson(Map<String, dynamic> json) {
    return AdminResponse(
      message: json['message'] ?? '',
      respondedBy: json['respondedBy'] ?? '',
      respondedByTitle: json['respondedByTitle'] ?? '',
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as dynamic).toDate()
          : DateTime.now(),
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'respondedBy': respondedBy,
      'respondedByTitle': respondedByTitle,
      'respondedAt': respondedAt,
      'verified': verified,
    };
  }
}

class ComplaintModel {
  final String id;
  final String refId;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final String category;
  final String status; // "pending", "in_progress", "resolved"
  final List<String> attachments;
  final AdminResponse? adminResponse;
  final List<StatusHistoryEntry> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintModel({
    required this.id,
    required this.refId,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.attachments = const [],
    this.adminResponse,
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ComplaintModel(
      id: id ?? json['id'] ?? '',
      refId: json['refId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'pending',
      attachments: List<String>.from(json['attachments'] ?? []),
      adminResponse: json['adminResponse'] != null
          ? AdminResponse.fromJson(json['adminResponse'])
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusHistoryEntry.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refId': refId,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'attachments': attachments,
      'adminResponse': adminResponse?.toJson(),
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? refId,
    String? userId,
    String? userName,
    String? title,
    String? description,
    String? category,
    String? status,
    List<String>? attachments,
    AdminResponse? adminResponse,
    List<StatusHistoryEntry>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      refId: refId ?? this.refId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      adminResponse: adminResponse ?? this.adminResponse,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

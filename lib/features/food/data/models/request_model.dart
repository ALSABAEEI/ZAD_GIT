import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.proposalId,
    required super.proposalTitle,
    required super.charityId,
    required super.charityName,
    required super.restaurantId,
    required super.restaurantName,
    required super.requestedAt,
    required super.status,
    required super.message,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json, String id) {
    return RequestModel(
      id: id,
      proposalId: json['proposalId'] ?? '',
      proposalTitle: json['proposalTitle'] ?? '',
      charityId: json['charityId'] ?? '',
      charityName: json['charityName'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposalId': proposalId,
      'proposalTitle': proposalTitle,
      'charityId': charityId,
      'charityName': charityName,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status,
      'message': message,
    };
  }
}

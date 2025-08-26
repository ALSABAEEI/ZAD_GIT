import '../../domain/entities/charity_proposal_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CharityProposalModel extends CharityProposalEntity {
  CharityProposalModel({
    required super.id,
    required super.title,
    required super.description,
    required super.requestedAmount,
    required super.targetedDate,
    required super.charityId,
    required super.organizationName,
    super.organizationImageUrl,
    required super.createdAt,
    required super.isActive,
    required super.status,
  });

  factory CharityProposalModel.fromJson(Map<String, dynamic> json, String id) {
    return CharityProposalModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requestedAmount: json['requestedAmount'] ?? 0,
      targetedDate: (json['targetedDate'] as Timestamp).toDate(),
      charityId: json['charityId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      organizationImageUrl: json['organizationImageUrl'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requestedAmount': requestedAmount,
      'targetedDate': targetedDate,
      'charityId': charityId,
      'organizationName': organizationName,
      'organizationImageUrl': organizationImageUrl,
      'createdAt': createdAt,
      'isActive': isActive,
      'status': status,
    };
  }
}

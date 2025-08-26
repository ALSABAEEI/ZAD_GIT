class CharityProposalEntity {
  final String id;
  final String title;
  final String description;
  final int requestedAmount;
  final DateTime targetedDate;
  final String charityId;
  final String organizationName;
  final String? organizationImageUrl;
  final DateTime createdAt;
  final bool isActive;
  final String status;

  CharityProposalEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.requestedAmount,
    required this.targetedDate,
    required this.charityId,
    required this.organizationName,
    this.organizationImageUrl,
    required this.createdAt,
    required this.isActive,
    required this.status,
  });
}

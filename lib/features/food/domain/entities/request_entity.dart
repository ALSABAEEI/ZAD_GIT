class RequestEntity {
  final String id;
  final String proposalId;
  final String proposalTitle;
  final String charityId;
  final String charityName;
  final String restaurantId;
  final String restaurantName;
  final DateTime requestedAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final String message; // Optional message from restaurant

  const RequestEntity({
    required this.id,
    required this.proposalId,
    required this.proposalTitle,
    required this.charityId,
    required this.charityName,
    required this.restaurantId,
    required this.restaurantName,
    required this.requestedAt,
    required this.status,
    required this.message,
  });
}

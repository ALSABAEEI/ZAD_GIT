import '../entities/request_entity.dart';

abstract class RequestRepository {
  Future<List<RequestEntity>> getRequestsByCharity(String charityId);
  Future<List<RequestEntity>> getRequestsByRestaurant(String restaurantId);
  Future<void> createRequest(RequestEntity request);
  Future<void> updateRequestStatus(String requestId, String status);
  Future<void> deleteRequest(String requestId);
  Future<bool> hasRestaurantApplied(String proposalId, String restaurantId);
}

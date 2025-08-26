import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<RequestEntity>> getRequestsByCharity(String charityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('charityId', isEqualTo: charityId)
          .get();

      final requests = querySnapshot.docs
          .map((doc) => RequestModel.fromJson(doc.data(), doc.id))
          .toList();

      // Sort in memory to avoid composite index requirement
      requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

      return requests;
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
    }
  }

  @override
  Future<List<RequestEntity>> getRequestsByRestaurant(
    String restaurantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      final requests = querySnapshot.docs
          .map((doc) => RequestModel.fromJson(doc.data(), doc.id))
          .toList();

      // Sort in memory to avoid composite index requirement
      requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

      return requests;
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
    }
  }

  @override
  Future<void> createRequest(RequestEntity request) async {
    try {
      print('REQUEST REPO: Starting to create request ${request.id}');
      final requestModel = RequestModel(
        id: request.id,
        proposalId: request.proposalId,
        proposalTitle: request.proposalTitle,
        charityId: request.charityId,
        charityName: request.charityName,
        restaurantId: request.restaurantId,
        restaurantName: request.restaurantName,
        requestedAt: request.requestedAt,
        status: request.status,
        message: request.message,
      );

      print('REQUEST REPO: RequestModel created, saving to Firestore...');
      await _firestore
          .collection('requests')
          .doc(request.id)
          .set(requestModel.toJson());

      print(
        'REQUEST REPO: Successfully created request ${request.id} for ${request.proposalTitle}',
      );
    } catch (e) {
      print('REQUEST REPO: Error creating request: $e');
      throw Exception('Failed to create request: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete request: $e');
    }
  }

  @override
  Future<bool> hasRestaurantApplied(
    String proposalId,
    String restaurantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('proposalId', isEqualTo: proposalId)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check application status: $e');
    }
  }
}

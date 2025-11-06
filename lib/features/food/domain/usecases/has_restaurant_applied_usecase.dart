import '../repositories/request_repository.dart';

class HasRestaurantAppliedUseCase {
  final RequestRepository repository;

  HasRestaurantAppliedUseCase(this.repository);

  Future<bool> call(String proposalId, String restaurantId) async {
    return await repository.hasRestaurantApplied(proposalId, restaurantId);
  }
}



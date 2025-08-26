import '../entities/request_entity.dart';
import '../repositories/request_repository.dart';

class GetRequestsByRestaurantUseCase {
  final RequestRepository repository;

  GetRequestsByRestaurantUseCase(this.repository);

  Future<List<RequestEntity>> call(String restaurantId) async {
    return await repository.getRequestsByRestaurant(restaurantId);
  }
}

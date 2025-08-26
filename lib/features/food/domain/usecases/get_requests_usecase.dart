import '../entities/request_entity.dart';
import '../repositories/request_repository.dart';

class GetRequestsUseCase {
  final RequestRepository repository;

  GetRequestsUseCase(this.repository);

  Future<List<RequestEntity>> call(String charityId) async {
    return await repository.getRequestsByCharity(charityId);
  }
}

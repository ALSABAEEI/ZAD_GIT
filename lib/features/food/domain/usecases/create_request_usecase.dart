import '../entities/request_entity.dart';
import '../repositories/request_repository.dart';

class CreateRequestUseCase {
  final RequestRepository repository;

  CreateRequestUseCase(this.repository);

  Future<void> call(RequestEntity request) async {
    return await repository.createRequest(request);
  }
}

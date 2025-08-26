import '../repositories/request_repository.dart';

class UpdateRequestStatusUseCase {
  final RequestRepository repository;

  UpdateRequestStatusUseCase(this.repository);

  Future<void> call(String requestId, String status) async {
    return await repository.updateRequestStatus(requestId, status);
  }
}

import '../entities/cr_info_entity.dart';
import '../repositories/wathq_repository.dart';

class ValidateCrnUseCase {
  final WathqRepository repository;

  ValidateCrnUseCase(this.repository);

  Future<(CrInfoEntity, String)> call(String crn, {String? role}) async {
    final info = await repository.getCrInfo(crn, role: role);
    final status = await repository.getCrStatus(crn);
    return (info, status);
  }
}

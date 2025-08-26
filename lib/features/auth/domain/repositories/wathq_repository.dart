import '../entities/cr_info_entity.dart';

abstract class WathqRepository {
  Future<CrInfoEntity> getCrInfo(String crn, {String? role});
  Future<String> getCrStatus(String crn);
}

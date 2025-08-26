import '../../domain/entities/cr_info_entity.dart';
import '../../domain/repositories/wathq_repository.dart';
import '../datasources/wathq_remote_datasource.dart';
import '../models/wathq_cr_info_model.dart';

class WathqRepositoryImpl implements WathqRepository {
  final WathqRemoteDatasource remoteDatasource;

  WathqRepositoryImpl(this.remoteDatasource);

  static const List<String> restaurantKeywords = [
    'مطعم',
    'مطاعم',
    'بوفية',
    'مطبخ',
    'مطابخ',
    'تغذية',
    'للاغذية',
    'اغذية',
    'اغذية',
    'أغذية',
    'الغذائية',
  ];
  static const List<String> charityKeywords = ['جمعية', 'الجمعية'];

  @override
  Future<CrInfoEntity> getCrInfo(String crn, {String? role}) async {
    final json = await remoteDatasource.fetchCrInfo(crn);
    final status = json['status']?['name'] ?? '';
    if (status != 'نشط') {
      throw Exception('The organization is not active.');
    }
    final name = json['name'] ?? '';
    final activities =
        (json['activities'] as List?)
            ?.map((a) => a['name'] as String)
            .toList() ??
        [];
    if (role == 'Organization') {
      if (!charityKeywords.any((kw) => name.contains(kw))) {
        throw Exception(
          'The name does not indicate a charity (جمعية/الجمعية).',
        );
      }
    }
    if (role == 'Restaurant') {
      final foundInName = restaurantKeywords.any((kw) => name.contains(kw));
      final foundInActivities = activities.any(
        (a) => restaurantKeywords.any((kw) => a.contains(kw)),
      );
      if (!foundInName && !foundInActivities) {
        throw Exception('The name or activities do not indicate a restaurant.');
      }
    }
    return CrInfoEntity(
      name: name,
      type: json['entityType']?['name'] ?? '',
      status: status,
    );
  }

  @override
  Future<String> getCrStatus(String crn) async {
    final json = await remoteDatasource.fetchCrStatus(crn);
    return json['status'] ?? '';
  }
}

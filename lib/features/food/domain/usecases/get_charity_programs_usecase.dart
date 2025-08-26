import 'package:flutter_bloc/flutter_bloc.dart';
import '../entities/charity_proposal_entity.dart';
import '../repositories/charity_proposal_repository.dart';

class GetCharityProgramsUseCase {
  final CharityProposalRepository repository;

  GetCharityProgramsUseCase(this.repository);

  Future<List<CharityProposalEntity>> execute(String charityId) async {
    return await repository.getCharityProposalsByCharity(charityId);
  }
}

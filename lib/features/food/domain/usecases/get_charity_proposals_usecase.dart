import '../repositories/charity_proposal_repository.dart';
import '../entities/charity_proposal_entity.dart';

class GetCharityProposalsUseCase {
  final CharityProposalRepository repository;

  GetCharityProposalsUseCase(this.repository);

  Future<List<CharityProposalEntity>> call() async {
    return await repository.getCharityProposals();
  }
}

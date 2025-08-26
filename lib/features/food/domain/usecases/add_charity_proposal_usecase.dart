import '../repositories/charity_proposal_repository.dart';
import '../entities/charity_proposal_entity.dart';

class AddCharityProposalUseCase {
  final CharityProposalRepository repository;

  AddCharityProposalUseCase(this.repository);

  Future<void> call(CharityProposalEntity proposal) async {
    return await repository.addCharityProposal(proposal);
  }
}

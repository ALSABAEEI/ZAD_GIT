import '../repositories/charity_proposal_repository.dart';

class DeleteCharityProposalUseCase {
  final CharityProposalRepository repository;

  DeleteCharityProposalUseCase(this.repository);

  Future<void> execute(String proposalId) async {
    await repository.deleteCharityProposal(proposalId);
  }
}

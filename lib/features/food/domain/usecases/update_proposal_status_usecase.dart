import '../entities/charity_proposal_entity.dart';
import '../repositories/charity_proposal_repository.dart';
import '../../data/models/charity_proposal_model.dart';

class UpdateProposalStatusUseCase {
  final CharityProposalRepository repository;

  UpdateProposalStatusUseCase(this.repository);

  Future<void> execute(String proposalId, String status) async {
    // First get the current proposal
    final proposals = await repository.getCharityProposals();
    final proposal = proposals.firstWhere((p) => p.id == proposalId);

    // Create updated proposal with new status
    final updatedProposal = CharityProposalModel(
      id: proposal.id,
      title: proposal.title,
      description: proposal.description,
      requestedAmount: proposal.requestedAmount,
      targetedDate: proposal.targetedDate,
      charityId: proposal.charityId,
      organizationName: proposal.organizationName,
      organizationImageUrl: proposal.organizationImageUrl,
      status: status, // Update the status
      isActive: proposal.isActive,
      createdAt: proposal.createdAt,
    );

    // Update the proposal
    await repository.updateCharityProposal(updatedProposal);
  }
}

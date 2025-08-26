import '../entities/charity_proposal_entity.dart';

abstract class CharityProposalRepository {
  Future<List<CharityProposalEntity>> getCharityProposals();
  Future<List<CharityProposalEntity>> getCharityProposalsByCharity(
    String charityId,
  );
  Future<void> addCharityProposal(CharityProposalEntity proposal);
  Future<void> updateCharityProposal(CharityProposalEntity proposal);
  Future<void> deleteCharityProposal(String proposalId);
}

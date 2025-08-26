import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/charity_proposal_repository.dart';
import '../../domain/entities/charity_proposal_entity.dart';
import '../models/charity_proposal_model.dart';

class CharityProposalRepositoryImpl implements CharityProposalRepository {
  final FirebaseFirestore _firestore;

  CharityProposalRepositoryImpl(this._firestore);

  @override
  Future<List<CharityProposalEntity>> getCharityProposals() async {
    try {
      final querySnapshot = await _firestore
          .collection('charity_proposals')
          .get();
      return querySnapshot.docs
          .map((doc) => CharityProposalModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get charity proposals: $e');
    }
  }

  @override
  Future<List<CharityProposalEntity>> getCharityProposalsByCharity(
    String charityId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('charity_proposals')
          .where('charityId', isEqualTo: charityId)
          .get();

      return querySnapshot.docs
          .map((doc) => CharityProposalModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get charity programs: $e');
    }
  }

  @override
  Future<void> addCharityProposal(CharityProposalEntity proposal) async {
    try {
      final proposalModel = proposal as CharityProposalModel;
      await _firestore
          .collection('charity_proposals')
          .add(proposalModel.toJson());
    } catch (e) {
      throw Exception('Failed to add charity proposal: $e');
    }
  }

  @override
  Future<void> updateCharityProposal(CharityProposalEntity proposal) async {
    try {
      final proposalModel = proposal as CharityProposalModel;
      await _firestore
          .collection('charity_proposals')
          .doc(proposal.id)
          .update(proposalModel.toJson());
    } catch (e) {
      throw Exception('Failed to update charity proposal: $e');
    }
  }

  @override
  Future<void> deleteCharityProposal(String proposalId) async {
    try {
      await _firestore.collection('charity_proposals').doc(proposalId).delete();
    } catch (e) {
      throw Exception('Failed to delete charity proposal: $e');
    }
  }
}

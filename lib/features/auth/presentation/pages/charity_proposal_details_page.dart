import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../../../food/domain/entities/charity_proposal_entity.dart';
import '../../../food/domain/entities/request_entity.dart';
import '../../../food/presentation/bloc/request_bloc.dart';
import '../../../notifications/domain/services/notification_service.dart';
import '../../../food/domain/usecases/has_restaurant_applied_usecase.dart';

class CharityProposalDetailsPage extends StatelessWidget {
  final CharityProposalEntity proposal;
  final bool isApplied;

  const CharityProposalDetailsPage({
    Key? key,
    required this.proposal,
    this.isApplied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Stunning Hero Section
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  proposal.organizationImageUrl != null &&
                          proposal.organizationImageUrl!.isNotEmpty
                      ? Image.network(
                          proposal.organizationImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildHeroPlaceholder();
                          },
                        )
                      : _buildHeroPlaceholder(),

                  // Beautiful Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Content Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Organization Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(proposal.charityId)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }

                                    final userData =
                                        snapshot.data?.data()
                                            as Map<String, dynamic>?;
                                    final organizationName =
                                        userData?['name'] ??
                                        proposal.organizationName;

                                    return Text(
                                      organizationName.isNotEmpty
                                          ? organizationName
                                          : 'Unknown Organization',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program Name Section (First)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                    const Color(0xFF7C3AED).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFF8B5CF6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Program Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Program Name Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8B5CF6).withOpacity(0.05),
                                const Color(0xFF7C3AED).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            proposal.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE2E8F0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Description Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF1E40AF).withOpacity(0.1),
                                    const Color(0xFF3B82F6).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Color(0xFF1E40AF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'About This Proposal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description Text
                        Text(
                          proposal.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.6,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE2E8F0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Details Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.1),
                                    const Color(0xFF059669).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Proposal Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Details Cards
                        Row(
                          children: [
                            // Quantity Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1E40AF).withOpacity(0.05),
                                      const Color(0xFF3B82F6).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF1E40AF,
                                    ).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1E40AF,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: Color(0xFF1E40AF),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${proposal.requestedAmount}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Items Needed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(
                                          0xFF1E40AF,
                                        ).withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Date Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFF59E0B).withOpacity(0.05),
                                      const Color(0xFFD97706).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF59E0B,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${proposal.targetedDate.day}/${proposal.targetedDate.month}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Target Date',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(
                                          0xFFF59E0B,
                                        ).withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Button Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _buildActionButton(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E40AF),
            const Color(0xFF3B82F6),
            const Color(0xFF06B6D4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Charity Proposal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isApplied) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF10B981), const Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            const Text(
              'Applied Successfully',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _applyToProposal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E40AF),
              const Color(0xFF3B82F6),
              const Color(0xFF06B6D4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            const Text(
              'Apply to Proposal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyToProposal(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Prevent duplicate requests for the same proposal by this restaurant
      final hasApplied = await context.read<HasRestaurantAppliedUseCase>().call(
        proposal.id,
        user.uid,
      );
      if (hasApplied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already applied to this proposal'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get restaurant name from user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final restaurantName = userData?['name'] ?? 'Unknown Restaurant';

      // Get charity organization name from charity profile (fallback to proposal)
      final charityDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proposal.charityId)
          .get();
      final charityData = charityDoc.data();
      final charityName =
          charityData?['organizationName'] ?? proposal.organizationName;

      // Create request with generated ID
      final requestId = FirebaseFirestore.instance
          .collection('requests')
          .doc()
          .id;
      final request = RequestEntity(
        id: requestId,
        proposalId: proposal.id,
        proposalTitle: proposal.title,
        restaurantId: user.uid,
        restaurantName: restaurantName,
        charityId: proposal.charityId,
        charityName: charityName,
        status: 'pending',
        requestedAt: DateTime.now(),
        message: 'I would like to help with this proposal.',
      );

      context.read<RequestBloc>().add(CreateRequest(request));

      // Fire-and-forget: notify organization (charity) of new request
      Future.microtask(() async {
        try {
          final notificationService = context.read<NotificationService>();
          await notificationService.notifyOrgOnRestaurantApplied(
            organizationUserId: proposal.charityId,
            restaurantName: request.restaurantName,
            proposalTitle: proposal.title,
            requestId: request.id,
          );
        } catch (e) {
          print('NOTIFY ORG NEW REQUEST failed: $e');
        }
      });

      // Return true to indicate successful application
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

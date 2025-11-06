import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../food/presentation/bloc/charity_proposal_bloc.dart';
import '../../../food/domain/entities/charity_proposal_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'charity_proposal_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../food/presentation/bloc/request_bloc.dart';
import '../../../food/data/models/request_model.dart';
import '../../../food/domain/usecases/has_restaurant_applied_usecase.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import 'restaurant_requests_page.dart';
import 'restaurant_profile_page.dart';
import 'restaurant_my_listings_page.dart';
import 'add_food_listing_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({Key? key}) : super(key: key);

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  Set<String> _appliedProposals = {};
  Map<String, String> _proposalIdToStatus = {};

  @override
  void initState() {
    super.initState();
    // Load charity proposals when page initializes
    context.read<CharityProposalBloc>().add(LoadCharityProposals());
    // Load applied proposals
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<RequestBloc>().add(LoadRequestsByRestaurant(user.uid));
      // Load notification count
      context.read<NotificationBloc>().add(LoadUnreadCount(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RequestBloc, RequestState>(
            listener: (context, requestState) {
              if (requestState is RequestCreated) {
                print('APPLY: Request created successfully in BLoC');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (requestState is RequestError) {
                print(
                  'APPLY: Error in request creation: ${requestState.message}',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${requestState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (requestState is RequestsLoaded) {
                // Build status map from loaded requests to drive UI
                final statusMap = <String, String>{};
                for (final r in requestState.requests) {
                  statusMap[r.proposalId] = r.status;
                }
                setState(() {
                  _proposalIdToStatus = statusMap;
                  _appliedProposals = statusMap.keys.toSet();
                });
              } else if (requestState is RequestStatusUpdated) {
                // Refresh requests to update local status map
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  context.read<RequestBloc>().add(
                    LoadRequestsByRestaurant(user.uid),
                  );
                }
              }
            },
          ),
          BlocListener<CharityProposalBloc, CharityProposalState>(
            listener: (context, proposalState) {
              // Refresh proposals when status changes
              if (proposalState is CharityProposalLoaded) {
                print('PROPOSAL: Proposals refreshed');
              }
            },
          ),
        ],
        child: CustomScrollView(
          slivers: [
            // Parallax Hero Section
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: const [],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image with Gradient Overlay
                    Container(
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E40AF).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Notification button placed near top-right (replaces decorative circle)
                    Positioned(
                      top: 40,
                      right: 16,
                      child: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          int unreadCount = 0;
                          if (state is UnreadCountLoaded) {
                            unreadCount = state.count;
                          }

                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationsPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: -30,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Content Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Share Your Delicious Meals',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Help those in need with your amazing food',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Quick Action Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddFoodListingPage(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant_menu_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Add Food Listing',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            'Share your delicious meals',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
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
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Proposals Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Proposals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1E40AF).withOpacity(0.1),
                                const Color(0xFF3B82F6).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1E40AF).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${context.watch<CharityProposalBloc>().state is CharityProposalLoaded ? (context.watch<CharityProposalBloc>().state as CharityProposalLoaded).proposals.length : 0} Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Proposals List
                  BlocBuilder<CharityProposalBloc, CharityProposalState>(
                    builder: (context, state) {
                      if (state is CharityProposalLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E40AF),
                          ),
                        );
                      }

                      if (state is CharityProposalError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading proposals',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is CharityProposalLoaded) {
                        final proposals = state.proposals;
                        if (proposals.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1E40AF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.inbox_rounded,
                                    size: 64,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No proposals available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for new charity requests',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        // Filter out accepted proposals (disappear from home)
                        final availableProposals = proposals
                            .where((proposal) => proposal.status != 'accepted')
                            .toList();

                        if (availableProposals.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1E40AF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.inbox_rounded,
                                    size: 64,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No proposals available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All proposals have been accepted or check back later',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: availableProposals.length,
                          itemBuilder: (context, index) {
                            final proposal = availableProposals[index];
                            final isApplied = _appliedProposals.contains(
                              proposal.id,
                            );
                            return _buildProposalCard(proposal, isApplied);
                          },
                        );
                      }

                      return const Center(
                        child: Text('No proposals available'),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 100,
                  ), // Bottom padding for navigation bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProposalCard(CharityProposalEntity proposal, bool isApplied) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section with Gradient Overlay
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharityProposalDetailsPage(
                    proposal: proposal,
                    isApplied: isApplied,
                  ),
                ),
              );

              if (result == true) {
                setState(() {
                  _appliedProposals.add(proposal.id);
                });
              }
            },
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                color: const Color(0xFFF8FAFC),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child:
                    proposal.organizationImageUrl != null &&
                        proposal.organizationImageUrl!.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            proposal.organizationImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildStunningPlaceholder();
                            },
                          ),
                          // Beautiful gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                          // Floating action indicator
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_rounded,
                                    color: const Color(0xFF1E40AF),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E40AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildStunningPlaceholder(),
              ),
            ),
          ),

          // Content Section with Beautiful Typography
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Text(
                  proposal.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Beautiful Info Cards Row
                Row(
                  children: [
                    // Quantity Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E40AF).withOpacity(0.08),
                              const Color(0xFF3B82F6).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1E40AF).withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E40AF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_rounded,
                                size: 16,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${proposal.requestedAmount} items',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Date Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.08),
                            const Color(0xFFD97706).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${proposal.targetedDate.day}/${proposal.targetedDate.month}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Full-width Action Button
                SizedBox(
                  width: double.infinity,
                  child: _buildApplyButton(proposal, isApplied),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStunningPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E40AF).withOpacity(0.08),
            const Color(0xFF3B82F6).withOpacity(0.08),
            const Color(0xFF06B6D4).withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: const Color(0xFF1E40AF),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Charity Proposal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view details',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1E40AF).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(CharityProposalEntity proposal, bool isApplied) {
    if (isApplied) {
      // Determine current request status from local map
      final status = _proposalIdToStatus[proposal.id] ?? 'applied';

      Color bg1;
      Color bg2;
      String label;
      if (status == 'rejected') {
        bg1 = Colors.red.shade500;
        bg2 = Colors.red.shade700;
        label = 'Rejected';
      } else if (status == 'accepted') {
        bg1 = Colors.green.shade400;
        bg2 = Colors.teal.shade500;
        label = 'Applied';
      } else {
        bg1 = Colors.grey.shade400;
        bg2 = Colors.grey.shade600;
        label = 'Applied';
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg1, bg2],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bg1.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    } else {
      // Not applied state
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _applyToProposal(proposal),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'Apply',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }
  }

  void _applyToProposal(CharityProposalEntity proposal) async {
    try {
      print('APPLY: Starting application process for proposal ${proposal.id}');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      print('APPLY: User authenticated: ${user.uid}');

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

      // Get charity organization name from charity's user profile
      final charityDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proposal.charityId)
          .get();
      final charityData = charityDoc.data();
      final charityName =
          charityData?['organizationName'] ??
          proposal.organizationName ??
          'Unknown Charity';

      // Create request with proper ID
      final requestId = FirebaseFirestore.instance
          .collection('requests')
          .doc()
          .id;
      print('APPLY: Generated request ID: $requestId');

      print('APPLY: Charity name from user profile: $charityName');

      final request = RequestModel(
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
      print('APPLY: RequestModel created successfully');
      print('APPLY: Request charity name: ${request.charityName}');

      // Dispatch the create request event
      print('APPLY: Dispatching CreateRequest event');
      context.read<RequestBloc>().add(CreateRequest(request));

      // Update local state immediately for better UX
      setState(() {
        _appliedProposals.add(proposal.id);
      });
      print('APPLY: Local state updated');

      // Reload requests to update the requests page
      print('APPLY: Reloading requests for restaurant');
      context.read<RequestBloc>().add(LoadRequestsByRestaurant(user.uid));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Listings',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantMyListingsPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.description_rounded,
                label: 'Requests',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantRequestsPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatListPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E40AF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF1E40AF)
                  : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF1E40AF)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

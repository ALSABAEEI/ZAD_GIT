import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../../../food/domain/entities/request_entity.dart';
import '../../../food/presentation/bloc/request_bloc.dart';
import '../../../food/presentation/bloc/charity_proposal_bloc.dart';
import '../../../chat/domain/entities/chat_room_entity.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../notifications/domain/services/notification_service.dart';
import 'charity_profile_page.dart';
import 'charity_home_page.dart';
import 'charity_reserved_page.dart';

class CharityRequestsPage extends StatefulWidget {
  const CharityRequestsPage({Key? key}) : super(key: key);

  @override
  State<CharityRequestsPage> createState() => _CharityRequestsPageState();
}

class _CharityRequestsPageState extends State<CharityRequestsPage> {
  String? _charityId;

  @override
  void initState() {
    super.initState();
    _charityId = FirebaseAuth.instance.currentUser?.uid;
    if (_charityId != null) {
      context.read<RequestBloc>().add(LoadRequests(_charityId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI dimensions available if needed

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf8fafc), Color(0xFFe0e7ff), Color(0xFFfef9c3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    Expanded(
                      child: Text(
                        'Restaurant Requests',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocBuilder<RequestBloc, RequestState>(
                  builder: (context, state) {
                    if (state is RequestLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      );
                    }

                    if (state is RequestError) {
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
                              'Error loading requests',
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

                    if (state is RequestsLoaded) {
                      final requests = state.requests;

                      if (requests.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No requests yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Restaurants will apply to your proposals here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return _buildRequestCard(request);
                        },
                      );
                    }

                    return const Center(child: Text('No requests available'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        2,
      ), // Requests tab
    );
  }

  Widget _buildRequestCard(RequestEntity request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Restaurant Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200, width: 2),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.orange.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.restaurantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applied to: ${request.proposalTitle}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(request.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(request.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Request Details
            if (request.message.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message from restaurant:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Request Date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Applied on ${_formatDate(request.requestedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons (only for pending requests)
            if (request.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateRequestStatus(request.id, 'accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateRequestStatus(request.id, 'rejected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Chat button for accepted requests
            if (request.status == 'accepted') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Request accepted! You can now chat with the restaurant.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _navigateToChat(context, request);
                        },
                        icon: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Chat with Restaurant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          shadowColor: Colors.green.shade600.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${difference} days ago';
    }
  }

  void _updateRequestStatus(String requestId, String status) async {
    try {
      // Update the request status
      context.read<RequestBloc>().add(UpdateRequestStatus(requestId, status));

      // Get the request data for notifications
      final requests = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      if (requests.exists) {
        final requestData = requests.data()!;
        final restaurantId = requestData['restaurantId'] as String;
        final proposalTitle = requestData['proposalTitle'] as String;
        final charityName = requestData['charityName'] as String;
        final proposalId = requestData['proposalId'] as String;

        // Create notification for restaurant (status update)
        final notificationService = context.read<NotificationService>();
        await notificationService.createProposalStatusNotification(
          restaurantId: restaurantId,
          proposalTitle: proposalTitle,
          organizationName: charityName,
          status: status,
          proposalId: proposalId,
        );

        // If the request is accepted, we also need to update the proposal status
        if (status == 'accepted') {
          // Update the proposal status to 'accepted'
          await FirebaseFirestore.instance
              .collection('charity_proposals')
              .doc(proposalId)
              .update({'status': 'accepted'});

          print('PROPOSAL: Updated proposal $proposalId status to accepted');

          // Refresh the charity proposals to update all restaurant home pages
          context.read<CharityProposalBloc>().add(LoadCharityProposals());

          // Create chat room for accepted request
          await _createChatRoomForAcceptedRequest(requestData);
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                status == 'accepted' ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Request ${status} successfully!')),
            ],
          ),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('ERROR: Failed to update request/proposal status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Reserved',
                  isActive: currentIndex == 1,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.inbox_rounded,
                  label: 'Requests',
                  isActive: currentIndex == 2,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  isActive: currentIndex == 3,
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Home tab
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CharityHomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          // Reserved tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CharityReservedPage()),
          );
        } else if (index == 2) {
          // Requests tab - Already on this page, do nothing
          return;
        } else if (index == 3) {
          // Chat tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatListPage()),
          );
        } else if (index == 4) {
          // Profile tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CharityProfilePage()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1E40AF), const Color(0xFF1E3A8A)],
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isActive
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createChatRoomForAcceptedRequest(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final chatRoomId =
          '${requestData['restaurantId']}_${requestData['charityId']}_${requestData['proposalId']}';

      final chatRoom = {
        'id': chatRoomId,
        'requestId': requestData['id'],
        'restaurantId': requestData['restaurantId'],
        'charityId': requestData['charityId'],
        'restaurantName': requestData['restaurantName'],
        'charityName': requestData['charityName'],
        'proposalTitle': requestData['proposalTitle'],
        'createdAt': requestData['requestedAt'],
        'isActive': true,
        'lastMessageAt': requestData['requestedAt'],
        'lastMessageText': 'Request accepted - Chat now available!',
      };

      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .set(chatRoom);

      print('CHAT: Created chat room $chatRoomId for accepted request');
    } catch (e) {
      print('CHAT: Error creating chat room for accepted request: $e');
      // Don't throw error to avoid breaking request acceptance
    }
  }

  void _navigateToChat(BuildContext context, RequestEntity request) async {
    // Create chat room entity for navigation
    final chatRoom = ChatRoomEntity(
      id: '${request.restaurantId}_${request.charityId}_${request.proposalId}',
      requestId: request.id,
      restaurantId: request.restaurantId,
      charityId: request.charityId,
      restaurantName: request.restaurantName,
      charityName: request.charityName,
      proposalTitle: request.proposalTitle,
      createdAt: request.requestedAt,
      isActive: true,
      lastMessageAt: request.requestedAt,
      lastMessageText: 'Request accepted - Chat now available!',
    );

    try {
      // Create the chat room in Firestore first
      context.read<ChatBloc>().add(CreateChatRoom(chatRoom));

      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(chatRoom: chatRoom)),
      );
    } catch (e) {
      // If chat room creation fails, still navigate but show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat room creation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(chatRoom: chatRoom)),
      );
    }
  }
}

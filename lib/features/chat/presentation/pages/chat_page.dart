import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../bloc/chat_bloc.dart' as chat_bloc;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:io';
// removed unused: dart:typed_data, dart:math
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../auth/presentation/pages/restaurant_home_page.dart';
import '../../../auth/presentation/pages/restaurant_my_listings_page.dart';
import '../../../auth/presentation/pages/restaurant_requests_page.dart';
import '../../../auth/presentation/pages/restaurant_profile_page.dart';
import '../../../auth/presentation/pages/charity_home_page.dart';
import '../../../auth/presentation/pages/charity_reserved_page.dart';
import '../../../auth/presentation/pages/charity_requests_page.dart';
import '../../../auth/presentation/pages/charity_profile_page.dart';
import 'chat_list_page.dart';

class ChatPage extends StatefulWidget {
  final ChatRoomEntity chatRoom;

  const ChatPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final types.User _user = types.User(
    id: FirebaseAuth.instance.currentUser?.uid ?? '',
  );
  late types.User _otherUser;
  bool _isAttachmentUploading = false;
  String? _role; // 'Organization' or 'Restaurant'

  @override
  void initState() {
    super.initState();
    _setupUsers();
    _loadMessages();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _loadRole(uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupUsers() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isRestaurant = currentUserId == widget.chatRoom.restaurantId;

    _otherUser = types.User(
      id: isRestaurant
          ? widget.chatRoom.charityId
          : widget.chatRoom.restaurantId,
      firstName: isRestaurant
          ? widget.chatRoom.charityName
          : widget.chatRoom.restaurantName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _otherUser.firstName ?? 'Chat',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            Text(
              widget.chatRoom.proposalTitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Navigate back to chat list page smoothly
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ChatListPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add more options (block, report, etc.)
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocListener<chat_bloc.ChatBloc, chat_bloc.ChatState>(
        listener: (context, state) {
          if (state is chat_bloc.MessageSent) {
            // Reload messages after sending
            _loadMessages();
          }
        },
        child: BlocBuilder<chat_bloc.ChatBloc, chat_bloc.ChatState>(
          builder: (context, state) {
            if (state is chat_bloc.ChatLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1E40AF)),
              );
            }

            if (state is chat_bloc.ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading messages',
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

            if (state is chat_bloc.MessagesLoaded) {
              // Convert ChatMessageEntity to flutter_chat_ui Message format
              final messages = state.messages.map((message) {
                switch (message.type) {
                  case MessageType.text:
                    return types.TextMessage(
                      author: types.User(
                        id: message.senderId,
                        firstName: message.senderName,
                      ),
                      id: message.id,
                      text: message.content,
                      createdAt: message.createdAt.millisecondsSinceEpoch,
                    );
                  case MessageType.image:
                    return types.ImageMessage(
                      author: types.User(
                        id: message.senderId,
                        firstName: message.senderName,
                      ),
                      id: message.id,
                      name: message.content,
                      uri: message.fileUrl ?? '',
                      size: message.fileSize ?? 0,
                      createdAt: message.createdAt.millisecondsSinceEpoch,
                    );
                  case MessageType.file:
                    return types.FileMessage(
                      author: types.User(
                        id: message.senderId,
                        firstName: message.senderName,
                      ),
                      id: message.id,
                      name: message.content,
                      uri: message.fileUrl ?? '',
                      size: message.fileSize ?? 0,
                      createdAt: message.createdAt.millisecondsSinceEpoch,
                    );
                }
              }).toList();

              return Chat(
                messages: messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onEndReached: () async => _handleEndReached(),
                onEndReachedThreshold: 0.1,
                theme: DefaultChatTheme(
                  primaryColor: const Color(0xFF1E40AF),
                  secondaryColor: const Color(0xFFE0E7FF),
                  backgroundColor: const Color(0xFFF8FAFC),
                  inputBackgroundColor: Colors.white,
                  inputTextColor: const Color(0xFF1E293B),
                  inputTextCursorColor: const Color(0xFF1E40AF),
                  sentMessageBodyTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  receivedMessageBodyTextStyle: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                  ),
                ),
              );
            }

            // Default case - show empty chat
            return Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onEndReached: () async => _handleEndReached(),
              onEndReachedThreshold: 0.1,
              theme: DefaultChatTheme(
                primaryColor: const Color(0xFF1E40AF),
                secondaryColor: const Color(0xFFE0E7FF),
                backgroundColor: const Color(0xFFF8FAFC),
                inputBackgroundColor: Colors.white,
                inputTextColor: const Color(0xFF1E293B),
                inputTextCursorColor: const Color(0xFF1E40AF),
                sentMessageBodyTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Future<void> _loadRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) return;
      setState(() {
        _role = doc.data()?['role'];
      });
    } catch (_) {}
  }

  Widget _buildBottomNavigationBar() {
    final isCharity = _role == 'Organization';
    if (isCharity) {
      return _buildCharityBottomNav(currentIndex: 3);
    }
    return _buildRestaurantBottomNav(currentIndex: 3); // Chat is now index 3
  }

  Widget _buildCharityBottomNav({required int currentIndex}) {
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
                _charityNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CharityHomePage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _charityNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Reserved',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CharityReservedPage(),
                      ),
                    );
                  },
                ),
                _charityNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.inbox_rounded,
                  label: 'Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CharityRequestsPage(),
                      ),
                    );
                  },
                ),
                _charityNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  onTap: () {
                    // Navigate back to chat list
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ChatListPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
                _charityNavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CharityProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _charityNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: onTap ?? () {},
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

  Widget _buildRestaurantBottomNav({required int currentIndex}) {
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
              _restaurantNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantHomePage(),
                    ),
                  );
                },
              ),
              _restaurantNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Listings',
                isActive: currentIndex == 1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantMyListingsPage(),
                    ),
                  );
                },
              ),
              _restaurantNavItem(
                icon: Icons.description_rounded,
                label: 'Requests',
                isActive: currentIndex == 2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantRequestsPage(),
                    ),
                  );
                },
              ),
              _restaurantNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: currentIndex == 3,
                onTap: () {
                  // Navigate back to chat list
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ChatListPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
              _restaurantNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 4,
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

  Widget _restaurantNavItem({
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

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Send to backend
    final chatMessage = ChatMessageEntity(
      id: textMessage.id,
      chatRoomId: widget.chatRoom.id,
      senderId: _user.id,
      senderName: _user.firstName ?? 'User',
      type: MessageType.text,
      content: message.text,
      createdAt: DateTime.now(),
      isRead: false,
    );

    context.read<chat_bloc.ChatBloc>().add(chat_bloc.SendMessage(chatMessage));
  }

  void _handleAttachmentPressed() {
    if (_isAttachmentUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, uploading...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Send Attachment',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.blue),
                title: const Text('Photo'),
                subtitle: const Text('Send image from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _addImage();
                },
              ),
              if (!kIsWeb) ...[
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                  title: const Text('Camera'),
                  subtitle: const Text('Take photo with camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _addImageFromCamera();
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.file_present, color: Colors.green),
                title: const Text('File'),
                subtitle: const Text('Send any file (max 5MB)'),
                onTap: () {
                  Navigator.pop(context);
                  _addFile();
                },
              ),
              if (kIsWeb) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.grey),
                  title: const Text('Mobile Features'),
                  subtitle: const Text(
                    'Camera capture available on mobile app',
                  ),
                  enabled: false,
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      setState(() {
        _isAttachmentUploading = true;
      });

      try {
        // Upload to Firebase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.name}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(widget.chatRoom.id)
            .child(fileName);

        late final UploadTask uploadTask;
        late final int fileSize;

        if (kIsWeb) {
          // For web, use bytes
          final bytes = await result.readAsBytes();
          fileSize = bytes.length;
          uploadTask = storageRef.putData(bytes);
        } else {
          // For mobile, use file
          final file = File(result.path);
          fileSize = await file.length();
          uploadTask = storageRef.putFile(file);
        }

        final uploadResult = await uploadTask;
        final downloadUrl = await uploadResult.ref.getDownloadURL();

        // Create UI message first
        final message = types.ImageMessage(
          author: _user,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result.name,
          size: fileSize,
          uri: downloadUrl,
        );

        _addMessage(message);

        // Send to backend
        final chatMessage = ChatMessageEntity(
          id: message.id,
          chatRoomId: widget.chatRoom.id,
          senderId: _user.id,
          senderName: _user.firstName ?? 'User',
          type: MessageType.image,
          content: result.name,
          fileUrl: downloadUrl,
          fileSize: fileSize,
          createdAt: DateTime.now(),
          isRead: false,
        );

        context.read<chat_bloc.ChatBloc>().add(
          chat_bloc.SendMessage(chatMessage),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }
  }

  void _addImageFromCamera() async {
    // Check for web platform first
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera is not available on web. Please use gallery instead.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      setState(() {
        _isAttachmentUploading = true;
      });

      try {
        // Upload to Firebase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.name}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(widget.chatRoom.id)
            .child(fileName);

        final file = File(result.path);
        final fileSize = await file.length();
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Create UI message first
        final message = types.ImageMessage(
          author: _user,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result.name,
          size: fileSize,
          uri: downloadUrl,
        );

        _addMessage(message);

        // Send to backend
        final chatMessage = ChatMessageEntity(
          id: message.id,
          chatRoomId: widget.chatRoom.id,
          senderId: _user.id,
          senderName: _user.firstName ?? 'User',
          type: MessageType.image,
          content: result.name,
          fileUrl: downloadUrl,
          fileSize: fileSize,
          createdAt: DateTime.now(),
          isRead: false,
        );

        context.read<chat_bloc.ChatBloc>().add(
          chat_bloc.SendMessage(chatMessage),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }
  }

  void _addFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      // Check file size (5MB limit)
      if (file.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size must be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isAttachmentUploading = true;
      });

      try {
        // Upload to Firebase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_files')
            .child(widget.chatRoom.id)
            .child(fileName);

        late final UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = storageRef.putData(file.bytes!);
        } else {
          uploadTask = storageRef.putFile(File(file.path!));
        }

        final uploadResult = await uploadTask;
        final downloadUrl = await uploadResult.ref.getDownloadURL();

        // Create UI message
        final message = types.FileMessage(
          author: _user,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          size: file.size,
          uri: downloadUrl,
        );

        _addMessage(message);

        // Send to backend
        final chatMessage = ChatMessageEntity(
          id: message.id,
          chatRoomId: widget.chatRoom.id,
          senderId: _user.id,
          senderName: _user.firstName ?? 'User',
          type: MessageType.file,
          content: file.name,
          fileUrl: downloadUrl,
          fileSize: file.size,
          createdAt: DateTime.now(),
          isRead: false,
        );

        context.read<chat_bloc.ChatBloc>().add(
          chat_bloc.SendMessage(chatMessage),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) {
    if (message is types.FileMessage) {
      // TODO: Handle file download
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleEndReached() {
    // TODO: Load more messages
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _loadMessages() {
    // Load messages for this chat room
    context.read<chat_bloc.ChatBloc>().add(
      chat_bloc.LoadMessages(widget.chatRoom.id),
    );
  }
}

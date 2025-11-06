import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../../../food/presentation/bloc/food_bloc.dart';
import '../../../food/presentation/bloc/reservation_bloc.dart';
import '../../../food/domain/entities/food_item_entity.dart';
import 'add_proposal_page.dart';
import 'charity_profile_page.dart';
import 'food_item_details_page.dart';
import 'charity_reserved_page.dart';
import 'charity_requests_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class CharityHomePage extends StatefulWidget {
  const CharityHomePage({Key? key}) : super(key: key);

  @override
  State<CharityHomePage> createState() => _CharityHomePageState();
}

class _CharityHomePageState extends State<CharityHomePage> {
  String? _selectedCategory;
  @override
  void initState() {
    super.initState();
    // Load food items when page initializes
    context.read<FoodBloc>().add(LoadFoodItems());

    // Load reservations for filtering
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ReservationBloc>().add(LoadReservations(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Parallax Hero Section
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back! 👋',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Find amazing food',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
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
                                  icon: Icon(
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
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Quick Action Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Share your needs',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Create a new proposal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AddProposalPage(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: const Color(0xFF1E40AF),
                                      size: 24,
                                    ),
                                  ),
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
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Browse Categories',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCategoryIcon(
                          icon: Icons.rice_bowl,
                          label: 'rice dish',
                          isSelected: _selectedCategory == 'rice dish',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'rice dish';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryIcon(
                          icon: Icons.lunch_dining,
                          label: 'Burgers',
                          isSelected: _selectedCategory == 'Burgers',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Burgers';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryIcon(
                          icon: Icons.outdoor_grill,
                          label: 'Mashawi',
                          isSelected: _selectedCategory == 'Mashawi',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Mashawi';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryIcon(
                          icon: Icons.cake,
                          label: 'Dessert',
                          isSelected: _selectedCategory == 'Dessert',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Dessert';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryIcon(
                          icon: Icons.local_drink,
                          label: 'Beverages',
                          isSelected: _selectedCategory == 'Beverages',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Beverages';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Food Listings Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Food',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Food Listings - Using BLoC
                BlocBuilder<FoodBloc, FoodState>(
                  builder: (context, state) {
                    if (state is FoodLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is FoodError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }

                    if (state is FoodLoaded) {
                      // Filter out unavailable items (reserved by any charity)
                      final availableItems = state.foodItems.where((foodItem) {
                        return foodItem.isAvailable;
                      }).toList();

                      final filteredItems = _selectedCategory == null
                          ? availableItems
                          : availableItems.where((item) {
                              final normalized = _normalizeCategoryLabel(
                                _selectedCategory!,
                              );
                              final itemType = (item.foodType ?? '')
                                  .trim()
                                  .toLowerCase();
                              return itemType == normalized;
                            }).toList();

                      if (filteredItems.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No food items available yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Restaurants will post food items here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final foodItem = filteredItems[index];
                          print(
                            'Building food card for: ${foodItem.name} with image: ${foodItem.imageUrl}',
                          );
                          return _buildFoodCard(foodItem);
                        },
                      );
                    }

                    return const Center(child: Text('No data available'));
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
      bottomNavigationBar: _buildBottomNavigationBar(context, 0),
    );
  }

  Widget _buildCategoryIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final Color baseColor = const Color(0xFF475569);
    final Color activeColor = const Color(0xFF1E40AF);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)]
                    : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? activeColor : baseColor).withOpacity(
                    0.12,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: (isSelected ? activeColor : const Color(0xFFE2E8F0)),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? activeColor : baseColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? activeColor : baseColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _normalizeCategoryLabel(String label) {
    final value = label.trim().toLowerCase();
    switch (value) {
      case 'rice dish':
      case 'rice dishes':
      case 'meat & rice':
      case 'meat and rice':
        return 'rice dish';
      default:
        return value;
    }
  }

  Widget _buildSeeAllButton() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1E40AF), const Color(0xFF1E3A8A)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'See All',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF667EEA),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFoodCard(FoodItemEntity foodItem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodItemDetailsPage(foodItem: foodItem),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
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
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: const Color(0xFFF8FAFC),
                ),
                child: Stack(
                  children: [
                    (() {
                          print(
                            'CHARITY HOME: Checking image URL: ${foodItem.imageUrl}',
                          );

                          final shouldShowImage =
                              foodItem.imageUrl.isNotEmpty &&
                              !foodItem.imageUrl.contains('placeholder') &&
                              !foodItem.imageUrl.contains('Upload+Failed');

                          print(
                            'CHARITY HOME: Should show image: $shouldShowImage',
                          );

                          return shouldShowImage;
                        })()
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: _buildSimpleImageWidget(foodItem.imageUrl),
                          )
                        : _buildFoodImagePlaceholder(),
                    // Price badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: foodItem.price == 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (foodItem.price == 0
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B))
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          foodItem.price == 0 ? 'FREE' : '\$${foodItem.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 14,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${foodItem.quantity}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Try using a CORS proxy to bypass Flutter web restrictions
    final proxyUrl =
        'https://api.allorigins.win/raw?url=${Uri.encodeComponent(imageUrl)}';

    return FutureBuilder<Uint8List>(
      future: _loadImageBytes(proxyUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print('Proxy image load error for $imageUrl: ${snapshot.error}');
          // Try direct approach as fallback
          return _buildDirectImageWidget(imageUrl);
        }
        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }

  Widget _buildSimpleImageWidget(String imageUrl) {
    // Mobile-optimized image loading
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Image load error for $imageUrl: $error');
        return _buildFoodImagePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.orange,
          ),
        );
      },
    );
  }

  Widget _buildDirectImageWidget(String imageUrl) {
    // Direct approach using Image.network as fallback
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Direct image load error for $imageUrl: $error');
        return _buildFoodImagePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.orange,
          ),
        );
      },
    );
  }

  Widget _buildImageWithProxy(String imageUrl) {
    // Try using a CORS proxy to bypass the issue
    final proxyUrl = 'https://cors-anywhere.herokuapp.com/$imageUrl';

    return FutureBuilder<Uint8List>(
      future: _loadImageBytes(proxyUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print('Proxy image load error for $imageUrl: ${snapshot.error}');
          return _buildFoodImagePlaceholder();
        }
        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }

  Future<Uint8List> _loadImageBytes(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Access-Control-Allow-Origin': '*',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading image bytes: $e');
      throw e;
    }
  }

  Widget _buildFoodImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Food Image',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
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
        if (index == 1) {
          // Reserved tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CharityReservedPage()),
          );
        } else if (index == 2) {
          // Requests tab
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CharityRequestsPage()),
          );
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
}

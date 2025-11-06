import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../../../food/presentation/bloc/food_bloc.dart';
import '../../../food/data/models/food_item_model.dart';

class AddFoodListingPage extends StatefulWidget {
  const AddFoodListingPage({Key? key}) : super(key: key);

  @override
  State<AddFoodListingPage> createState() => _AddFoodListingPageState();
}

class _AddFoodListingPageState extends State<AddFoodListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expirationHoursController = TextEditingController();
  String? _selectedFoodType;

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  bool _isFree = false;
  bool _imageSelected = false; // reserved for future UI hints

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Stunning Hero Section
          SliverAppBar(
            expandedHeight: 200,
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
              background: Container(
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
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Share Your Delicious Food',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help those in need with your amazing meals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF10B981).withOpacity(0.1),
                                      const Color(0xFF059669).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Color(0xFF10B981),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Food Image',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Image Upload Area
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.05),
                                    const Color(0xFF059669).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.2),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _buildImageContent(),
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

                    // Food Details Section
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1E40AF).withOpacity(0.1),
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFF1E40AF),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Food Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Food Name
                          _buildInputField(
                            controller: _foodNameController,
                            label: 'Food Name',
                            hint: 'Enter the name of your delicious food',
                            icon: Icons.restaurant_rounded,
                            color: const Color(0xFF1E40AF),
                          ),

                          const SizedBox(height: 28),

                          // Price and Free Checkbox Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _priceController,
                                  label: 'Price',
                                  hint: _isFree ? 'Free item' : 'Enter price',
                                  icon: Icons.attach_money_rounded,
                                  color: const Color(0xFFF59E0B),
                                  keyboardType: TextInputType.number,
                                  enabled: !_isFree,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                margin: const EdgeInsets.only(top: 40),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _isFree,
                                      onChanged: (value) {
                                        setState(() {
                                          _isFree = value ?? false;
                                          if (_isFree) {
                                            _priceController.clear();
                                          }
                                        });
                                      },
                                      activeColor: const Color(0xFF10B981),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const Text(
                                      'Free',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Quantity and Expiration Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _quantityController,
                                  label: 'Quantity',
                                  hint: 'Enter quantity',
                                  icon: Icons.inventory_2_rounded,
                                  color: const Color(0xFF8B5CF6),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildInputField(
                                  controller: _expirationHoursController,
                                  label: 'Expires In (Hours)',
                                  hint: 'Enter hours',
                                  icon: Icons.access_time_rounded,
                                  color: const Color(0xFFEF4444),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Food Type Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Food Type',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E40AF),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedFoodType,
                                items:
                                    const [
                                          'rice dish',
                                          'Burgers',
                                          'Mashawi',
                                          'Dessert',
                                          'Beverages',
                                        ]
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) => setState(() {
                                  _selectedFoodType = val;
                                }),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Food Type is required'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Select a food type',
                                  hintStyle: TextStyle(
                                    color: const Color(
                                      0xFF64748B,
                                    ).withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1E40AF,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.category_rounded,
                                      color: Color(0xFF1E40AF),
                                      size: 18,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: const Color(
                                        0xFF1E40AF,
                                      ).withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: const Color(
                                        0xFF1E40AF,
                                      ).withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E40AF),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(
                                    0xFF1E40AF,
                                  ).withOpacity(0.02),
                                ),
                              ),
                            ],
                          ),

                          // Description
                          _buildInputField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Describe your delicious food...',
                            icon: Icons.description_rounded,
                            color: const Color(0xFF06B6D4),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _buildSubmitButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null || _selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: kIsWeb
            ? Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Color(0xFF10B981),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to upload image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Show your delicious food',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF10B981).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: (value) {
            if (!enabled) return null; // Skip validation for disabled fields
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B).withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color.withOpacity(0.2), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color.withOpacity(0.2), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color.withOpacity(0.1), width: 1),
            ),
            filled: true,
            fillColor: enabled
                ? color.withOpacity(0.02)
                : color.withOpacity(0.01),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitForm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
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
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Creating...' : 'Create Food Listing',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    // Show beautiful selection dialog
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF10B981).withOpacity(0.1),
                                const Color(0xFF059669).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Color(0xFF10B981),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Take Photo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Use camera',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF10B981).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pop(context, ImageSource.gallery),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1E40AF).withOpacity(0.1),
                                const Color(0xFF3B82F6).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF1E40AF).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E40AF,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  color: Color(0xFF1E40AF),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload Photo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From gallery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E40AF).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return; // User cancelled

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _imageSelected = true;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload image
      String imageUrl = '';
      if (_selectedImageBytes != null || _selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('food_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        if (kIsWeb && _selectedImageBytes != null) {
          await storageRef.putData(_selectedImageBytes!);
        } else if (_selectedImage != null) {
          await storageRef.putFile(_selectedImage!);
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      // Get restaurant name
      final restaurantName = await _getRestaurantName(user.uid);

      // Create food item
      final foodItem = FoodItemModel(
        id: '',
        name: _foodNameController.text,
        description: _descriptionController.text,
        price: _isFree ? 0.0 : double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: imageUrl,
        restaurantId: user.uid,
        restaurantName: restaurantName,
        expirationHours: int.parse(_expirationHoursController.text),
        createdAt: DateTime.now(),
        isAvailable: true,
        foodType: _selectedFoodType,
      );

      context.read<FoodBloc>().add(AddFoodItem(foodItem));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food listing created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating food listing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getRestaurantName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.data()?['name'] ?? 'Unknown Restaurant';
    } catch (e) {
      return 'Unknown Restaurant';
    }
  }
}

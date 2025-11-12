import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../food/data/models/charity_proposal_model.dart';

class AddProposalPage extends StatefulWidget {
  const AddProposalPage({Key? key}) : super(key: key);

  @override
  State<AddProposalPage> createState() => _AddProposalPageState();
}

class _AddProposalPageState extends State<AddProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _targetedDateController = TextEditingController();

  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImagePath = null;
          _selectedImageBytes = bytes;
        });
      } else {
        // For mobile, use file path
        setState(() {
          _selectedImagePath = image.path;
          _selectedImageBytes = null;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImagePath = null;
          _selectedImageBytes = bytes;
        });
      } else {
        // For mobile, use file path
        setState(() {
          _selectedImagePath = image.path;
          _selectedImageBytes = null;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImagePath == null && _selectedImageBytes == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          'proposal_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask;

      if (kIsWeb && _selectedImageBytes != null) {
        // For web, upload bytes
        uploadTask = storageRef.putData(_selectedImageBytes!);
      } else if (!kIsWeb && _selectedImagePath != null) {
        // For mobile, upload file
        final file = File(_selectedImagePath!);
        uploadTask = storageRef.putFile(file);
      } else {
        throw Exception('No image data available');
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _targetedDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _submitProposal() async {
    print('DEBUG: _submitProposal called');

    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    if (_selectedDate == null) {
      print('DEBUG: No date selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a targeted date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Getting current user');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: User is null');
        throw Exception('User not authenticated');
      }
      print('DEBUG: User found: ${user.uid}');

      // Upload image if selected
      String? imageUrl;
      if (_selectedImagePath != null || _selectedImageBytes != null) {
        print('DEBUG: Uploading image');
        imageUrl = await _uploadImage();
        print('DEBUG: Image uploaded: $imageUrl');
      } else {
        print('DEBUG: No image to upload');
      }

      print('DEBUG: Creating proposal model');
      // Get organization name from user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final organizationName = userData?['name'] ?? 'Unknown Organization';

      // Create CharityProposalEntity
      final proposal = CharityProposalModel(
        id: '', // Will be set by Firestore
        title: _itemNameController.text,
        description: _descriptionController.text,
        requestedAmount: int.parse(_amountController.text),
        targetedDate: _selectedDate!,
        charityId: user.uid,
        organizationName: organizationName,
        organizationImageUrl: imageUrl,
        createdAt: DateTime.now(),
        isActive: true,
        status: 'pending',
      );

      print('DEBUG: Adding proposal to Firestore');
      final docRef = await FirebaseFirestore.instance
          .collection('charity_proposals')
          .add(proposal.toJson());

      print('DEBUG: Proposal added with ID: ${docRef.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposal created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('DEBUG: Error creating proposal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating proposal: $e'),
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

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: const Color(0xFF64748B).withOpacity(0.6),
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF667EEA), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Image Preview
          if (_selectedImagePath != null || _selectedImageBytes != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb && _selectedImageBytes != null
                    ? Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      )
                    : !kIsWeb && _selectedImagePath != null
                    ? Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.error,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Upload Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded, size: 20),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF59E0B),
                          const Color(0xFFD97706),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt_rounded, size: 20),
                      label: const Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Remove Image Button
          if (_selectedImagePath != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImagePath = null;
                      _selectedImageBytes = null;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  label: const Text(
                    'Remove Image',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Hero header similar to AddFoodListingPage
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
                      const Color(0xFF667EEA),
                      const Color(0xFF764BA2),
                      const Color(0xFF06B6D4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
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
                              Icons.assignment_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Share Your Needs',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new proposal',
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

          // Content card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF667EEA).withOpacity(0.12),
                                  const Color(0xFF764BA2).withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF667EEA),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Proposal Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Item Name
                      _buildFormSection(
                        title: 'Item Name',
                        icon: Icons.inventory_rounded,
                        child: TextFormField(
                          controller: _itemNameController,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter item name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter item name';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      _buildFormSection(
                        title: 'Description',
                        icon: Icons.description_rounded,
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _buildInputDecoration(
                            hintText: 'Describe what you need',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Image uploader
                      _buildFormSection(
                        title: 'Image (Optional)',
                        icon: Icons.image_rounded,
                        child: _buildImageUploadSection(),
                      ),

                      const SizedBox(height: 24),

                      // Amount
                      _buildFormSection(
                        title: 'Amount Needed',
                        icon: Icons.numbers_rounded,
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter amount needed',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Targeted date
                      _buildFormSection(
                        title: 'Targeted Date',
                        icon: Icons.calendar_today_rounded,
                        child: TextFormField(
                          controller: _targetedDateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration:
                              _buildInputDecoration(
                                hintText: 'Select targeted date',
                              ).copyWith(
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select targeted date';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit
                      GestureDetector(
                        onTap: _isLoading ? null : _submitProposal,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF667EEA),
                                const Color(0xFF764BA2),
                                const Color(0xFF06B6D4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
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
                                _isLoading ? 'Creating...' : 'Create Proposal',
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _targetedDateController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../Authentication/login.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  File? _imageFile;
  String? _profilePictureUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getProfile();
      if (mounted && result['success'] == true) {
        final data = result['data'];
        setState(() {
          _nameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _dobController.text = data['date_of_birth'] ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _profilePictureUrl = data['profile_picture_url'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.updateProfileWithImage(
        fullName: _nameController.text,
        email: _emailController.text,
        dob: _dobController.text,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        imagePath: _imageFile?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Profile updated successfully')),
        );
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkRed = Color(0xFF800B39);
    const Color bgColor = Color(0xFFFDF5F7);
    const Color softPink = Color(0xFFFDE6ED);
    const Color darkText = Color(0xFF2B0A16);
    const Color greyText = Color(0xFF8A606A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading && _nameController.text.isEmpty
            ? const Center(child: CircularProgressIndicator(color: primaryDarkRed))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Custom Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: darkText, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Edit Profile",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : _saveProfile,
                            child: Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isLoading ? greyText : primaryDarkRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Picture
                    const SizedBox(height: 10),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryDarkRed, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 68,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                                      ? NetworkImage(_profilePictureUrl!)
                                      : null) as ImageProvider?,
                              child: (_imageFile == null && (_profilePictureUrl == null || _profilePictureUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 80, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: primaryDarkRed, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: const Text(
                        "Change Photo",
                        style: TextStyle(color: primaryDarkRed, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Information Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.person_outline, color: darkText),
                              SizedBox(width: 10),
                              Text(
                                "Personal Information",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildInputField("FULL NAME", _nameController),
                          _buildInputField("EMAIL ADDRESS", _emailController),
                          _buildInputField("BIRTH OF DATE", _dobController, isDate: true),
                          Row(
                            children: [
                              Expanded(child: _buildInputField("HEIGHT (FEET)", _heightController, isDropdown: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInputField("WEIGHT (LBS)", _weightController, isDropdown: true)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.logout, color: primaryDarkRed, size: 28),
                              SizedBox(width: 20),
                              Text(
                                "Log Out",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isDate = false, bool isDropdown = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8A606A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: isDate ? "Month/Day/Year" : "",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2B0A16)),
                ),
              ),
              if (isDate) const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
              if (isDropdown) const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

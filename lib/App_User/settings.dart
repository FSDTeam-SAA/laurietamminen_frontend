import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Authentication/login.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);
  
  bool locationEnabled = true;
  Map<String, dynamic>? userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            userProfile = result['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      final result = await ApiService.logout();
      if (mounted) {
        if (result['success'] == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Logout failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: darkText, size: 28),
                      onPressed: () {},
                    ),
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: primaryDarkRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF0D5DD), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: userProfile?['profile_picture_url'] != null && userProfile?['profile_picture_url'] != ""
                                ? NetworkImage(userProfile!['profile_picture_url'])
                                : null,
                            child: userProfile?['profile_picture_url'] == null || userProfile?['profile_picture_url'] == ""
                                ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEEAEF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.verified, color: primaryDarkRed, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile?['full_name'] ?? "Laurie Schamber",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    Text(
                      userProfile?['email'] ?? "elena.vitality@wellness.com",
                      style: TextStyle(
                        fontSize: 16,
                        color: greyText,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Menu Items
              _buildMenuItem(
                icon: Icons.person_outline,
                title: "Personal Information",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                  _fetchProfile(); // Refresh on back
                },
                trailing: Icon(Icons.chevron_right, color: darkText),
              ),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: "Location Permissions",
                trailing: Switch(
                  value: locationEnabled,
                  onChanged: (val) => setState(() => locationEnabled = val),
                  activeColor: primaryDarkRed,
                  activeTrackColor: primaryDarkRed.withOpacity(0.5),
                ),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: "Our Privacy Policy",
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: "Log Out",
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBFC),
        border: Border(bottom: BorderSide(color: Color(0xFFF0D5DD), width: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEAEF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryDarkRed, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: darkText,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String? _profilePictureUrl;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (mounted && result['success'] == true) {
        final data = result['data'];
        setState(() {
          _fullNameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _dobController.text = data['date_of_birth']?.toString().split('T')[0] ?? '';
          
          // Convert CM to FT/IN
          if (data['height'] != null) {
            double cm = double.tryParse(data['height'].toString()) ?? 0;
            double totalInches = cm / 2.54;
            _heightFeetController.text = (totalInches / 12).floor().toString();
            _heightInchesController.text = (totalInches % 12).round().toString();
          }

          // Convert KG to LBS
          if (data['weight'] != null) {
            double kg = double.tryParse(data['weight'].toString()) ?? 0;
            _weightController.text = (kg * 2.20462).toStringAsFixed(1);
          }

          _profilePictureUrl = data['profile_picture_url'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      // Convert FT/IN back to CM
      int feet = int.tryParse(_heightFeetController.text) ?? 0;
      int inches = int.tryParse(_heightInchesController.text) ?? 0;
      double? heightCm = (feet > 0 || inches > 0) ? ((feet * 12) + inches) * 2.54 : null;

      // Convert LBS back to KG
      double lbs = double.tryParse(_weightController.text) ?? 0;
      double? weightKg = lbs > 0 ? lbs / 2.20462 : null;

      final result = await ApiService.updateProfileWithImage(
        fullName: _fullNameController.text,
        email: _emailController.text,
        dob: _dobController.text,
        height: heightCm,
        weight: weightKg,
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: darkText, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(
                        onPressed: _saveProfile,
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: primaryDarkRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Change Photo Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: darkText, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.black87,
                            backgroundImage: _selectedImage != null 
                              ? FileImage(_selectedImage!)
                              : (_profilePictureUrl != null && _profilePictureUrl != ""
                                  ? NetworkImage(_profilePictureUrl!)
                                  : null),
                            child: _selectedImage == null && (_profilePictureUrl == null || _profilePictureUrl == "")
                                ? const Icon(Icons.person, size: 45, color: Colors.white70)
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryDarkRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        "Change Photo",
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryDarkRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Form Fields
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add_alt_1_outlined, color: darkText, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(label: "FULL NAME", controller: _fullNameController),
                    const SizedBox(height: 16),
                    _buildTextField(label: "EMAIL ADDRESS", controller: _emailController),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "BIRTH OF DATE",
                      controller: _dobController,
                      suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey.shade400, size: 20),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(child: _buildTextField(label: "HEIGHT (FT)", controller: _heightFeetController, keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTextField(label: "IN", controller: _heightInchesController, keyboardType: TextInputType.number)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(label: "WEIGHT (LBS)", controller: _weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, Widget? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: darkText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF800B39)),
            ),
          ),
        ),
      ],
    );
  }
}

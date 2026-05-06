import 'package:flutter/material.dart';
import 'successfull_password.dart';
import '../services/api_service.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);
  final Color borderColor = const Color(0xFFE8C5D0);

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.resetPassword(
        email: widget.email,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SuccessfulPasswordScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Reset failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Something went wrong. Please try again.';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = 'The request timed out. The server might be slow, please try again.';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'No internet connection or server unreachable.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String hintText, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFA58B94)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: primaryDarkRed, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: primaryDarkRed),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.arrow_back_ios_new, color: primaryDarkRed, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(),
              const SizedBox(height: 60),
              Text(
                "Create new password",
                style: TextStyle(
                  color: darkText,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Your new password must be unique from those previously used.",
                style: TextStyle(
                  color: greyText,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField("New Password", _newPasswordController, isPassword: true),
              _buildTextField("Confirm password", _confirmPasswordController, isPassword: true),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'create_new_password.dart';
import '../services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color bgColor = const Color(0xFFFEEAEF);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);
  final Color borderColor = const Color(0xFFE8C5D0);

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.verifyOtp(widget.email, otp);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'OTP verified successfully')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewPasswordScreen(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Invalid OTP')),
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
        ),
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
                "OTP Verification",
                style: TextStyle(
                  color: darkText,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Enter the verification code we just send to your email address",
                style: TextStyle(
                  color: greyText,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpBox(0),
                  _buildOtpBox(1),
                  _buildOtpBox(2),
                  _buildOtpBox(3),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
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
                          "Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Resend logic could call forgotPassword again
                    ApiService.forgotPassword(widget.email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP resent')),
                    );
                  },
                  child: Text(
                    "Resend Code",
                    style: TextStyle(
                      color: primaryDarkRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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


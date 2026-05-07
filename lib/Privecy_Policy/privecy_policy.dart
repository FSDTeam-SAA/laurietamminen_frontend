import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: darkText, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B0A16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the back button
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Privacy Policy – SolidSteps App",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Effective Date: April 25, 2025",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: greyText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildParagraph(
                        "SolidSteps App (\"SolidSteps,\" \"we,\" \"our,\" or \"the App\") respects your privacy. This Privacy Policy explains what information we collect, how we use it, when location information may be accessed, and how information is handled when you use the app."
                      ),
                      
                      _buildSectionTitle("1. Information We Collect"),
                      _buildParagraph("Depending on how the app is used, SolidSteps may collect the following information:"),
                      
                      _buildSubSectionTitle("A. Information you provide directly"),
                      _buildBulletPoint("name"),
                      _buildBulletPoint("email address"),
                      _buildBulletPoint("password or login credentials"),
                      _buildBulletPoint("profile details you choose to enter, such as step goals or account settings"),
                      _buildBulletPoint("manually entered daily step counts"),
                      _buildBulletPoint("messages or information you choose to submit through app features"),
                      
                      _buildSubSectionTitle("B. Device and app information"),
                      _buildParagraph("We may collect limited technical information needed to operate, secure, and improve the app, such as:"),
                      _buildBulletPoint("device type"),
                      _buildBulletPoint("operating system"),
                      _buildBulletPoint("app version"),
                      _buildBulletPoint("basic diagnostic or error information"),
                      
                      _buildSubSectionTitle("C. Location Information"),
                      _buildParagraph("SolidSteps may request access to your device's location. Location is only accessed:"),
                      _buildBulletPoint("with your permission"),
                      _buildBulletPoint("when location sharing is turned on by the user"),
                      _buildBulletPoint("and only when the user initiates a feature or action that requires location information"),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        "SolidSteps does not use continuous background location tracking during ordinary app use. Location is not used for advertising, profiling, or marketing. When enabled, location information is only used to support the specific in-app function the user has chosen to use."
                      ),
                      
                      _buildSectionTitle("2. How Information Is Used"),
                      _buildParagraph("We use information only as reasonably necessary to operate the app and provide app-related features, including to:"),
                      _buildBulletPoint("create and manage user accounts"),
                      _buildBulletPoint("allow users to log in securely"),
                      _buildBulletPoint("record daily step entries"),
                      _buildBulletPoint("calculate total, trends and progress toward goals"),
                      _buildBulletPoint("provide app features requested by the user"),
                      _buildBulletPoint("support optional location-enabled functions initiated by the user"),
                      _buildBulletPoint("maintain app security, troubleshoot issues, and improve reliability"),
                      _buildBulletPoint("respond to support requests or user communications"),
                      const SizedBox(height: 8),
                      _buildParagraph("We do not use personal information for targeted advertising."),
                      
                      _buildSectionTitle("3. Location Sharing Features"),
                      _buildParagraph("Some optional features of SolidSteps may allow users to share location information through user-controlled app functions."),
                      _buildParagraph("These features are:"),
                      _buildBulletPoint("optional"),
                      _buildBulletPoint("permission-based"),
                      _buildBulletPoint("controlled by the user"),
                      _buildBulletPoint("activated only when the user turns location sharing on and uses the related feature"),
                      const SizedBox(height: 8),
                      _buildParagraph("Location information is only processed or shared when needed to carry out that user-initiated function."),
                      
                      _buildSectionTitle("4. Data Sharing"),
                      _buildParagraph("We do not sell or rent personal information."),
                      _buildParagraph("We only share information in the following limited circumstances:"),
                      _buildBulletPoint("with service providers that help us operate the app or its secure backend"),
                      _buildBulletPoint("when a user chooses to use a feature that sends information to a designated recipient"),
                      _buildBulletPoint("when required by law, court order, or to protect safety, rights, or security"),
                      const SizedBox(height: 8),
                      _buildParagraph("Any sharing is limited to what is reasonably necessary for the purpose involved."),
                      
                      _buildSectionTitle("5. Data Storage"),
                      _buildParagraph("Information may be stored:"),
                      _buildBulletPoint("locally on the user's device"),
                      _buildBulletPoint("on secure backend systems used to operate app accounts and approved features"),
                      const SizedBox(height: 8),
                      _buildParagraph("The type of storage depends on the feature being used. Some information may remain on the device while account settings, support or location-enabled feature information may be stored securely on our systems."),
                      
                      _buildSectionTitle("6. Data Retention"),
                      _buildParagraph("We keep information only for as long as reasonably necessary to:"),
                      _buildBulletPoint("provide the app and its features"),
                      _buildBulletPoint("maintain security and account integrity"),
                      _buildBulletPoint("comply with legal obligations"),
                      _buildBulletPoint("resolve disputes or enforce our terms"),
                      const SizedBox(height: 8),
                      _buildParagraph("When information is no longer needed, we take reasonable steps to delete or de-identify it."),
                      
                      _buildSectionTitle("7. User Choices"),
                      _buildParagraph("You may be able to:"),
                      _buildBulletPoint("update account or profile information in the app"),
                      _buildBulletPoint("disable location permissions in your device settings"),
                      _buildBulletPoint("stop using optional location-based features at any time"),
                      _buildBulletPoint("request deletion of your account or associated information by contacting us"),
                      const SizedBox(height: 8),
                      _buildParagraph("Disabling location permissions may prevent certain app features from functioning."),
                      
                      _buildSectionTitle("8. Security"),
                      _buildParagraph("We use reasonable administrative, technical, and organizational safeguards to protect information. However, no app, device, transmission method, or storage system can be guaranteed to be completely secure."),
                      
                      _buildSectionTitle("9. Children's Privacy"),
                      _buildParagraph("SolidSteps is not directed to children under 13, and we do not knowingly collect personal information from children under 13 without appropriate authorization. If we learn that such information has been collected inappropriately, we will take reasonable steps to delete it."),
                      
                      _buildSectionTitle("10. Changes to This Policy"),
                      _buildParagraph("We may update this Privacy Policy from time to time. If we make material changes, we will update the effective date above and may provide additional notice where appropriate. Continued use of the app after an update means the updated policy will apply."),
                      
                      _buildSectionTitle("11. Contact Us"),
                      _buildParagraph("If you have questions about this Privacy Policy or wish to request account or data deletion, contact:"),
                      Text(
                        "customerservice@solidstepsapp.com",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkRed,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Copyright @ 2024 SolidSteps App",
                          style: TextStyle(
                            fontSize: 12,
                            color: greyText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkText.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: darkText.withOpacity(0.9),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 15, color: primaryDarkRed, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: darkText.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

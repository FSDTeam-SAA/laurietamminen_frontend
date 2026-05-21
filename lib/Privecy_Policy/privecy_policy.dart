import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with TickerProviderStateMixin {
  final Color primaryDarkRed = const Color(0xFF800B39);
  final Color darkText = const Color(0xFF2B0A16);
  final Color greyText = const Color(0xFF8A606A);

  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _shimmerAnim;
  late Animation<double> _pulseAnim;

  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      _contentController.forward();
    });

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEAEF),
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeader(),
              ),
            ),

            // Scroll Progress Bar
            AnimatedBuilder(
              animation: _scrollController.hasClients
                  ? _scrollController
                  : const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDD0D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _scrollProgress,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryDarkRed, const Color(0xFFD4256A)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryDarkRed.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 6),

            // Animated Content Card
            Expanded(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryDarkRed.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerTitle(),
                            const SizedBox(height: 8),
                            _buildEffectiveDateBadge(),
                            const SizedBox(height: 20),
                            _buildAnimatedParagraph(
                              "SolidSteps App (“SolidSteps,” “we,” “our,” or “the app”) respects your privacy. This Privacy Policy explains what information we collect, how we use it, when location information may be accessed, how information may be processed through our secure backend and administrator dashboard, and how users may request access, correction, or deletion of their information.",
                              delay: 0,
                            ),
                            _buildAnimatedParagraph(
                              "This Privacy Policy applies to the SolidSteps mobile app, related backend systems, support services, and any secure administrator dashboard or web-based management system used to operate, maintain, review, support, or respond to app-related features. This may include systems hosted on solidstepsapp.com or a related subdomain, such as an administrative subdomain used by authorized personnel.",
                              delay: 30,
                            ),

                            _buildAnimatedSectionTitle(
                              "1. Information We Collect",
                              delay: 60,
                            ),
                            _buildAnimatedParagraph(
                              "Depending on how the app is used, SolidSteps may collect the following information.",
                              delay: 90,
                            ),

                            _buildSubSectionTitle(
                              "A. Information Provided by the User",
                            ),
                            _buildAnimatedParagraph(
                              "We may collect information that a user chooses to provide, including:",
                              delay: 120,
                            ),
                            _buildAnimatedBullet("name;", delay: 150),
                            _buildAnimatedBullet("email address;", delay: 180),
                            _buildAnimatedBullet("password or login credentials;", delay: 210),
                            _buildAnimatedBullet("account registration details;", delay: 240),
                            _buildAnimatedBullet("profile details the user chooses to enter, such as step goals or account settings;", delay: 270),
                            _buildAnimatedBullet("manually entered daily step counts;", delay: 300),
                            _buildAnimatedBullet("messages, requests, or information the user chooses to submit through app features;", delay: 330),
                            _buildAnimatedBullet("support requests or communications the user sends to us.", delay: 360),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Basic step-tracking features are available to users without separate registration with On Solid Ground Hub.",
                              delay: 390,
                            ),

                            _buildSubSectionTitle(
                              "B. Device and App Information",
                            ),
                            _buildAnimatedParagraph(
                              "We may collect limited technical information needed to operate, secure, troubleshoot, and improve the app, including:",
                              delay: 420,
                            ),
                            _buildAnimatedBullet("device type;", delay: 450),
                            _buildAnimatedBullet("operating system;", delay: 480),
                            _buildAnimatedBullet("app version;", delay: 510),
                            _buildAnimatedBullet("basic diagnostic or error information;", delay: 540),
                            _buildAnimatedBullet("security, login, or authentication-related information;", delay: 570),
                            _buildAnimatedBullet("technical logs needed to maintain app reliability and protect against misuse.", delay: 600),

                            _buildSubSectionTitle("C. Location Information"),
                            _buildAnimatedParagraph(
                              "SolidSteps may request access to a user’s device location.",
                              delay: 630,
                            ),
                            _buildAnimatedParagraph(
                              "Location information is not used for ordinary step-tracking features.",
                              delay: 660,
                            ),
                            _buildAnimatedParagraph(
                              "Location information may only be collected, used, processed, or shared where:",
                              delay: 690,
                            ),
                            _buildAnimatedBullet("the user has enabled or granted location permission;", delay: 720),
                            _buildAnimatedBullet("the information is connected to an approved account-based or client-related feature;", delay: 750),
                            _buildAnimatedBullet("the information is reasonably necessary to support that feature;", delay: 780),
                            _buildAnimatedBullet("and the feature is activated or used by the user.", delay: 810),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Users can decline location permission. If location permission is declined, ordinary step-tracking features are not affected. However, certain approved account-based or client-related features may not include location information or may not function fully without location permission.",
                              delay: 840,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps does not use continuous background location tracking for ordinary step-tracking use.",
                              delay: 870,
                            ),
                            _buildAnimatedParagraph(
                              "Location information is not used for advertising, profiling, or marketing.",
                              delay: 900,
                            ),

                            _buildAnimatedSectionTitle(
                              "2. Users Registered with On Solid Ground Hub",
                              delay: 930,
                            ),
                            _buildAnimatedParagraph(
                              "Some users may separately register as clients with On Solid Ground Hub in order to access additional support, services, or approved app-related features.",
                              delay: 960,
                            ),
                            _buildAnimatedParagraph(
                              "Registration with On Solid Ground Hub is separate from creating a basic SolidSteps app account. A user who registers with On Solid Ground Hub may be asked to provide additional information directly to On Solid Ground Hub through an express registration, intake, consent, or permission process.",
                              delay: 990,
                            ),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, additional information may be collected and retained only where reasonably necessary to provide, verify, support, or administer client-related services or approved app-related features. This may include:",
                              delay: 1020,
                            ),
                            _buildAnimatedBullet("client registration details;", delay: 1050),
                            _buildAnimatedBullet("contact information;", delay: 1080),
                            _buildAnimatedBullet("information needed to verify client status;", delay: 1110),
                            _buildAnimatedBullet("information connected to approved client-related features;", delay: 1140),
                            _buildAnimatedBullet("designated contact or recipient information, if provided;", delay: 1170),
                            _buildAnimatedBullet("permission-based location information, where applicable;", delay: 1200),
                            _buildAnimatedBullet("records needed to operate, verify, support, or respond to client-related app functions.", delay: 1230),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "This additional information is not collected from all users. It applies only to users who are registered clients of On Solid Ground Hub and who have provided the required information, consent, or permissions through On Solid Ground Hub.",
                              delay: 1260,
                            ),

                            _buildAnimatedSectionTitle(
                              "3. How Information Is Used",
                              delay: 1290,
                            ),
                            _buildAnimatedParagraph(
                              "We use information only as reasonably necessary to operate, secure, maintain, and improve the app and related systems.",
                              delay: 1320,
                            ),
                            _buildAnimatedParagraph(
                              "This may include using information to:",
                              delay: 1350,
                            ),
                            _buildAnimatedBullet("create and manage user accounts;", delay: 1380),
                            _buildAnimatedBullet("allow users to log in securely;", delay: 1410),
                            _buildAnimatedBullet("authenticate account access;", delay: 1440),
                            _buildAnimatedBullet("record daily step entries;", delay: 1470),
                            _buildAnimatedBullet("calculate totals, trends, and progress toward goals;", delay: 1500),
                            _buildAnimatedBullet("provide basic app features requested by the user;", delay: 1530),
                            _buildAnimatedBullet("operate and maintain secure backend systems;", delay: 1560),
                            _buildAnimatedBullet("maintain app security and account integrity;", delay: 1590),
                            _buildAnimatedBullet("troubleshoot issues and improve reliability;", delay: 1620),
                            _buildAnimatedBullet("respond to support requests or user communications;", delay: 1650),
                            _buildAnimatedBullet("comply with legal obligations;", delay: 1680),
                            _buildAnimatedBullet("protect the rights, security, or integrity of users, the app, our systems, or others.", delay: 1710),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, information may also be used to:",
                              delay: 1740,
                            ),
                            _buildAnimatedBullet("verify registered client status;", delay: 1770),
                            _buildAnimatedBullet("support approved account-based or client-related app features;", delay: 1800),
                            _buildAnimatedBullet("display relevant information to authorized administrators through a secure dashboard;", delay: 1830),
                            _buildAnimatedBullet("review, verify, or respond to client-related app actions where required;", delay: 1860),
                            _buildAnimatedBullet("manage client-related records necessary to provide or support approved services or features.", delay: 1890),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "We do not use personal information for targeted advertising.",
                              delay: 1920,
                            ),

                            _buildAnimatedSectionTitle(
                              "4. Secure Backend and Administrator Dashboard",
                              delay: 1950,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps may use secure backend systems and an administrator dashboard to operate and support the app. This dashboard may be hosted on solidstepsapp.com or a related subdomain, including an administrative subdomain.",
                              delay: 1980,
                            ),
                            _buildAnimatedParagraph(
                              "The administrator dashboard is not a public-facing user feature. It is intended for authorized administrative access only.",
                              delay: 2010,
                            ),
                            _buildAnimatedParagraph(
                              "For users of the app, the backend may retain basic account, login, app setting, step-entry, diagnostic, and support-related information needed to operate the app.",
                              delay: 2040,
                            ),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, additional client-related information may be retained in secure backend systems or displayed in the administrator dashboard only where reasonably necessary to verify client status, support approved account-based or client-related features, manage client-related records, or respond to client-related app functions.",
                              delay: 2070,
                            ),
                            _buildAnimatedParagraph(
                              "The administrator dashboard may be used to:",
                              delay: 2100,
                            ),
                            _buildAnimatedBullet("manage app-related user accounts;", delay: 2130),
                            _buildAnimatedBullet("support account administration;", delay: 2160),
                            _buildAnimatedBullet("verify registered client status, where applicable;", delay: 2190),
                            _buildAnimatedBullet("manage client-related records for users registered with On Solid Ground Hub;", delay: 2220),
                            _buildAnimatedBullet("manage technical, support, or security issues;", delay: 2250),
                            _buildAnimatedBullet("monitor system reliability and security;", delay: 2280),
                            _buildAnimatedBullet("maintain records needed to operate the app and related systems.", delay: 2310),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Only authorized personnel or approved service providers may access the administrator dashboard. Access is limited to individuals who require it for operational, technical, support, administrative, or client-service purposes.",
                              delay: 2340,
                            ),
                            _buildAnimatedParagraph(
                              "Information available through the administrator dashboard will be limited to what is reasonably necessary for the purpose of operating, supporting, securing, or administering the app and related services.",
                              delay: 2370,
                            ),

                            _buildAnimatedSectionTitle(
                              "5. Account-Based and Client-Related App Features",
                              delay: 2400,
                            ),
                            _buildAnimatedParagraph(
                              "Users who are registered clients of On Solid Ground Hub may be able to access additional approved account-based or client-related app features.",
                              delay: 2430,
                            ),
                            _buildAnimatedParagraph(
                              "These features may be:",
                              delay: 2460,
                            ),
                            _buildAnimatedBullet("limited to users registered as clients with On Solid Ground Hub;", delay: 2490),
                            _buildAnimatedBullet("permission-based where required;", delay: 2520),
                            _buildAnimatedBullet("controlled by the user where applicable;", delay: 2550),
                            _buildAnimatedBullet("activated only when the user chooses to use a related feature.", delay: 2580),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Information connected to these features is only processed, stored, displayed, or shared where reasonably necessary to support the approved account-based or client-related function.",
                              delay: 2610,
                            ),
                            _buildAnimatedParagraph(
                              "Depending on the feature, information may be transmitted to secure backend systems or displayed in the administrator dashboard for the limited purpose of supporting or responding to that user-initiated feature.",
                              delay: 2640,
                            ),

                            _buildAnimatedSectionTitle(
                              "6. Data Sharing",
                              delay: 2670,
                            ),
                            _buildAnimatedParagraph(
                              "We do not sell or rent personal information.",
                              delay: 2700,
                            ),
                            _buildAnimatedParagraph(
                              "We only share information in limited circumstances, including:",
                              delay: 2730,
                            ),
                            _buildAnimatedBullet("with service providers that help us operate the app, backend systems, administrator dashboard, hosting, authentication, communications, security, or technical infrastructure;", delay: 2760),
                            _buildAnimatedBullet("where information must be processed through our secure backend to operate the app or support approved features;", delay: 2790),
                            _buildAnimatedBullet("where required by law, court order, subpoena, warrant, or legal process;", delay: 2820),
                            _buildAnimatedBullet("where reasonably necessary to protect rights, security, system integrity, or prevent misuse.", delay: 2850),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, information may also be shared with a designated recipient only where the user has provided the required information, consent, or permission through On Solid Ground Hub or through an approved account-based or client-related app feature.",
                              delay: 2880,
                            ),
                            _buildAnimatedParagraph(
                              "Any sharing is limited to what is reasonably necessary for the purpose involved.",
                              delay: 2910,
                            ),
                            _buildAnimatedParagraph(
                              "Where third-party service providers process information on our behalf, we expect them to protect user information and use it only for the services they provide to us.",
                              delay: 2940,
                            ),

                            _buildAnimatedSectionTitle(
                              "7. Data Storage",
                              delay: 2970,
                            ),
                            _buildAnimatedParagraph(
                              "Information may be stored:",
                              delay: 3000,
                            ),
                            _buildAnimatedBullet("locally on the user’s device;", delay: 3030),
                            _buildAnimatedBullet("on secure backend systems used to operate app accounts and approved features;", delay: 3060),
                            _buildAnimatedBullet("in secure systems connected to the administrator dashboard;", delay: 3090),
                            _buildAnimatedBullet("with trusted service providers that support app hosting, authentication, infrastructure, communications, security, or technical operations.", delay: 3120),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "The type of storage depends on the feature being used.",
                              delay: 3150,
                            ),
                            _buildAnimatedParagraph(
                              "For users of the app, stored information may include basic account information, login credentials, app settings, step entries, diagnostic information, and support communications, where applicable.",
                              delay: 3180,
                            ),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, additional client-related information may be stored securely where needed to provide client services, operate approved account-based or client-related features, maintain security, or respond to user-initiated app functions.",
                              delay: 3210,
                            ),

                            _buildAnimatedSectionTitle(
                              "8. Data Retention",
                              delay: 3240,
                            ),
                            _buildAnimatedParagraph(
                              "We keep information only for as long as reasonably necessary for the purpose for which it was collected.",
                              delay: 3270,
                            ),
                            _buildAnimatedParagraph(
                              "For users of the app, retained information may include basic account information, login credentials, app settings, manually entered step data, diagnostic information, and support communications, where applicable.",
                              delay: 3300,
                            ),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, we may retain additional client-related information for as long as reasonably necessary to provide client services, operate approved account-based or client-related features, maintain security, comply with legal obligations, resolve disputes, or protect system integrity.",
                              delay: 3330,
                            ),
                            _buildAnimatedParagraph(
                              "Additional client-related information is not retained for all users. It is only retained for users who are registered clients of On Solid Ground Hub and have provided the required information, consent, or permissions through On Solid Ground Hub.",
                              delay: 3360,
                            ),
                            _buildAnimatedParagraph(
                              "When information is no longer needed, we take reasonable steps to delete, de-identify, or securely dispose of it.",
                              delay: 3390,
                            ),
                            _buildAnimatedParagraph(
                              "Certain technical logs, account records, support records, or client-related records may be retained for a reasonable period where necessary for security, legal, operational, or system integrity reasons.",
                              delay: 3420,
                            ),

                            _buildAnimatedSectionTitle(
                              "9. User Choices",
                              delay: 3450,
                            ),
                            _buildAnimatedParagraph(
                              "Users may be able to:",
                              delay: 3480,
                            ),
                            _buildAnimatedBullet("update account or profile information in the app;", delay: 3510),
                            _buildAnimatedBullet("disable location permissions in device settings;", delay: 3540),
                            _buildAnimatedBullet("stop using optional permission-based features at any time;", delay: 3570),
                            _buildAnimatedBullet("stop using the app;", delay: 3600),
                            _buildAnimatedBullet("request deletion of their account or associated information;", delay: 3630),
                            _buildAnimatedBullet("contact us with privacy questions or concerns.", delay: 3660),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Disabling permissions may prevent certain approved account-based or client-related features from functioning.",
                              delay: 3690,
                            ),
                            _buildAnimatedParagraph(
                              "Users can request account or data deletion by contacting:\ncustomerservice@solidstepsapp.com",
                              delay: 3720,
                            ),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "We may need to verify the user’s identity before processing certain requests.",
                              delay: 3750,
                            ),

                            _buildAnimatedSectionTitle(
                              "10. Account and Data Deletion Requests",
                              delay: 3780,
                            ),
                            _buildAnimatedParagraph(
                              "Users may request deletion of their account and associated personal information by contacting us at:\ncustomerservice@solidstepsapp.com",
                              delay: 3810,
                            ),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "After receiving a deletion request, we will take reasonable steps to delete or de-identify personal information associated with the account, unless we are required or permitted to retain certain information for legal, security, fraud prevention, dispute resolution, or operational reasons.",
                              delay: 3840,
                            ),
                            _buildAnimatedParagraph(
                              "For users of the app, this may include deletion or de-identification of basic account information, profile information, step entries, and app-related data associated with the account.",
                              delay: 3870,
                            ),
                            _buildAnimatedParagraph(
                              "For users who are registered clients of On Solid Ground Hub, deletion requests may also involve client-related records, subject to any legal, security, or operational retention requirements.",
                              delay: 3900,
                            ),
                            _buildAnimatedParagraph(
                              "Some information may remain in backup systems or technical logs for a limited period before being deleted according to our normal retention practices.",
                              delay: 3930,
                            ),

                            _buildAnimatedSectionTitle(
                              "11. Security",
                              delay: 3960,
                            ),
                            _buildAnimatedParagraph(
                              "We use reasonable administrative, technical, and organizational safeguards to protect information from unauthorized access, use, disclosure, alteration, loss, or theft.",
                              delay: 3990,
                            ),
                            _buildAnimatedParagraph(
                              "Safeguards may include:",
                              delay: 4020,
                            ),
                            _buildAnimatedBullet("secure backend infrastructure;", delay: 4050),
                            _buildAnimatedBullet("restricted administrator dashboard access;", delay: 4080),
                            _buildAnimatedBullet("account authentication;", delay: 4110),
                            _buildAnimatedBullet("password-protected systems;", delay: 4140),
                            _buildAnimatedBullet("access controls for authorized personnel;", delay: 4170),
                            _buildAnimatedBullet("limited access based on role or operational need;", delay: 4200),
                            _buildAnimatedBullet("monitoring for security and reliability;", delay: 4230),
                            _buildAnimatedBullet("use of trusted service providers;", delay: 4260),
                            _buildAnimatedBullet("encryption or secure transmission where appropriate.", delay: 4290),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "No app, device, transmission method, website, backend system, dashboard, or storage system can be guaranteed to be completely secure.",
                              delay: 4320,
                            ),

                            _buildAnimatedSectionTitle(
                              "12. Children’s Privacy",
                              delay: 4350,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps is not directed to children under 13, and we do not knowingly collect personal information from children under 13 without appropriate authorization.",
                              delay: 4380,
                            ),
                            _buildAnimatedParagraph(
                              "If we learn that personal information from a child under 13 has been collected inappropriately, we will take reasonable steps to delete it, unless we are legally required or permitted to retain it for legal, security, or protection-related reasons.",
                              delay: 4410,
                            ),

                            _buildAnimatedSectionTitle(
                              "13. Third-Party Services",
                              delay: 4440,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps may rely on third-party service providers to operate the app and related systems. These may include providers for:",
                              delay: 4470,
                            ),
                            _buildAnimatedBullet("app hosting;", delay: 4500),
                            _buildAnimatedBullet("backend infrastructure;", delay: 4530),
                            _buildAnimatedBullet("authentication;", delay: 4560),
                            _buildAnimatedBullet("cloud storage;", delay: 4590),
                            _buildAnimatedBullet("communications;", delay: 4620),
                            _buildAnimatedBullet("error logging;", delay: 4650),
                            _buildAnimatedBullet("analytics or diagnostics;", delay: 4680),
                            _buildAnimatedBullet("security;", delay: 4710),
                            _buildAnimatedBullet("support services.", delay: 4740),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "These providers may process limited information on our behalf only as needed to provide their services. We do not authorize service providers to sell user information or use it for their own advertising purposes.",
                              delay: 4770,
                            ),

                            _buildAnimatedSectionTitle(
                              "14. No Targeted Advertising or Sale of Data",
                              delay: 4800,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps does not sell personal information.",
                              delay: 4830,
                            ),
                            _buildAnimatedParagraph(
                              "SolidSteps does not use personal information, step entries, location information, or client-related information for targeted advertising.",
                              delay: 4860,
                            ),

                            _buildAnimatedSectionTitle(
                              "15. Legal or Required Disclosure",
                              delay: 4890,
                            ),
                            _buildAnimatedParagraph(
                              "In limited circumstances, we may use or disclose information where permitted or required by law, including where reasonably necessary to:",
                              delay: 4920,
                            ),
                            _buildAnimatedBullet("comply with a legal obligation;", delay: 4950),
                            _buildAnimatedBullet("respond to a court order, subpoena, warrant, or lawful request;", delay: 4980),
                            _buildAnimatedBullet("protect the rights, security, or integrity of users or others;", delay: 5010),
                            _buildAnimatedBullet("investigate misuse, fraud, security issues, or unauthorized access;", delay: 5040),
                            _buildAnimatedBullet("protect the operation and integrity of the app, backend systems, or administrator dashboard.", delay: 5070),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                              "Where possible and appropriate, we will limit disclosure to the information reasonably necessary in the circumstances.",
                              delay: 5100,
                            ),

                            _buildAnimatedSectionTitle(
                              "16. Relationship with On Solid Ground Hub",
                              delay: 5130,
                            ),
                            _buildAnimatedParagraph(
                              "On Solid Ground Hub may provide separate client registration, intake, consent, or permission processes for users who are approved to access additional account-based or client-related services or app features.",
                              delay: 5160,
                            ),
                            _buildAnimatedParagraph(
                              "Registering as a client with On Solid Ground Hub is separate from creating a basic SolidSteps app account. Users can use basic step-tracking features without registering as clients with On Solid Ground Hub.",
                              delay: 5190,
                            ),
                            _buildAnimatedParagraph(
                              "Where a user is registered as a client with On Solid Ground Hub, SolidSteps may use secure backend systems and the administrator dashboard to verify client status, support approved features, and manage records necessary for those services.",
                              delay: 5220,
                            ),
                            _buildAnimatedParagraph(
                              "Only client-related information reasonably necessary for those purposes will be collected, stored, or accessed.",
                              delay: 5250,
                            ),

                            _buildAnimatedSectionTitle(
                              "17. Changes to This Policy",
                              delay: 5280,
                            ),
                            _buildAnimatedParagraph(
                              "We may update this Privacy Policy from time to time.",
                              delay: 5310,
                            ),
                            _buildAnimatedParagraph(
                              "If we make material changes, we will update the effective date above and may provide additional notice where appropriate.",
                              delay: 5340,
                            ),
                            _buildAnimatedParagraph(
                              "Continued use of the app after an update means the updated policy will apply.",
                              delay: 5370,
                            ),

                            _buildAnimatedSectionTitle(
                              "18. Contact Us",
                              delay: 5400,
                            ),
                            _buildAnimatedParagraph(
                              "If you have questions about this Privacy Policy, the app, backend processing, the administrator dashboard, or if you want to request account or data deletion, contact:",
                              delay: 5430,
                            ),

                            _buildAnimatedContactEmail(),

                            const SizedBox(height: 40),
                            _buildFooter(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          _AnimatedIconButton(
            icon: Icons.arrow_back_ios,
            color: darkText,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Privacy Policy",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryDarkRed, const Color(0xFFD4256A), primaryDarkRed],
              stops: [
                (_shimmerAnim.value - 1).clamp(0.0, 1.0),
                _shimmerAnim.value.clamp(0.0, 1.0),
                (_shimmerAnim.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: Text(
            "Privacy Policy – SolidSteps App",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEffectiveDateBadge() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnim.value,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryDarkRed.withOpacity(0.12),
                  const Color(0xFFD4256A).withOpacity(0.07),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryDarkRed.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: primaryDarkRed,
                ),
                const SizedBox(width: 6),
                Text(
                  "Effective Date: May 16, 2026",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryDarkRed,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSectionTitle(String title, {int delay = 0}) {
    return _FadeSlideIn(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryDarkRed, const Color(0xFFD4256A)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
          ],
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

  Widget _buildAnimatedParagraph(String text, {int delay = 0}) {
    return _FadeSlideIn(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: darkText.withOpacity(0.9),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBullet(String text, {int delay = 0}) {
    return _FadeSlideIn(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFD4256A), primaryDarkRed],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDarkRed.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
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
      ),
    );
  }

  Widget _buildAnimatedContactEmail() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 1020),
      child: _AnimatedEmailTile(
        email: "customerservice@solidstepsapp.com",
        color: primaryDarkRed,
      ),
    );
  }

  Widget _buildFooter() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 1050),
      child: Center(
        child: Text(
          "Copyright © 2026 SolidSteps App",
          style: TextStyle(fontSize: 12, color: greyText),
        ),
      ),
    );
  }
}

// ─── Reusable Animated Widgets ───────────────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: widget.color, size: 20),
        ),
      ),
    );
  }
}

class _AnimatedEmailTile extends StatefulWidget {
  final String email;
  final Color color;

  const _AnimatedEmailTile({required this.email, required this.color});

  @override
  State<_AnimatedEmailTile> createState() => _AnimatedEmailTileState();
}

class _AnimatedEmailTileState extends State<_AnimatedEmailTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.03,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      onTapCancel: () {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [
                      widget.color.withOpacity(0.15),
                      widget.color.withOpacity(0.08),
                    ]
                  : [
                      widget.color.withOpacity(0.08),
                      widget.color.withOpacity(0.04),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(_hovered ? 0.5 : 0.2),
              width: 1.2,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 16, color: widget.color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

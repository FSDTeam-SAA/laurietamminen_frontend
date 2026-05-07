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

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

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
                          colors: [
                            primaryDarkRed,
                            const Color(0xFFD4256A),
                          ],
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
                              "SolidSteps App (\"SolidSteps,\" \"we,\" \"our,\" or \"the App\") respects your privacy. This Privacy Policy explains what information we collect, how we use it, when location information may be accessed, and how information is handled when you use the app.",
                              delay: 0,
                            ),

                            _buildAnimatedSectionTitle("1. Information We Collect", delay: 50),
                            _buildAnimatedParagraph(
                                "Depending on how the app is used, SolidSteps may collect the following information:",
                                delay: 80),

                            _buildSubSectionTitle("A. Information you provide directly"),
                            _buildAnimatedBullet("name", delay: 100),
                            _buildAnimatedBullet("email address", delay: 130),
                            _buildAnimatedBullet("password or login credentials", delay: 160),
                            _buildAnimatedBullet(
                                "profile details you choose to enter, such as step goals or account settings",
                                delay: 190),
                            _buildAnimatedBullet("manually entered daily step counts", delay: 220),
                            _buildAnimatedBullet(
                                "messages or information you choose to submit through app features",
                                delay: 250),

                            _buildSubSectionTitle("B. Device and app information"),
                            _buildAnimatedParagraph(
                                "We may collect limited technical information needed to operate, secure, and improve the app, such as:",
                                delay: 280),
                            _buildAnimatedBullet("device type", delay: 300),
                            _buildAnimatedBullet("operating system", delay: 320),
                            _buildAnimatedBullet("app version", delay: 340),
                            _buildAnimatedBullet("basic diagnostic or error information", delay: 360),

                            _buildSubSectionTitle("C. Location Information"),
                            _buildAnimatedParagraph(
                                "SolidSteps may request access to your device's location. Location is only accessed:",
                                delay: 380),
                            _buildAnimatedBullet("with your permission", delay: 400),
                            _buildAnimatedBullet("when location sharing is turned on by the user", delay: 420),
                            _buildAnimatedBullet(
                                "and only when the user initiates a feature or action that requires location information",
                                delay: 440),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "SolidSteps does not use continuous background location tracking during ordinary app use. Location is not used for advertising, profiling, or marketing. When enabled, location information is only used to support the specific in-app function the user has chosen to use.",
                                delay: 460),

                            _buildAnimatedSectionTitle("2. How Information Is Used", delay: 480),
                            _buildAnimatedParagraph(
                                "We use information only as reasonably necessary to operate the app and provide app-related features, including to:",
                                delay: 500),
                            _buildAnimatedBullet("create and manage user accounts", delay: 510),
                            _buildAnimatedBullet("allow users to log in securely", delay: 520),
                            _buildAnimatedBullet("record daily step entries", delay: 530),
                            _buildAnimatedBullet("calculate total, trends and progress toward goals", delay: 540),
                            _buildAnimatedBullet("provide app features requested by the user", delay: 550),
                            _buildAnimatedBullet(
                                "support optional location-enabled functions initiated by the user",
                                delay: 560),
                            _buildAnimatedBullet(
                                "maintain app security, troubleshoot issues, and improve reliability",
                                delay: 570),
                            _buildAnimatedBullet(
                                "respond to support requests or user communications",
                                delay: 580),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "We do not use personal information for targeted advertising.",
                                delay: 590),

                            _buildAnimatedSectionTitle("3. Location Sharing Features", delay: 600),
                            _buildAnimatedParagraph(
                                "Some optional features of SolidSteps may allow users to share location information through user-controlled app functions.",
                                delay: 610),
                            _buildAnimatedParagraph("These features are:", delay: 620),
                            _buildAnimatedBullet("optional", delay: 630),
                            _buildAnimatedBullet("permission-based", delay: 640),
                            _buildAnimatedBullet("controlled by the user", delay: 650),
                            _buildAnimatedBullet(
                                "activated only when the user turns location sharing on and uses the related feature",
                                delay: 660),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "Location information is only processed or shared when needed to carry out that user-initiated function.",
                                delay: 670),

                            _buildAnimatedSectionTitle("4. Data Sharing", delay: 680),
                            _buildAnimatedParagraph(
                                "We do not sell or rent personal information.",
                                delay: 690),
                            _buildAnimatedParagraph(
                                "We only share information in the following limited circumstances:",
                                delay: 700),
                            _buildAnimatedBullet(
                                "with service providers that help us operate the app or its secure backend",
                                delay: 710),
                            _buildAnimatedBullet(
                                "when a user chooses to use a feature that sends information to a designated recipient",
                                delay: 720),
                            _buildAnimatedBullet(
                                "when required by law, court order, or to protect safety, rights, or security",
                                delay: 730),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "Any sharing is limited to what is reasonably necessary for the purpose involved.",
                                delay: 740),

                            _buildAnimatedSectionTitle("5. Data Storage", delay: 750),
                            _buildAnimatedParagraph("Information may be stored:", delay: 760),
                            _buildAnimatedBullet("locally on the user's device", delay: 770),
                            _buildAnimatedBullet(
                                "on secure backend systems used to operate app accounts and approved features",
                                delay: 780),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "The type of storage depends on the feature being used. Some information may remain on the device while account settings, support or location-enabled feature information may be stored securely on our systems.",
                                delay: 790),

                            _buildAnimatedSectionTitle("6. Data Retention", delay: 800),
                            _buildAnimatedParagraph(
                                "We keep information only for as long as reasonably necessary to:",
                                delay: 810),
                            _buildAnimatedBullet("provide the app and its features", delay: 820),
                            _buildAnimatedBullet("maintain security and account integrity", delay: 830),
                            _buildAnimatedBullet("comply with legal obligations", delay: 840),
                            _buildAnimatedBullet("resolve disputes or enforce our terms", delay: 850),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "When information is no longer needed, we take reasonable steps to delete or de-identify it.",
                                delay: 860),

                            _buildAnimatedSectionTitle("7. User Choices", delay: 870),
                            _buildAnimatedParagraph("You may be able to:", delay: 880),
                            _buildAnimatedBullet("update account or profile information in the app",
                                delay: 890),
                            _buildAnimatedBullet("disable location permissions in your device settings",
                                delay: 900),
                            _buildAnimatedBullet(
                                "stop using optional location-based features at any time",
                                delay: 910),
                            _buildAnimatedBullet(
                                "request deletion of your account or associated information by contacting us",
                                delay: 920),
                            const SizedBox(height: 8),
                            _buildAnimatedParagraph(
                                "Disabling location permissions may prevent certain app features from functioning.",
                                delay: 930),

                            _buildAnimatedSectionTitle("8. Security", delay: 940),
                            _buildAnimatedParagraph(
                                "We use reasonable administrative, technical, and organizational safeguards to protect information. However, no app, device, transmission method, or storage system can be guaranteed to be completely secure.",
                                delay: 950),

                            _buildAnimatedSectionTitle("9. Children's Privacy", delay: 960),
                            _buildAnimatedParagraph(
                                "SolidSteps is not directed to children under 13, and we do not knowingly collect personal information from children under 13 without appropriate authorization. If we learn that such information has been collected inappropriately, we will take reasonable steps to delete it.",
                                delay: 970),

                            _buildAnimatedSectionTitle("10. Changes to This Policy", delay: 980),
                            _buildAnimatedParagraph(
                                "We may update this Privacy Policy from time to time. If we make material changes, we will update the effective date above and may provide additional notice where appropriate. Continued use of the app after an update means the updated policy will apply.",
                                delay: 990),

                            _buildAnimatedSectionTitle("11. Contact Us", delay: 1000),
                            _buildAnimatedParagraph(
                                "If you have questions about this Privacy Policy or wish to request account or data deletion, contact:",
                                delay: 1010),

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
              colors: [
                primaryDarkRed,
                const Color(0xFFD4256A),
                primaryDarkRed,
              ],
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
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: primaryDarkRed),
                const SizedBox(width: 6),
                Text(
                  "Effective Date: April 25, 2025",
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
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
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
                    colors: [
                      const Color(0xFFD4256A),
                      primaryDarkRed,
                    ],
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
          "Copyright © 2024 SolidSteps App",
          style: TextStyle(
            fontSize: 12,
            color: greyText,
          ),
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
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 16, color: widget.color),
              const SizedBox(width: 8),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
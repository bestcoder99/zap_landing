import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;
import 'dart:ui' as ui;
import 'package:web/web.dart' as html;

// Product URLs (update these to real URLs)
const String kZapInUrl = 'https://example.com/zap-in';
const String kZapAdminUrl = 'https://example.com/zap-admin';
class IframeVideo extends StatefulWidget {
  const IframeVideo({super.key, required this.previewUrl});
  final String previewUrl;

  @override
  State<IframeVideo> createState() => _IframeVideoState();
}

class _IframeVideoState extends State<IframeVideo> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'drive-iframe-${DateTime.now().microsecondsSinceEpoch}';

    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = html.HTMLIFrameElement()
          ..src = widget.previewUrl
          ..style.border = '0'
          ..allow = 'autoplay; encrypted-media'
          ..allowFullscreen = true;
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return HtmlElementView(viewType: _viewType);
  }
}


void main() => runApp(const ZapLanding());

class ZapLanding extends StatelessWidget {
  const ZapLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: const Color(0xFFE5E7EB),
          displayColor: const Color(0xFFE5E7EB),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(key: HomePage.homeKey),
        '/venues': (context) => const VenuesPage(),
        '/clinics-fnb': (context) => const ClinicsPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  // Static reference to allow scrolling from anywhere
  static GlobalKey<_HomePageState> homeKey = GlobalKey<_HomePageState>();
  
  // Static method to scroll to StartNow section
  static void scrollToStartNow() {
    homeKey.currentState?._scrollTo(homeKey.currentState!._startKey);
  }
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();

  // anchors
  final _heroKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _startKey = GlobalKey();
  final _testimonialsKey = GlobalKey();

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyedSubtree(
                key: _heroKey,
                child: HeroSection(
                  onAboutTap: () => _scrollTo(_aboutKey),
                  onStartTap: () => _scrollTo(_startKey),
                  onPricingTap: () => _scrollTo(_testimonialsKey),
                ),
              ),
              KeyedSubtree(
                key: _aboutKey,
                child: const AboutSection(), // white section, black text, no stats
              ),
              KeyedSubtree(
                key: _startKey,
                child: const StartNowSection(), // NEW
              ),
              KeyedSubtree(
  key: _testimonialsKey,          // <-- use the field, not a new GlobalKey()
  child: const TestimonialsSection(),
),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation helper function
void _openNewPage(BuildContext context, String route) {
  if (kIsWeb) {
    // For web, open in new tab with the full URL
    final currentUrl = html.window.location.href;
    final baseUrl = currentUrl.contains('/#/') 
        ? currentUrl.split('/#/')[0] 
        : currentUrl.split('/').take(3).join('/');
    final newUrl = '$baseUrl/#$route';
    html.window.open(newUrl, '_blank');
  } else {
    // For mobile apps, navigate normally
    Navigator.pushNamed(context, route);
  }
}

/// ---------------- VENUES PAGE ----------------
class VenuesPage extends StatelessWidget {
  const VenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: isMobile
            ? Column(
                children: [
                  // User Benefits Section
                  Expanded(
                    child: _VenueBenefitSection(
                      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
                      title: 'Zap In - User End',
                      subtitle: 'Instructions for users to join queues',
                      isUserSection: true,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ),
                  // Business Benefits Section
                  Expanded(
                    child: _VenueBenefitSection(
                      backgroundColor: const Color(0xFF0B0B0B), // Dark background to match your site
                      title: 'Zap Admin - Business End',
                      subtitle: 'Instructions for businesses to manage queues',
                      isUserSection: false,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  // User Benefits Section
                  Expanded(
                    child: _VenueBenefitSection(
                      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
                      title: 'Zap In - User End',
                      subtitle: 'Zap In benefits for the users.',
                      isUserSection: true,
                      isMobile: false,
                      isTablet: isTablet,
                    ),
                  ),
                  // Business Benefits Section
                  Expanded(
                    child: _VenueBenefitSection(
                      backgroundColor: const Color(0xFF0B0B0B), // Dark background to match your site
                      title: 'Zap Admin - Business End',
                      subtitle: 'Zap Admin benefits for the business',
                      isUserSection: false,
                      isMobile: false,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Venue Benefit Section Widget
class _VenueBenefitSection extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool isUserSection;
  final bool isMobile;
  final bool isTablet;

  

  const _VenueBenefitSection({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.isUserSection,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isUserSection ? Colors.black87 : Colors.white;
    final accentColor = const Color(0xFFCDFF05); // Your green accent

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 24 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 20 : isTablet ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.1,
            ),
          ),
          SizedBox(height: isMobile ? 24 : isTablet ? 32 : 48),
          // Grid
          Expanded(child: _buildBenefitsGrid(textColor, accentColor)),
          SizedBox(height: isMobile ? 16 : 24),
          // CTA button
          Align(
            alignment: Alignment.centerLeft,
            child: GlowButton(
              label: isUserSection ? 'Open Zap In' : 'Open Zap Admin',
              url: isUserSection ? "https://customer.zapnow.tech/login" : "https://admin.zapnow.tech/signup",
              accentColor: accentColor,
              darkBackground: !isUserSection,
              dense: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid(Color textColor, Color accentColor) {
    final benefits = isUserSection ? _getUserBenefits() : _getBusinessBenefits();

    // Use LayoutBuilder so sizing adapts smoothly to any container width
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Decide columns by available width (per-section width)
        final singleColumn = w < 560; // narrow section => 1 column

        // Grid spacing responsive to width
        final crossGap = w < 420 ? 12.0 : w < 760 ? 16.0 : 24.0;
        final mainGap = crossGap;

        // Scale typography + icon with width
        double clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);
        final scale = clamp(w / 560.0, 0.9, 1.1);

        final fontSize = clamp(16.0 * scale, 14.0, 18.0);
        final iconSize = clamp(24.0 * scale, 18.0, 26.0);
        final cardHeight = clamp(76.0 * scale, 64.0, 92.0);

        // Target a max card width so grid auto-fits 1 or 2 columns naturally
        final maxExtent = singleColumn ? w : clamp(w / 2 - crossGap, 360.0, 520.0);

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            mainAxisExtent: cardHeight,
            crossAxisSpacing: crossGap,
            mainAxisSpacing: mainGap,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            final benefit = benefits[index];
            return _Reveal(
              child: _VenueBenefitCard(
                icon: benefit['icon'],
                title: benefit['title'],
                textColor: textColor,
                accentColor: accentColor,
                fontSize: fontSize,
                iconSize: iconSize,
                cardHeight: cardHeight,
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getUserBenefits() {
    return [
      

      {
        'icon': Icons.looks_one_outlined,
        'title': 'Click Join Queue',
      },
      {
        'icon': Icons.looks_two_outlined,
        'title': 'Enter queue code',
      },
      {
        'icon': Icons.looks_3_outlined,
        'title': 'Select party size',
      },
      {
        'icon': Icons.looks_4_outlined,
        'title': 'Check status & relax',
      },
    ];
  }

  List<Map<String, dynamic>> _getBusinessBenefits() {
    return [
      {
        'icon': Icons.looks_one_outlined,
        'title': 'On Dashboard click +',
      },
      {
        'icon': Icons.looks_two_outlined,
        'title': 'Set Batch Details',
      },
      {
        'icon': Icons.looks_3_outlined,
        'title': 'Refresh, share queue code with guests',
      },
      {
        'icon': Icons.looks_4_outlined,
        'title': 'Monitor, and board guests',
      },
    ];
  }
}


class _ClincsBenefitSection extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool isUserSection;
  final bool isMobile;
  final bool isTablet;

  

  const _ClincsBenefitSection({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.isUserSection,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isUserSection ? Colors.black87 : Colors.white;
    final accentColor = const Color(0xFFCDFF05); // Your green accent

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 24 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 20 : isTablet ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.1,
            ),
          ),
          SizedBox(height: isMobile ? 24 : isTablet ? 32 : 48),
          // Grid
          Expanded(child: _buildBenefitsGrid(textColor, accentColor)),
          SizedBox(height: isMobile ? 16 : 24),
          // CTA button
          Align(
            alignment: Alignment.centerLeft,
            child: GlowButton(
              label: isUserSection ? 'Open Zap In' : 'Open Zap Admin',
              url: isUserSection ? "https://zapcateg.vercel.app" : "https://zapcategadmin.vercel.app/",
              accentColor: accentColor,
              darkBackground: !isUserSection,
              dense: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid(Color textColor, Color accentColor) {
    final benefits = isUserSection ? _getUserBenefits() : _getBusinessBenefits();

    // Use LayoutBuilder so sizing adapts smoothly to any container width
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Decide columns by available width (per-section width)
        final singleColumn = w < 560; // narrow section => 1 column

        // Grid spacing responsive to width
        final crossGap = w < 420 ? 12.0 : w < 760 ? 16.0 : 24.0;
        final mainGap = crossGap;

        // Scale typography + icon with width
        double clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);
        final scale = clamp(w / 560.0, 0.9, 1.1);

        final fontSize = clamp(16.0 * scale, 14.0, 18.0);
        final iconSize = clamp(24.0 * scale, 18.0, 26.0);
        final cardHeight = clamp(76.0 * scale, 64.0, 92.0);

        // Target a max card width so grid auto-fits 1 or 2 columns naturally
        final maxExtent = singleColumn ? w : clamp(w / 2 - crossGap, 360.0, 520.0);

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            mainAxisExtent: cardHeight,
            crossAxisSpacing: crossGap,
            mainAxisSpacing: mainGap,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            final benefit = benefits[index];
            return _Reveal(
              child: _VenueBenefitCard(
                icon: benefit['icon'],
                title: benefit['title'],
                textColor: textColor,
                accentColor: accentColor,
                fontSize: fontSize,
                iconSize: iconSize,
                cardHeight: cardHeight,
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getUserBenefits() {
    return [
      

      {
        'icon': Icons.looks_one_outlined,
        'title': 'Click Join Queue',
      },
      {
        'icon': Icons.looks_two_outlined,
        'title': 'Enter queue code',
      },
      {
        'icon': Icons.looks_3_outlined,
        'title': 'Select category',
      },
      {
        'icon': Icons.looks_4_outlined,
        'title': 'Check status & relax',
      },
    ];
  }

  List<Map<String, dynamic>> _getBusinessBenefits() {
    return [
      {
        'icon': Icons.looks_one_outlined,
        'title': 'On Dashboard click +',
      },
      {
        'icon': Icons.looks_two_outlined,
        'title': 'Set categories and queue details',
      },
      {
        'icon': Icons.looks_3_outlined,
        'title': 'Share queue code with guests',
      },
      {
        'icon': Icons.looks_4_outlined,
        'title': 'Monitor and board guests',
      },
    ];
  }
}

/// Individual Venue Benefit Card Widget
class _VenueBenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;
  final Color accentColor;
  final double fontSize;
  final double iconSize;
  final double cardHeight;

  const _VenueBenefitCard({
    required this.icon,
    required this.title,
    required this.textColor,
    required this.accentColor,
    required this.fontSize,
    required this.iconSize,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkBackground = textColor == Colors.white;
    final gap = iconSize >= 24 ? 16.0 : 12.0;
    final iconPad = (iconSize * 0.45).clamp(6.0, 12.0);

    return SizedBox(
      height: cardHeight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: gap, vertical: iconPad),
        decoration: BoxDecoration(
          color: isDarkBackground ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkBackground ? accentColor.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkBackground ? 0.2 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with accent background
            Container(
              padding: EdgeInsets.all(iconPad),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: iconSize,
              ),
            ),
            SizedBox(width: gap),
            // Title
            Expanded(
              child: Text(
                title,
                softWrap: true,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glow CTA button
class GlowButton extends StatefulWidget {
  final String label;
  final String url;
  final Color accentColor;
  final bool darkBackground;
  final bool dense;

  const GlowButton({
    super.key,
    required this.label,
    required this.url,
    required this.accentColor,
    this.darkBackground = false,
    this.dense = false,
  });

  @override
  State<GlowButton> createState() => _GlowCtaButtonState();
}

class _GlowCtaButtonState extends State<GlowButton> {
  bool _hover = false;
  bool _down = false;

  Future<void> _open() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = widget.darkBackground ? const Color(0xFF181818) : Colors.white;
    final labelColor = widget.darkBackground ? Colors.white : Colors.black;
    final pad = widget.dense ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10) : const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
    final radius = BorderRadius.circular(28);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: pad,
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: radius,
            border: Border.all(color: widget.accentColor.withOpacity(0.6), width: 1.2),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.55),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
            ],
            gradient: _down
                ? LinearGradient(colors: [widget.accentColor.withOpacity(0.25), baseBg])
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.north_east, size: widget.dense ? 14 : 16, color: labelColor),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: widget.dense ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- CLINICS/F&B PAGE (clone of VenuesPage) ----------------
class ClinicsPage extends StatelessWidget {
  const ClinicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: isMobile
            ? Column(
                children: [
                  // User Benefits Section (same as VenuesPage)
                  Expanded(
                    child: _ClincsBenefitSection(
                      backgroundColor: const Color(0xFFF8F9FA), // light bg
                      title: 'Zap In - User End',
                      subtitle: 'Instructions for users to join queues',
                      isUserSection: true,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ),
                  // Business Benefits Section (same as VenuesPage)
                  Expanded(
                    child: _ClincsBenefitSection(
                      backgroundColor: const Color(0xFF0B0B0B), // dark bg
                      title: 'Zap Admin - Business End',
                      subtitle: 'Instructions for businesses to manage queues',
                      isUserSection: false,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _ClincsBenefitSection(
                      backgroundColor: const Color(0xFFF8F9FA),
                      title: 'Zap In - User End',
                      subtitle: 'Zap In benefits for the users.',
                      isUserSection: true,
                      isMobile: false,
                      isTablet: isTablet,
                    ),
                  ),
                  Expanded(
                    child: _ClincsBenefitSection(
                      backgroundColor: const Color(0xFF0B0B0B),
                      title: 'Zap Admin - Business End',
                      subtitle: 'Zap Admin benefits for the business',
                      isUserSection: false,
                      isMobile: false,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


/// Glass effect section widget with background color
class _GlassSection extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;

  const _GlassSection({
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          // Glass effect overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Glassmorphism effect
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- HERO ----------------
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    this.onAboutTap,
    this.onStartTap,
    this.onPricingTap,
    this.onFaqsTap,
  });

  final VoidCallback? onAboutTap, onStartTap, onPricingTap, onFaqsTap;

  @override
  Widget build(BuildContext context) {
    const textMuted = Color(0xFF9CA3AF);
    const outline = Color(0xFF232627);
    const accent = Color(0xFFCDFF05);

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1100;

    final widthScale = (w / 1200).clamp(0.70, 1.10);
    final heightScale = (h / 900).clamp(0.75, 1.05);
    final scale = (widthScale * 0.65 + heightScale * 0.35).clamp(0.70, 1.10);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : isTablet ? 32 : 48,
        vertical: isMobile ? 24 : isTablet ? 48 : 72,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isMobile)
                Positioned(
                  right: isTablet ? -40 : -10,
                  top: isTablet ? 16 : -8,
                  child: IgnorePointer(
                    child: Container(
                      width: (isTablet ? 360 : 520) * scale,
                      height: (isTablet ? 360 : 520) * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x1ACDFF05), Colors.transparent],
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopNav(
                    accent: accent,
                    outline: outline,
                    scale: scale,
                    onAboutTap: onAboutTap,
                    onStartTap: onStartTap, // wired
                    onPricingTap: onPricingTap,
                    onFaqsTap: onFaqsTap,
                  ),
                  SizedBox(height: isMobile ? 22 : 40 * scale),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth;
                      return Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment:
                            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isMobile
                                ? contentWidth
                                : (isTablet ? contentWidth * 0.55 : contentWidth * 0.52),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8 * scale,
                                  runSpacing: 6 * scale,
                                  children: [
                                    _HeadingLine('Say goodbye to queues,',
                                        size: (isMobile ? 30 : 54) * scale),
                                    _HeadingLine(' hello to ',
                                        size: (isMobile ? 30 : 54) * scale,
                                        trailing: _AccentWord('Zap',
                                            accent: accent,
                                            size: (isMobile ? 30 : 54) * scale)),
                                  ],
                                ),
                                SizedBox(height: 14 * scale),
                                Text(
                                  'Zap is a live digital-queue system for restaurants, clinics, and offices. '
                                  'Fewer walk-aways, happier customers, and clear wait-time visibility.',
                                  style: GoogleFonts.inter(
                                    color: textMuted,
                                    height: 1.5,
                                    fontSize: (isMobile ? 14 : 16.5) * scale,
                                  ),
                                ),
                                SizedBox(height: 18 * scale),
                                _GlowButton(
                                  label: 'Get started',
                                  accent: accent,
                                  scale: scale,
                                  onTap: onStartTap ?? () {},
                                ),
                                SizedBox(height: 14 * scale),
                                Wrap(
                                  spacing: 10 * scale,
                                  runSpacing: 10 * scale,
                                  children: const [
                                    _KpiPill(icon: Icons.people_alt_outlined, label: '1,200+ active users'),
                                    _KpiPill(icon: Icons.store_mall_directory_outlined, label: '55 live queues run'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isMobile ? 0 : 28 * scale, height: isMobile ? 22 * scale : 0),
                          if (!isMobile)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _PhoneVisuals(
                                  outline: outline,
                                  variant: isTablet ? PhoneVariant.tablet : PhoneVariant.desktop,
                                  scale: scale,
                                ),
                              ),
                            ),
                          if (isMobile)
                            Padding(
                              padding: EdgeInsets.only(top: 8 * scale),
                              child: Center(
                                child: _PhoneVisuals(
                                  outline: outline,
                                  variant: PhoneVariant.mobile,
                                  scale: 0.92 * scale,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// nav
class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.accent,
    required this.outline,
    required this.scale,
    this.onAboutTap,
    this.onStartTap,
    this.onPricingTap,
    this.onFaqsTap,
  });

  final Color accent, outline;
  final double scale;
  final VoidCallback? onAboutTap, onStartTap, onPricingTap, onFaqsTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 768;

    Widget chip(String label, {VoidCallback? onTap}) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              border: Border.all(color: outline),
              color: const Color(0xFF101213),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 13 * scale, fontWeight: FontWeight.w500)),
          ),
        );

    return Row(
      children: [
        // Logo image
        Image.asset(
          'assets/zap-logo.png',
          height: (isMobile ? 40 : 48) * scale,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        if (!isMobile) ...[
          chip('About', onTap: onAboutTap),
          SizedBox(width: 10 * scale),
          chip('Start Now', onTap: onStartTap), // changed from Contact
          SizedBox(width: 10 * scale),
          chip('Testimonials', onTap: onPricingTap),
          SizedBox(width: 10 * scale),
        ],
        _GlowButton(
          label: 'Start Now', 
          accent: accent, 
          scale: scale, 
          onTap: onStartTap ?? () {},
        ),
      ],
    );
  }
}

class _HeadingLine extends StatelessWidget {
  const _HeadingLine(this.text, {this.trailing, required this.size});
  final String text;
  final Widget? trailing;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          text,
          softWrap: true,
          style: GoogleFonts.inter(
            fontSize: size,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _AccentWord extends StatelessWidget {
  const _AccentWord(this.word, {required this.accent, required this.size});
  final String word;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      word,
      style: GoogleFonts.inter(
        fontSize: size,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: accent,
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  const _GlowButton(
      {required this.label, required this.accent, required this.scale, required this.onTap});
  final String label;
  final Color accent;
  final double scale;
  final VoidCallback onTap;

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 18 * widget.scale, vertical: 14 * widget.scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.accent, widget.accent.withOpacity(0.92)]),
            borderRadius: BorderRadius.circular(14 * widget.scale),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.55),
                      blurRadius: 28 * widget.scale,
                      spreadRadius: 1,
                      offset: Offset(0, 6 * widget.scale),
                    )
                  ]
                : [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.25),
                      blurRadius: 16 * widget.scale,
                      offset: Offset(0, 4 * widget.scale),
                    )
                  ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 15.5 * widget.scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiPill extends StatelessWidget {
  const _KpiPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final scale = (w / 1200).clamp(0.7, 1.1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF101213),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF232627)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16 * scale, color: const Color(0xFF8FA3A7)),
          SizedBox(width: 6 * scale),
          Text(label, style: GoogleFonts.inter(fontSize: 13.2 * scale, color: const Color(0xFFCFD8DC))),
        ],
      ),
    );
  }
}

/// phone visuals
enum PhoneVariant { mobile, tablet, desktop }

class _PhoneVisuals extends StatelessWidget {
  const _PhoneVisuals({
    required this.outline,
    required this.variant,
    this.scale = 1,
  });

  final Color outline;
  final PhoneVariant variant;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 768;

    final baseW = (isMobile ? 220 : 260) * scale;
    final baseH = (isMobile ? 440 : 520) * scale;

    Widget phone(String asset, {double angle = 0}) => Transform.rotate(
          angle: angle,
          child: Container(
            width: baseW,
            height: baseH,
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0F10),
              borderRadius: BorderRadius.circular(36 * scale),
              border: Border.all(color: outline),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26 * scale),
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
        );

    switch (variant) {
      case PhoneVariant.mobile:
        return phone('assets/phone-customer.png', angle: -0.02);
      case PhoneVariant.tablet:
        return SizedBox(
          height: 520 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.9,
                  child: Transform.scale(
                    scale: 0.96,
                    child: phone('assets/phone-business.png', angle: 0.04),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: -10 * scale,
                child: phone('assets/phone-customer.png', angle: -0.06),
              ),
            ],
          ),
        );
      case PhoneVariant.desktop:
        return SizedBox(
          height: 560 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 160 * scale,
                bottom: 0,
                child: Opacity(
                  opacity: 0.9,
                  child: Transform.scale(
                    scale: 0.96,
                    child: phone('assets/phone-business.png', angle: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 24 * scale,
                top: -10 * scale,
                child: phone('assets/phone-customer.png', angle: -0.08),
              ),
            ],
          ),
        );
    }
  }
}

/// ---------------- ABOUT (white bg, black text, no stats) ----------------
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCDFF05);
    const text = Color(0xFF0B0B0B);
    const textMuted = Color(0xFF4B5563);

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1100;

    final widthScale = (w / 1200).clamp(0.70, 1.10);
    final heightScale = (h / 900).clamp(0.75, 1.05);
    final scale = (widthScale * 0.65 + heightScale * 0.35).clamp(0.70, 1.10);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : isTablet ? 32 : 48,
        vertical: isMobile ? 56 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              _Reveal(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24 * scale,
                      height: 24 * scale,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDFF05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 14, color: Colors.black),
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      'INTRODUCING ZAP',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * scale),
              _Reveal(
                delayMs: 80,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'We know what’s going on.\n',
                        style: GoogleFonts.inter(
                          fontSize: (isMobile ? 28 : 48) * scale,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: text,
                        ),
                      ),
                      TextSpan(
                        text: 'That’s when Zap comes in.',
                        style: GoogleFonts.inter(
                          fontSize: (isMobile ? 26 : 44) * scale,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: text.withOpacity(.85),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height: 28 * scale),
              _Reveal(
                delayMs: 160,
                child: Column(
                  children: [
                    // Description text
                    Container(
                      margin: EdgeInsets.only(bottom: 32 * scale),
                      child: Text(
                        'Long queues frustrate customers and slow businesses down. '
                        'Even when actual wait times are short, a long-looking line pushes people away. '
                        'Zap replaces the visible wait with a modern virtual queue—clear, fair, and transparent.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: textMuted,
                          height: 1.7,
                          fontSize: (isMobile ? 14.5 : 16.5) * scale,
                        ),
                      ),
                    ),
                    
                    // 2x2 Grid of benefit cards
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: (isMobile ? double.infinity : 800 * scale)),
                      child: Column(
                        children: [
                          // First row
                          Row(
                            children: [
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.qr_code_scanner,
                                  title: 'No App Required',
                                  description: 'Customers join from a QR or link—no app install.',
                                  scale: scale,
                                  delayMs: 220,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.notifications_active,
                                  title: 'Smart Notifications',
                                  description: 'Live position + smart notifications reduce anxiety.',
                                  scale: scale,
                                  delayMs: 280,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * scale),
                          // Second row
                          Row(
                            children: [
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.dashboard,
                                  title: 'Simple Dashboard',
                                  description: 'Managers control flow from a simple web dashboard.',
                                  scale: scale,
                                  delayMs: 340,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.analytics,
                                  title: 'Smart Analytics',
                                  description: 'Analytics turn waits into insights and revenue.',
                                  scale: scale,
                                  delayMs: 400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * scale),
                          // Third row
                          Row(
                            children: [
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.tune,
                                  title: 'Customizable Features',
                                  description: 'Tailor queue settings and workflows to match your business needs perfectly.',
                                  scale: scale,
                                  delayMs: 460,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.queue,
                                  title: 'Multi-Queue Tracking',
                                  description: 'Users can monitor their position across multiple queues simultaneously.',
                                  scale: scale,
                                  delayMs: 520,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // (stats removed)
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.scale,
    this.delayMs = 0,
  });

  final IconData icon;
  final String title;
  final String description;
  final double scale;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCDFF05);
    const text = Color(0xFF0B0B0B);
    const muted = Color(0xFF4B5563);
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 768;

    return _Reveal(
      delayMs: delayMs,
      child: Container(
        // Remove fixed height to allow flexible sizing
        padding: EdgeInsets.all(isMobile ? 16 * scale : 20 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16 * scale,
              offset: Offset(0, 4 * scale),
              spreadRadius: 1 * scale,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4 * scale,
              offset: Offset(0, 1 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Allow flexible height
          children: [
            Container(
              width: isMobile ? 36 * scale : 40 * scale,
              height: isMobile ? 36 * scale : 40 * scale,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(
                icon,
                size: isMobile ? 18 * scale : 20 * scale,
                color: text,
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 14 * scale : 16 * scale,
                fontWeight: FontWeight.w700,
                color: text,
                height: 1.3,
              ),
            ),
            SizedBox(height: 6 * scale),
            Flexible(
              child: Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 12 * scale : 13 * scale,
                  color: muted,
                  height: 1.5,
                ),
                // Remove maxLines and overflow restrictions to show full text
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// ---------------- START NOW (two variants) ----------------
class StartNowSection extends StatelessWidget {
  const StartNowSection({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCDFF05);
    const outlineDark = Color(0xFF232627);
    const text = Color(0xFFE5E7EB);
    const muted = Color(0xFF9CA3AF);

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1100;

    final widthScale = (w / 1200).clamp(0.70, 1.10);
    final heightScale = (h / 900).clamp(0.75, 1.05);
    final scale = (widthScale * 0.65 + heightScale * 0.35).clamp(0.70, 1.10);

    return Container(
      color: const Color(0xFF0B0B0B), // back to dark for contrast after white About
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : isTablet ? 32 : 48,
        vertical: isMobile ? 56 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Reveal(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24 * scale,
                      height: 24 * scale,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDFF05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 14, color: Colors.black),
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      'GET STARTED',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * scale),
              _Reveal(
                child: Text(
                  'Start now',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (isMobile ? 28 : 42) * scale,
                    fontWeight: FontWeight.w800,
                    color: text,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(height: 10 * scale),
              _Reveal(
                delayMs: 80,
                child: Text(
                  'Digitalise queues now, takes a minute saves a century. Choose your variant below to get started.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (isMobile ? 14.5 : 16) * scale,
                    color: muted,
                  ),
                ),
              ),
              SizedBox(height: 28 * scale),

              // Two cards
              _Reveal(
                delayMs: 140,
                child: Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, // or CrossAxisAlignment.center

                  children: [
                    Expanded(
                      flex: isMobile ? 0 : 6,
                      child: _VariantCard(
                        title: 'Digital Queues with Meta-Grouping',
                        subtitle: 'Amusement parks · Airports · Temples',
                        bullets: const [
                          'Create "meta groups" - optimised waitlists to fill batches',
                          'Board users based on batch size',
                          'Auto-sorts premium and standard guests',
                          
                        ],
                        ctaText: 'Launch this version',
                        onTap: () {
                          _openNewPage(context, '/venues');
                        },
                        accent: accent,
                        outline: outlineDark,
                        scale: scale,
                      ),
                    ),
                    SizedBox(width: isMobile ? 0 : 24 * scale, height: isMobile ? 18 * scale : 0),
                    Expanded(
                      flex: isMobile ? 0 : 6,
                      child: _VariantCard(
                        title: 'Digital Queues with Categorisation',
                        subtitle: 'Hospitals · Appointments · Restaurants',
                        bullets: const [
                          'Create "categories" for users to pick from',
                          'Users sorted based on categories chosen',
                          'AI Caller reminders - no need to pick your phone and dial',
                        ],
                        ctaText: 'Launch this version',
                        onTap: () {
                          _openNewPage(context, '/clinics-fnb');
                        },
                        accent: accent,
                        outline: outlineDark,
                        scale: scale,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18 * scale),

BookCallBlock(
  accent: accent,
  outline: outlineDark,
  scale: scale,
),

            ],
          ),
        ),
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.ctaText,
    required this.onTap,
    required this.accent,
    required this.outline,
    required this.scale,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;
  final String ctaText;
  final VoidCallback onTap;
  final Color accent, outline;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFE5E7EB);
    const muted = Color(0xFF9CA3AF);

    return Container(
      margin: EdgeInsets.only(bottom: 18 * scale),
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF101213),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              Container(
                width: 14 * scale,
                height: 14 * scale,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: (20) * scale,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: (13.5) * scale,
              color: muted,
            ),
          ),
          SizedBox(height: 14 * scale),

          // bullets
          ...bullets.map((b) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8 * scale,
                      height: 8 * scale,
                      margin: EdgeInsets.only(top: 6 * scale),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2 * scale),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: Text(
                        b,
                        style: GoogleFonts.inter(
                          fontSize: 14.5 * scale,
                          color: text.withOpacity(.95),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          SizedBox(height: 14 * scale),

          // CTA
          Align(
            alignment: Alignment.centerLeft,
            child: _GlowButton(
              label: ctaText,
              accent: accent,
              scale: scale,
              onTap: onTap,
            ),
          ),
          
        ],
      ),
    );
  }
}

/// reveal-on-scroll (fade + slight slide)
class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _kickoff() async {
    if (_started) return;
    _started = true;
    if (widget.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: widget.delayMs));
    }
    if (mounted) _c.forward();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15) _kickoff();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: FractionalTranslation(translation: _offset.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

class BookCallBlock extends StatelessWidget {
  const BookCallBlock({
    super.key,
    required this.accent,
    required this.outline,
    required this.scale,
  });

  final Color accent, outline;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFFE5E7EB);
    const muted = Color(0xFF9CA3AF);

    return Container(
      margin: EdgeInsets.only(top: 16 * scale),
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF101213),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: outline),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 720;
          return Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment:
                isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              // Left: Copy
              Expanded(
                flex: isNarrow ? 0 : 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16 * scale,
                          height: 16 * scale,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(4 * scale),
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        Text(
                          'Book a call',
                          style: GoogleFonts.inter(
                            fontSize: (20) * scale,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Get a 15-minute walkthrough: setup, pricing, and whether Zap fits your flow.',
                      style: GoogleFonts.inter(
                        fontSize: 14.5 * scale,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isNarrow ? 0 : 18 * scale, height: isNarrow ? 16 * scale : 0),

              // Right: Actions
              Expanded(
                flex: isNarrow ? 0 : 5,
                child: Wrap(
                  alignment: isNarrow ? WrapAlignment.start : WrapAlignment.end,
                  spacing: 12 * scale,
                  runSpacing: 12 * scale,
                  children: [
                    _SmallGlowButton(
                      label: 'Pick a slot',
                      accent: accent,
                      scale: scale,
                      onTap: () => _safeLaunch('https://calendly.com/zapmyqueue/30min'),
                    ),
                    
                    _OutlineChip(
                      label: 'WhatsApp',
                      outline: outline,
                      scale: scale,
                      onTap: () => _safeLaunch('https://wa.me/918237842553?text=Hi%20Zap%2C%20I%27d%20like%20a%2015-min%20demo'),
                    ),
                    _OutlineChip(
                      label: 'Email',
                      outline: outline,
                      scale: scale,
                      onTap: () => _safeLaunch('mailto:advitiya@zapnow.tech?subject=Zap%20demo%20request'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SmallGlowButton extends StatefulWidget {
  const _SmallGlowButton({
    required this.label,
    required this.accent,
    required this.scale,
    required this.onTap,
  });
  final String label;
  final Color accent;
  final double scale;
  final VoidCallback onTap;

  @override
  State<_SmallGlowButton> createState() => _SmallGlowButtonState();
}

class _SmallGlowButtonState extends State<_SmallGlowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 16 * widget.scale, vertical: 12 * widget.scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.accent, widget.accent.withOpacity(0.92)]),
            borderRadius: BorderRadius.circular(12 * widget.scale),
            boxShadow: _hover
                ? [BoxShadow(color: widget.accent.withOpacity(0.55), blurRadius: 24 * widget.scale, offset: Offset(0, 6 * widget.scale))]
                : [BoxShadow(color: widget.accent.withOpacity(0.22), blurRadius: 14 * widget.scale, offset: Offset(0, 4 * widget.scale))],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 14.5 * widget.scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({
    required this.label,
    required this.outline,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color outline;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: outline),
          color: const Color(0xFF0F1112),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13.5 * scale, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ignore: unused_element
void _showBookCallSheet(BuildContext context, Color accent, double scale) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0E0F10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
    ),
    builder: (context) {
      final outline = const Color(0xFF232627);
      const text = Color(0xFFE5E7EB);
      const muted = Color(0xFF9CA3AF);

      final dates = [
        'Today',
        'Tomorrow',
        'This Fri',
        'Next Mon',
      ];
      final slots = [
        '10:00–10:15',
        '11:30–11:45',
        '15:00–15:15',
        '18:30–18:45',
      ];

      String selectedDate = dates.first;
      String selectedSlot = slots[1];

      Widget chip(String label, bool active, VoidCallback onTap) => GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: outline),
                color: active ? accent : const Color(0xFF101213),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.black : text,
                ),
              ),
            ),
          );

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(18 * scale, 16 * scale, 18 * scale, 20 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: outline,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text('Book a 15-minute call', style: GoogleFonts.inter(fontSize: 18 * scale, fontWeight: FontWeight.w800, color: text)),
                SizedBox(height: 6 * scale),
                Text('Pick a date and a quick slot—We’ll send you a calendar invite.', style: GoogleFonts.inter(fontSize: 14 * scale, color: muted)),
                SizedBox(height: 14 * scale),

                Text('Date', style: GoogleFonts.inter(fontSize: 13 * scale, color: muted)),
                SizedBox(height: 8 * scale),
                Wrap(
                  spacing: 8 * scale,
                  runSpacing: 8 * scale,
                  children: dates
                      .map((d) => chip(d, d == selectedDate, () => setState(() => selectedDate = d)))
                      .toList(),
                ),
                SizedBox(height: 14 * scale),

                Text('Time (IST)', style: GoogleFonts.inter(fontSize: 13 * scale, color: muted)),
                SizedBox(height: 8 * scale),
                Wrap(
                  spacing: 8 * scale,
                  runSpacing: 8 * scale,
                  children: slots
                      .map((s) => chip(s, s == selectedSlot, () => setState(() => selectedSlot = s)))
                      .toList(),
                ),
                SizedBox(height: 20 * scale),

                Row(
                  children: [
                    Expanded(
                      child: _SmallGlowButton(
                        label: 'Confirm',
                        accent: accent,
                        scale: scale,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF111315),
                              content: Text(
                                'Booked: $selectedDate, $selectedSlot • We\'ll email you a calendar invite.',
                                style: GoogleFonts.inter(),
                              ),
                              action: SnackBarAction(
                                label: 'Open email',
                                textColor: accent,
                                onPressed: () => _safeLaunch('mailto:sales@zapapp.com?subject=Zap%20call%20confirmation'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    _OutlineChip(
                      label: 'Use Calendly',
                      outline: outline,
                      scale: scale,
                      onTap: () => _safeLaunch('https://calendly.com/your-handle/15min'),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
              ],
            ),
          );
        },
      );
    },
  );
}


Future<void> _safeLaunch(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    // silently ignore or show a toast/snackbar if you prefer
  }
}


/// ---------------- TESTIMONIALS (white bg, dark text, animated videos) ----------------

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF0B0B0B);
    const muted = Color(0xFF4B5563);
    const accent = Color(0xFFCDFF05);

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1100;

    final widthScale = (w / 1200).clamp(0.70, 1.10);
    final heightScale = (h / 900).clamp(0.75, 1.05);
    final scale = (widthScale * 0.65 + heightScale * 0.35).clamp(0.70, 1.10);

    const drivePreview =
        'https://drive.google.com/file/d/1wVtXHU1TI_hZ9UrCQeUl9zZYMm-J4CSL/preview';

        // https://drive.google.com/file/d/19CcQc_PMcwy6Y8OLxyzyCwnO-MjcLNAB/preview

    Widget styledIframePlayer(String url, {int delayMs = 0}) => _Reveal(
          delayMs: delayMs,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24 * scale,
                  offset: Offset(0, 8 * scale),
                  spreadRadius: 2 * scale,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * scale),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: IframeVideo(previewUrl: url),
              ),
            ),
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : isTablet ? 32 : 48,
        vertical: isMobile ? 56 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              _Reveal(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24 * scale,
                      height: 24 * scale,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDFF05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 14, color: Colors.black),
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      'CUSTOMER STORIES',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * scale),
              _Reveal(
                delayMs: 80,
                child: Text(
                  'Real businesses, real results',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (isMobile ? 28 : 42) * scale,
                    fontWeight: FontWeight.w800,
                    color: text,
                    height: 1.15,
                  ),
                ),
              ),
              SizedBox(height: 12 * scale),
              _Reveal(
                delayMs: 140,
                child: Text(
                  'See how businesses across industries are transforming their customer experience with Zap.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (isMobile ? 14.5 : 16) * scale,
                    color: muted,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 48 * scale),
              _Reveal(
                delayMs: 200,
                child: isMobile 
                  ? Column(
                      children: [
                        // First testimonial
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 32 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  'Restaurant Chain',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                '"Smoother Managing Experience"',
                                style: GoogleFonts.inter(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: text,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                'How a popular restaurant chain eliminated crowded lobbies and improved customer satisfaction.',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  color: muted,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16 * scale),
                              styledIframePlayer(drivePreview, delayMs: 280),
                            ],
                          ),
                        ),
                        // Second testimonial
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  'Government Office',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                '"Much more convenient"',
                                style: GoogleFonts.inter(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: text,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                'See how governmental functions were made easier.',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  color: muted,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16 * scale),
                              styledIframePlayer("https://drive.google.com/file/d/19CcQc_PMcwy6Y8OLxyzyCwnO-MjcLNAB/preview", delayMs: 360),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  'Restaurant Chain',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                '"Smoother Managing Experience"',
                                style: GoogleFonts.inter(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: text,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                'How a popular restaurant chain eliminated crowded lobbies and improved customer satisfaction.',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  color: muted,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16 * scale),
                              styledIframePlayer(drivePreview, delayMs: 280),
                            ],
                          ),
                        ),
                        SizedBox(width: 32 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  'Government Office',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                '"Much more convenient"',
                                style: GoogleFonts.inter(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: text,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                'See how governmental functions were made easier.',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  color: muted,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16 * scale),
                              styledIframePlayer("https://drive.google.com/file/d/19CcQc_PMcwy6Y8OLxyzyCwnO-MjcLNAB/preview", delayMs: 360),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
              SizedBox(height: 48 * scale),
              _Reveal(
                delayMs: 420,
                child: Container(
                  padding: EdgeInsets.all(24 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48 * scale,
                        height: 48 * scale,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          size: 24 * scale,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to see your results?',
                              style: GoogleFonts.inter(
                                fontSize: (isMobile ? 16 : 18) * scale,
                                fontWeight: FontWeight.w700,
                                color: text,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              'Join these businesses and start transforming your customer experience today.',
                              style: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      _GlowButton(
                        label: 'Get started',
                        accent: accent,
                        scale: scale * 0.9,
                        onTap: () {
                          // Use the static method to scroll to the Start Now section
                          HomePage.scrollToStartNow();
                        },
                      ),
                    ],
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



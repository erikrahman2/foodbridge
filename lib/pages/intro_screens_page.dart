import 'package:flutter/material.dart';
import 'package:food_bridge/routes/app_routes.dart';

class IntroScreensPage extends StatefulWidget {
  const IntroScreensPage({super.key});

  @override
  State<IntroScreensPage> createState() => _IntroScreensPageState();
}

class _IntroScreensPageState extends State<IntroScreensPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  late AnimationController _loadingController;
  late AnimationController _fadeController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
 
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
 
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
 
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
 
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
 
    _loadingController.forward();
 
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward().then((_) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 1) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    } else if (page == 2) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.welcomeSplash);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B4A),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildFirstScreen(),
          _buildSecondScreen(),
          _buildThirdScreen(),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B4A),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondScreen() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B4A),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Image.asset(
                    'assets/images/LogoOnboarding.png',
                    width: 180,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const SpeedIcon(),
                  ),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: value,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Nikmati Kelezatan,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Berbagi Kebaikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 1 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 1 ? Colors.white : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThirdScreen() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B4A),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Image.asset(
                    'assets/images/LogoOnboarding.png',
                    width: 180,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const SpeedIcon(),
                  ),
                ),
              ),
              SizedBox(height: 40 * value),
              Opacity(
                opacity: value,
                child: const Text(
                  'FOOD BRIDGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              SizedBox(height: 16 * value),
              Opacity(
                opacity: value,
                child: const Text(
                  'Menghubungkan Rasa & Kepedulian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: value,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Nikmati Kelezatan,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Berbagi Kebaikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 2 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 2 ? Colors.white : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class SpeedIcon extends StatelessWidget {
  const SpeedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 100,
      child: CustomPaint(
        painter: SpeedIconPainter(),
      ),
    );
  }
}

class SpeedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.5),
      size.height * 0.28,
      circlePaint,
    );

    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.72, size.height * 0.5),
      radius: size.height * 0.38,
    );
    canvas.drawArc(
      arcRect,
      -2.8,
      2.0,
      false,
      arcPaint,
    );

    final trianglePath = Path();
    trianglePath.moveTo(size.width * 0.05, size.height * 0.5);
    trianglePath.lineTo(size.width * 0.5, size.height * 0.2);
    trianglePath.lineTo(size.width * 0.5, size.height * 0.8);
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

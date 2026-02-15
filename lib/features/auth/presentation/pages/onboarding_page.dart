import 'package:flutter/material.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_responsive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Discover elite tournaments',
      subtitle:
          'Find and join premium sports events in your area. Compete with the best.',
      image: 'assets/images/second.png',
    ),
    OnboardingData(
      title: 'Track Your Performance',
      subtitle:
          'Advanced analytics and real-time stats to help you reach the top of your game.',
      image: 'assets/images/third.png',
    ),
    OnboardingData(
      title: 'Manage Your Journey',
      subtitle:
          'From match schedules to payment history, control every aspect of your sports career.',
      image: 'assets/images/fourth.png',
    ),
  ];

  void _onNext() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.register);
    }
  }

  void _onSkip() {
    Navigator.of(context).pushReplacementNamed(AppRouter.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _onboardingData[index].image,
                    fit: BoxFit.cover,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.s(context, 18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppResponsive.h(context, 0.16)),
                          Text(
                            _onboardingData[index].title,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.font(context, 30),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.41,),
                          ),
                          SizedBox(height: AppResponsive.s(context, 20)),
                          Text(
                            _onboardingData[index].subtitle,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.font(context, 20),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(context, 0.00),
              ),
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double progress = 0;
                        if (_pageController.hasClients &&
                            _pageController.position.hasContentDimensions) {
                          progress = (_pageController.page ?? 0) + 1;
                        } else {
                          progress = (_currentIndex + 1).toDouble();
                        }

                        return Container(
                          width: AppResponsive.w(context, 0.58),
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  Container(
                                    width: constraints.maxWidth *
                                        (progress / _onboardingData.length),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC3FF00),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Visibility(
                        visible: _currentIndex < _onboardingData.length - 1,
                        child: TextButton(
                          onPressed: _onSkip,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.font(context, 14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.s(context, 50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppResponsive.s(context, 55),
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 17),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(context, 0.1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String image;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

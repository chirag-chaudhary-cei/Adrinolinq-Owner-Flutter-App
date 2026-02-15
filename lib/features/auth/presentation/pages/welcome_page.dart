import 'package:flutter/material.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_responsive.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/first.png'),
                    fit: BoxFit.cover,),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: AppResponsive.padding(context, horizontal: 50),
                child: Column(
                  children: [
                    SizedBox(height: media.size.height * 0.18),
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/Logo.png',
                          width: 92,
                          height: 92,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: media.size.height * 0.025),
                    Text(
                      'ADRINOLINQ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppResponsive.font(context, 58),
                        fontFamily: 'Reglo-Bold',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Sports Management for local communities',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppResponsive.font(context, 15),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: media.size.width * 0.06,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: AppResponsive.s(context, 50),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRouter.onboardingIntro);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E8EE9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "I'm new here",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.font(context, 17),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: media.size.width * 0.06,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.login);
                          },
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.font(context, 17),
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }
}

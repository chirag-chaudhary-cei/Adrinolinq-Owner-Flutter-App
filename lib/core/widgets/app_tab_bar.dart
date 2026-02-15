import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';

/// Global Tab Bar Component
///
/// A reusable tab bar with consistent design across the app.
/// Features a grey background with a white sliding pill indicator.
///
/// Example usage:
/// ```dart
/// TabController _tabController = TabController(length: 2, vsync: this);
///
/// AppTabBar(
///   tabController: _tabController,
///   tabs: ['Your Details', 'Tournament Details'],
/// )
/// ```
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.height,
    this.backgroundColor,
  }) : assert(tabs.length >= 2, 'AppTabBar requires at least 2 tabs');

  /// The tab controller managing tab state
  final TabController tabController;

  /// List of tab labels
  final List<String> tabs;

  /// Optional custom height (defaults to 48dp)
  final double? height;

  /// Optional background color (defaults to light grey #EBECF0)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      padding: AppResponsive.padding(context, horizontal: 20, top: 16),
      child: Container(
        height: height ?? AppResponsive.s(context, 52),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFEBECF0),
          borderRadius: AppResponsive.borderRadius(context, 30),
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: AppResponsive.borderRadius(context, 24),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 15),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 15),
            fontWeight: FontWeight.w500,
          ),
          labelPadding: EdgeInsets.zero,
          padding: AppResponsive.padding(context, all: 4),
          tabs: tabs.map((label) => Tab(text: label)).toList(),
        ),
      ),
    );
  }
}

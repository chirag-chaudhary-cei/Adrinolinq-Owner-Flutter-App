import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../data/models/tournament_model.dart';
import '../providers/tournaments_providers.dart';
import 'create_team_page.dart';
import '../../../my_tournament/presentation/providers/my_tournament_providers.dart';

/// Helper function to capitalize text
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Parse date from API format (DD-MM-YYYY HH:MM:SS)
DateTime? _parseApiDate(String dateStr) {
  if (dateStr.isEmpty) return null;
  try {
    final normalized = dateStr.replaceAll('/', '-');
    return DateFormat('dd-MM-yyyy HH:mm:ss').parse(normalized);
  } catch (_) {
    try {
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

/// Format date as 'DD MMM YYYY' (e.g., 15 Dec 2024)
String _formatDate(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return dateStr;
  return DateFormat('dd MMM yyyy').format(date);
}

/// Format time as 'hh:mm AM/PM'
String _formatTime(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return '';
  return DateFormat('hh:mm a').format(date);
}

/// Format date range for registration period
String _formatDateRange(String startDate, String endDate) {
  final start = _parseApiDate(startDate);
  final end = _parseApiDate(endDate);

  if (start == null || end == null) {
    return '${_formatDate(startDate)} to ${_formatDate(endDate)}';
  }

  return '${DateFormat('dd MMM yyyy').format(start)} to ${DateFormat('dd MMM yyyy').format(end)}';
}

class TournamentDetailPage extends ConsumerStatefulWidget {
  const TournamentDetailPage({
    super.key,
    required this.tournamentId,
  });

  final int tournamentId;

  @override
  ConsumerState<TournamentDetailPage> createState() =>
      _TournamentDetailPageState();
}

class _TournamentDetailPageState extends ConsumerState<TournamentDetailPage> {
  bool? _canRegister;
  bool _isLoading = true;
  bool _isRegistrationClosed = false;
  int? _selectedTeamId;

  final ScrollController _scrollController = ScrollController();

  double _headerOffset = 0.0;
  double _maxHeaderHeight = 340.0;
  static const double _minAppBarHeight = 72.0;

  final GlobalKey _sponsorsKey = GlobalKey();
  double _sponsorsHeight = 0.0;

  double get _collapseExtent =>
      (_maxHeaderHeight - _minAppBarHeight) + _sponsorsHeight;

  double get _expandedTotalHeight => _maxHeaderHeight + _sponsorsHeight;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _updateHeaderOffset(_scrollController);
  }

  void _updateHeaderOffset(ScrollController controller) {
    if (_collapseExtent <= 0) return;

    final offset = controller.offset;
    final newOffset = (offset / _collapseExtent).clamp(0.0, 1.0);
    if ((newOffset - _headerOffset).abs() > 0.001) {
      setState(() => _headerOffset = newOffset);
    }
  }

  void _measureSponsorsHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderBox? renderBox =
          _sponsorsKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final newHeight = renderBox.size.height;
        if ((newHeight - _sponsorsHeight).abs() > 0.1 && newHeight > 0) {
          setState(() {
            _sponsorsHeight = newHeight;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistrationStatus(TournamentModel tournament) async {
    bool isClosed = false;
    if (tournament.registrationCloseDate.isNotEmpty) {
      try {
        final normalized =
            tournament.registrationCloseDate.replaceAll('/', '-');
        final closeDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(normalized);
        isClosed = DateTime.now().isAfter(closeDate);
      } catch (_) {
        isClosed = false;
      }
    }

    if (mounted) {
      setState(() {
        _isRegistrationClosed = isClosed;
        _canRegister = tournament.openOrClose;
        _isLoading = false;
      });
    }
  }

  Future<void> _showInviteCodeDialog() async {
    // Fetch current tournament data
    final tournament =
        await ref.read(tournamentDetailsProvider(widget.tournamentId).future);
    if (tournament == null) return;

    final inviteCodeController = TextEditingController();
    final parentContext = context;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppResponsive.radius(dialogContext, 32)),
        ),
        insetPadding: EdgeInsets.all(AppResponsive.p(dialogContext, 20)),
        child: Padding(
          padding: EdgeInsets.all(AppResponsive.p(dialogContext, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: AppResponsive.s(dialogContext, 100),
                height: AppResponsive.s(dialogContext, 50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: AppResponsive.s(dialogContext, 22),
                        backgroundImage:
                            const AssetImage('assets/images/demo1.jpg'),
                      ),
                    ),
                    Positioned(
                      child: CircleAvatar(
                        radius: AppResponsive.s(dialogContext, 22),
                        backgroundImage:
                            const AssetImage('assets/images/demo1.jpg'),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: AppResponsive.s(dialogContext, 22),
                        backgroundImage:
                            const AssetImage('assets/images/demo1.jpg'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppResponsive.s(dialogContext, 16)),
              Text(
                'Only Invited !',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(dialogContext, 20),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: AppResponsive.s(dialogContext, 8)),
              Text(
                'Only Invited join this Tournaments. Please\nEnter a Invited Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(dialogContext, 14),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5C5C5C),
                ),
              ),
              SizedBox(height: AppResponsive.s(dialogContext, 20)),
              AppTextFieldWithLabel(
                controller: inviteCodeController,
                label: 'Invited Code',
                hintText: 'Invited Code',
              ),
              SizedBox(height: AppResponsive.s(dialogContext, 24)),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(dialogContext),
                      isOutlined: true,
                      borderColor: Colors.grey.shade300,
                      textColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: AppResponsive.s(dialogContext, 12)),
                  Expanded(
                    child: AppButton(
                      text: 'Join',
                      onPressed: () async {
                        final inputCode = inviteCodeController.text.trim();
                        if (inputCode.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter invite code'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(dialogContext);

                        AppLoading.showDialog(
                          parentContext,
                          message: 'Verifying invite code...',
                        );

                        try {
                          final dataSource =
                              ref.read(tournamentsRemoteDataSourceProvider);
                          final result = await dataSource
                              .saveTournamentRegistrationWithInviteCode(
                            tournamentId: tournament.id,
                            teamId: _selectedTeamId!,
                            inviteCode: inputCode,
                          );

                          if (kDebugMode) {
                            print('🔍 [InviteCode] API result: $result');
                          }

                          if (!mounted) return;
                          AppLoading.dismissDialog(parentContext);

                          if (result == null) {
                            AppDialogs.showError(
                              parentContext,
                              message: 'Invalid invite code. Please try again.',
                            );
                            return;
                          }

                          ref.invalidate(myTournamentRegistrationsProvider);

                          await AppDialogs.showSuccess(
                            parentContext,
                            title: 'Registration Successful!',
                            message:
                                'You have successfully registered for ${tournament.name}.',
                          );

                          if (!mounted) return;

                          Navigator.of(parentContext).pop();
                        } catch (e) {
                          if (mounted) {
                            AppLoading.dismissDialog(parentContext);
                            AppDialogs.showError(
                              parentContext,
                              message:
                                  e.toString().replaceAll('Exception: ', ''),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateTeamDialog() async {
    // Fetch current tournament data
    final tournament =
        await ref.read(tournamentDetailsProvider(widget.tournamentId).future);
    if (tournament == null) return;

    final teamNameController = TextEditingController();
    final captainContactController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => GenericFormDialog(
          title: 'Create Team',
          subtitle: "You've add a new Team! Add Teammates to your team.",
          submitLabel: isLoading ? 'Saving...' : 'Save',
          showAvatars: true,
          fields: [
            AppTextFieldWithLabel(
              controller: teamNameController,
              label: 'Team Name',
              hintText: 'Team Name',
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            AppTextFieldWithLabel(
              controller: captainContactController,
              label: 'Captain Email/Mobile No.',
              hintText: 'Captain Email/Mobile No.',
            ),
          ],
          onSubmit: isLoading
              ? null
              : () async {
                  final teamName = teamNameController.text.trim();
                  final captainContact = captainContactController.text.trim();

                  if (teamName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter team name')),
                    );
                    return;
                  }

                  setDialogState(() => isLoading = true);

                  try {
                    final dataSource =
                        ref.read(tournamentsRemoteDataSourceProvider);

                    int? captainUserId;
                    if (captainContact.isNotEmpty) {
                      final users =
                          await dataSource.searchUserByQuery(captainContact);
                      if (users.isEmpty) {
                        setDialogState(() => isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Captain not found. Please check email/mobile.',
                              ),
                            ),
                          );
                        }
                        return;
                      }
                      captainUserId = users.first['id'] as int?;
                    }

                    final result = await dataSource.saveTournamentTeam(
                      tournamentId: tournament.id,
                      name: teamName,
                      captainUserId: captainUserId,
                    );

                    if (!mounted) return;

                    final teamId = result?['id'] as int?;

                    if (teamId == null) {
                      setDialogState(() => isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to create team: No ID returned',
                            ),
                          ),
                        );
                      }
                      return;
                    }

                    Navigator.pop(dialogContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateTeamPage(
                          tournament: tournament,
                          openDialogOnStart: true,
                          teamId: teamId,
                        ),
                      ),
                    );
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to create team: ${e.toString().replaceAll('Exception: ', '')}',
                          ),
                        ),
                      );
                    }
                  }
                },
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a team first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fetch current tournament data
    final tournament =
        await ref.read(tournamentDetailsProvider(widget.tournamentId).future);
    if (tournament == null) return;

    if (_canRegister == true) {
      // Open registration - directly register the selected team
      AppLoading.showDialog(
        context,
        message: 'Registering team...',
      );

      try {
        final dataSource = ref.read(tournamentsRemoteDataSourceProvider);
        final result = await dataSource.saveTournamentRegistrations(
          teamId: _selectedTeamId!,
          tournamentId: tournament.id,
        );

        if (kDebugMode) {
          print('🔍 [Registration] API result: $result');
        }

        if (!mounted) return;
        AppLoading.dismissDialog(context);

        ref.invalidate(myTournamentsProvider);

        await AppDialogs.showSuccess(
          context,
          title: 'Registration Successful!',
          message: 'Your team has been registered for ${tournament.name}.',
        );

        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          AppLoading.dismissDialog(context);
          AppDialogs.showError(
            context,
            message: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    } else {
      // Invite-only registration - show invite code dialog
      _showInviteCodeDialog();
    }
  }

  Widget _buildCollapsibleHeader(
      BuildContext context, TournamentModel tournament) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    _maxHeaderHeight = AppResponsive.sh(context, 340);

    final collapsedHeaderHeight = _minAppBarHeight + statusBarHeight;
    final expandedHeaderHeight = _maxHeaderHeight;
    final currentHeaderHeight = expandedHeaderHeight -
        (expandedHeaderHeight - collapsedHeaderHeight) * _headerOffset;

    final currentSponsorsHeight = _sponsorsHeight * (1 - _headerOffset);

    final heroContentOpacity = (1 - _headerOffset * 1.5).clamp(0.0, 1.0);

    final appBarBgOpacity = _headerOffset;

    final titleOpacity = ((_headerOffset - 0.5) * 2).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          height: currentHeaderHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: heroContentOpacity,
                  child: _HeroImageSection(tournament: tournament),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: collapsedHeaderHeight,
                child: Opacity(
                  opacity: appBarBgOpacity,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: statusBarHeight + AppResponsive.s(context, 12),
                left: AppResponsive.s(context, 16),
                child: const AppBackButton(
                  isTransparent: false,
                ),
              ),
              Positioned(
                top: statusBarHeight + AppResponsive.s(context, 12),
                left: AppResponsive.s(context, 80),
                right: AppResponsive.s(context, 16),
                height: AppResponsive.s(context, 48),
                child: Opacity(
                  opacity: titleOpacity,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tournament.name,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 18),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          height: currentSponsorsHeight,
          child: Opacity(
            opacity: heroContentOpacity,
            child: ClipRect(
              child: OverflowBox(
                maxHeight:
                    _sponsorsHeight > 0 ? _sponsorsHeight : double.infinity,
                alignment: Alignment.topCenter,
                child: KeyedSubtree(
                  key: _sponsorsKey,
                  child: _SponsorsSection(
                    tournament: tournament,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent(
      BuildContext context, TournamentModel tournament) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: _expandedTotalHeight),
      child: Column(
        children: [
          _ContentSection(tournament: tournament),
          SizedBox(height: AppResponsive.sh(context, 120)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _measureSponsorsHeight();

    if (kDebugMode) {
      print(
          '📄 [TournamentDetailPage] Building detail page for tournament ID: ${widget.tournamentId}');
    }

    final tournamentAsync =
        ref.watch(tournamentDetailsProvider(widget.tournamentId));

    return tournamentAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Loading content
            Positioned.fill(
              child: Column(
                children: [
                  // Status bar padding
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  // Header space for back button
                  SizedBox(height: AppResponsive.s(context, 72)),
                  // Loading indicator in center
                  Expanded(
                    child: Center(
                      child: AppLoading.center(
                        message: "Loading tournament details...",
                      ),
                    ),
                  ),
                  // Footer space for button
                  SizedBox(height: AppResponsive.sh(context, 120)),
                ],
              ),
            ),
            // Header with back button
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  AppResponsive.s(context, 12),
              left: AppResponsive.s(context, 16),
              child: const AppBackButton(
                isTransparent: false,
              ),
            ),
            // Footer with disabled button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: AppResponsive.padding(
                    context,
                    horizontal: 20,
                    top: 8,
                    bottom: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Opacity(
                    opacity: 0.5,
                    child: AppButton(
                      text: 'Loading...',
                      onPressed: null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const AppBackButton(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppResponsive.icon(context, 64),
                color: Colors.red,
              ),
              AppResponsive.verticalSpace(context, 16),
              Text(
                'Failed to load tournament details',
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 16),
                  color: Colors.grey.shade600,
                ),
              ),
              AppResponsive.verticalSpace(context, 8),
              Text(
                error.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 14),
                  color: Colors.grey.shade500,
                ),
              ),
              AppResponsive.verticalSpace(context, 24),
              AppButton(
                text: 'Try Again',
                onPressed: () {
                  ref.invalidate(
                      tournamentDetailsProvider(widget.tournamentId));
                },
              ),
            ],
          ),
        ),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const AppBackButton(),
            ),
            body: Center(
              child: Text(
                'Tournament not found',
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 16),
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
        }

        // Check registration status when tournament loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isLoading) {
            _checkRegistrationStatus(tournament);
          }
        });

        return _buildTournamentDetail(context, tournament);
      },
    );
  }

  Widget _buildTournamentDetail(
      BuildContext context, TournamentModel tournament) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildScrollableContent(context, tournament),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCollapsibleHeader(context, tournament),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: AppResponsive.padding(
                  context,
                  horizontal: 20,
                  top: 8,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _isRegistrationClosed
                        ? Container(
                            padding: AppResponsive.padding(
                              context,
                              all: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  AppResponsive.borderRadius(context, 16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  color: Colors.grey.shade600,
                                  size: AppResponsive.icon(context, 24),
                                ),
                                SizedBox(width: AppResponsive.s(context, 12)),
                                Text(
                                  'Registration Closed',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TeamSelectionDropdown(
                                selectedTeamId: _selectedTeamId,
                                onTeamSelected: (teamId) {
                                  setState(() {
                                    _selectedTeamId = teamId;
                                  });
                                },
                                onCreateTeam: _showCreateTeamDialog,
                              ),
                              SizedBox(height: AppResponsive.s(context, 12)),
                              AppButton(
                                text: _canRegister == true
                                    ? "Register Now • INR${tournament.feesAmount.toStringAsFixed(0)}"
                                    : "Submit Invite Code",
                                onPressed: _handleRegister,
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageSection extends ConsumerWidget {
  const _HeroImageSection({required this.tournament});

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.read(tournamentsDataSourceProvider);
    final imageUrl =
        tournament.imageFile != null && tournament.imageFile!.isNotEmpty
            ? dataSource.getTournamentImageUrl(tournament.imageFile)
            : '';

    return SizedBox(
      height: AppResponsive.sh(context, 340),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        AppLoading.imagePlaceholderDark(
                      backgroundColor: const Color(0xFF1A3A3A),
                      indicatorSize: AppResponsive.icon(context, 24),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF1A3A3A),
                      child: Center(
                        child: Icon(
                          Icons.sports,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: AppResponsive.icon(context, 60),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1A3A3A),
                    child: Center(
                      child: Icon(
                        Icons.sports,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: AppResponsive.icon(context, 60),
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppResponsive.s(context, 16),
            left: AppResponsive.s(context, 20),
            right: AppResponsive.s(context, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: AppResponsive.paddingSymmetric(
                    context,
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppResponsive.borderRadius(context, 16),
                  ),
                  child: Text(
                    _capitalize(tournament.sport),
                    style: TextStyle(
                      fontSize: AppResponsive.font(context, 12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppResponsive.verticalSpace(context, 10),
                Text(
                  _capitalize(tournament.name),
                  style: TextStyle(
                    fontSize: AppResponsive.font(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                AppResponsive.verticalSpace(context, 8),
                tournament.openOrClose
                    ? Text(
                        'INR ${tournament.feesAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: AppResponsive.font(context, 17),
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.tournament,
  });

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: AppResponsive.padding(
          context,
          horizontal: 20,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCardsContainer(tournament: tournament),
            AppResponsive.verticalSpace(context, 28),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'ABOUT TOURNAMENT'),
                  AppResponsive.verticalSpace(context, 10),
                  Text(
                    tournament.description.isNotEmpty
                        ? tournament.description
                        : 'Join the most prestigious ${tournament.sport} tournament of the season. Experience world-class competition and connect with elite players.',
                    style: TextStyle(
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5C5C5C),
                    ),
                  ),
                ],
              ),
            ),
            AppResponsive.verticalSpace(context, 16),
            AppResponsive.verticalSpace(context, 16),
            _SectionIconCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionWithIconInline(
                    icon: AppAssets.trophyIcon,
                    iconColor: Colors.white,
                    title: 'SCORING STRUCTURE',
                  ),
                  Transform.translate(
                    offset: Offset(0, AppResponsive.s(context, -2)),
                    child: Text(
                      'Best of 3 sets, Rally scoring to 21 points',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5C5C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppResponsive.verticalSpace(context, 16),
            AppResponsive.verticalSpace(context, 16),
            _SectionIconCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionWithIconInline(
                    icon: Icons.description_outlined,
                    iconColor: Colors.white,
                    title: 'EQUIPMENT REQUIRED',
                  ),
                  Transform.translate(
                    offset: Offset(0, AppResponsive.s(context, -2)),
                    child: Text(
                      tournament.equipmentsRequired?.isNotEmpty == true
                          ? tournament.equipmentsRequired!
                          : 'Racket, Shuttlecock provided',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5C5C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppResponsive.verticalSpace(context, 16),
            AppResponsive.verticalSpace(context, 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'RULES & REGULATIONS'),
                  AppResponsive.verticalSpace(context, 16),
                  if (tournament.rules != null && tournament.rules!.isNotEmpty)
                    Text(
                      tournament.rules!,
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 14),
                        height: 1.4,
                        color: const Color(0xFF616161),
                      ),
                    )
                  else ...[
                    const _RuleItem(
                      text: 'Players must arrive 30 minutes before match time',
                    ),
                    AppResponsive.verticalSpace(context, 14),
                    const _RuleItem(text: 'Professional attire required'),
                    AppResponsive.verticalSpace(context, 14),
                    const _RuleItem(text: 'Valid ID must be presented'),
                    AppResponsive.verticalSpace(context, 14),
                    const _RuleItem(
                      text: 'Substitutions not allowed after registration',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(context, horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppResponsive.s(context, 16),
            offset: Offset(0, AppResponsive.s(context, 4)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionIconCard extends StatelessWidget {
  const _SectionIconCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(context, horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppResponsive.s(context, 16),
            offset: Offset(0, AppResponsive.s(context, 4)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoCardsContainer extends StatelessWidget {
  const _InfoCardsContainer({required this.tournament});

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context) {
    final registeredCount = tournament.currentRegistered;
    final progress = tournament.maximumRegistrationsCount > 0
        ? registeredCount / tournament.maximumRegistrationsCount
        : 0.0;

    return Container(
      padding: AppResponsive.padding(context, horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppResponsive.s(context, 16),
            offset: Offset(0, AppResponsive.s(context, 4)),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: AppAssets.calendarIcon,
            iconColor: AppColors.accentBlue,
            title: 'Registration Start Date & End Date',
            subtitle: _formatDateRange(
              tournament.registrationStartDate,
              tournament.registrationCloseDate,
            ),
          ),
          AppResponsive.verticalSpace(context, 20),
          _InfoRow(
            icon: AppAssets.calendarIcon,
            iconColor: AppColors.accentBlue,
            title: 'Start Date & Time',
            subtitle: _formatDate(tournament.tournamentDate),
            detail: _formatTime(tournament.tournamentDate).isNotEmpty
                ? '${_formatTime(tournament.tournamentDate)} - ${_formatTime(tournament.tournamentEndDate)}'
                : '',
          ),
          AppResponsive.verticalSpace(context, 20),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.accentBlue,
            title: 'Location',
            subtitle:
                '${_capitalize(tournament.city)}, ${_capitalize(tournament.state)}',
            detail:
                '${_capitalize(tournament.district)}, ${_capitalize(tournament.country)}',
          ),
          AppResponsive.verticalSpace(context, 20),
          Row(
            children: [
              Container(
                width: AppResponsive.s(context, 44),
                height: AppResponsive.s(context, 44),
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  color: Colors.white,
                  size: AppResponsive.icon(context, 22),
                ),
              ),
              AppResponsive.horizontalSpace(context, 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    AppResponsive.verticalSpace(context, 4),
                    Text(
                      '$registeredCount/${tournament.maximumRegistrationsCount} Teams',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 15),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    AppResponsive.verticalSpace(context, 4),
                    AppLoading.linearRounded(
                      value: progress,
                      height: AppResponsive.s(context, 8),
                      borderRadius: AppResponsive.radius(context, 8),
                      color: AppColors.accentBlue,
                      backgroundColor: const Color(0xFFE8EAF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppResponsive.verticalSpace(context, 12),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.detail = '',
  });

  final dynamic icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppResponsive.s(context, 44),
          height: AppResponsive.s(context, 44),
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: icon is IconData
              ? Icon(
                  icon,
                  color: Colors.white,
                  size: AppResponsive.icon(context, 22),
                )
              : Center(
                  child: SvgPicture.asset(
                    icon,
                    width: AppResponsive.icon(context, 22),
                    height: AppResponsive.icon(context, 22),
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
        ),
        AppResponsive.horizontalSpace(context, 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000000),
                ),
              ),
              AppResponsive.verticalSpace(context, 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C5C5C),
                ),
              ),
              if (detail.isNotEmpty) ...[
                AppResponsive.verticalSpace(context, 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w700,
        color: const Color(0xFF000000),
      ),
    );
  }
}

class _SectionWithIconInline extends StatelessWidget {
  const _SectionWithIconInline({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final dynamic icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(AppResponsive.s(context, -8), 0),
      child: Row(
        children: [
          Container(
            width: AppResponsive.s(context, 36),
            height: AppResponsive.s(context, 36),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: icon is IconData
                ? Icon(
                    icon,
                    color: AppColors.accentBlue,
                    size: AppResponsive.icon(context, 20),
                  )
                : Center(
                    child: SvgPicture.asset(
                      icon,
                      width: AppResponsive.icon(context, 20),
                      height: AppResponsive.icon(context, 20),
                      colorFilter: const ColorFilter.mode(
                        AppColors.accentBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppResponsive.s(context, 2)),
          child: SvgPicture.asset(
            'assets/icons/Rule-Tick.svg',
            width: AppResponsive.icon(context, 20),
          ),
        ),
        AppResponsive.horizontalSpace(context, 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 14),
              height: 1.4,
              color: const Color(0xFF616161),
            ),
          ),
        ),
      ],
    );
  }
}

class _SponsorsSection extends ConsumerWidget {
  const _SponsorsSection({
    required this.tournament,
  });

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsData = tournament.tournamentSponsorsList;

    if (kDebugMode) {
      print('👁️ [_SponsorsSection] Building sponsors section');
      print('   Tournament: ${tournament.name}');
      print('   Sponsors count: ${sponsorsData.length}');
      print('   Sponsors data: $sponsorsData');
    }

    if (sponsorsData.isEmpty) {
      if (kDebugMode) {
        print('   ❌ No sponsors - returning empty SizedBox');
      }
      return const SizedBox(height: 0, width: double.infinity);
    }

    return _SponsorsAutoScrollSection(sponsorsData: sponsorsData);
  }
}

class _SponsorsAutoScrollSection extends ConsumerStatefulWidget {
  const _SponsorsAutoScrollSection({required this.sponsorsData});

  final List<dynamic> sponsorsData;

  @override
  ConsumerState<_SponsorsAutoScrollSection> createState() =>
      _SponsorsAutoScrollSectionState();
}

class _SponsorsAutoScrollSectionState
    extends ConsumerState<_SponsorsAutoScrollSection> {
  late PageController _pageController;
  Timer? _timer;
  double _itemWidth = 0;

  @override
  void initState() {
    super.initState();
    int initialPage = 10000;
    if (widget.sponsorsData.isNotEmpty) {
      initialPage = 10000 - (10000 % widget.sponsorsData.length);
    }

    _pageController = PageController(
      viewportFraction: 1 / 3,
      initialPage: initialPage,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - AppResponsive.s(context, 40);
    _itemWidth = availableWidth / 3;

    if (widget.sponsorsData.length > 3 && _timer == null) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    const duration = Duration(seconds: 3);
    _timer = Timer.periodic(duration, (timer) {
      if (_pageController.hasClients) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: AppResponsive.s(context, 10),
          bottom: AppResponsive.s(context, 0),
        ),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: widget.sponsorsData.length <= 3
            ? SizedBox(
                height: AppResponsive.s(context, 90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.sponsorsData.map((sponsor) {
                    final dataSource =
                        ref.read(tournamentsRemoteDataSourceProvider);
                    final imageUrl =
                        dataSource.getSponsorImageUrl(sponsor['imageFile']);

                    return SizedBox(
                      width: _itemWidth,
                      child: Center(
                        child: _SponsorTile(
                          imageUrl: imageUrl,
                          sponsorName: sponsor['name'] ?? '',
                          sponsorType: sponsor['sponsorType'] ?? '',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox(
                height: AppResponsive.s(context, 90),
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final sponsor =
                        widget.sponsorsData[index % widget.sponsorsData.length];
                    final dataSource =
                        ref.read(tournamentsRemoteDataSourceProvider);
                    final imageUrl =
                        dataSource.getSponsorImageUrl(sponsor['imageFile']);

                    return Center(
                      child: _SponsorTile(
                        imageUrl: imageUrl,
                        sponsorName: sponsor['name'] ?? '',
                        sponsorType: sponsor['sponsorType'] ?? '',
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _SponsorTile extends StatelessWidget {
  const _SponsorTile({
    required this.imageUrl,
    required this.sponsorName,
    required this.sponsorType,
  });

  final String imageUrl;
  final String sponsorName;
  final String sponsorType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppResponsive.s(context, 60),
          height: AppResponsive.s(context, 40),
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 8),
          ),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 18,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
        ),
        AppResponsive.verticalSpace(context, 5),
        Text(
          sponsorName.isNotEmpty
              ? sponsorName[0].toUpperCase() +
                  sponsorName.substring(1).toLowerCase()
              : '',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: const Color(0xFF5C5C5C),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          sponsorType.isNotEmpty
              ? "(${sponsorType[0].toUpperCase()}${sponsorType.substring(1).toLowerCase()})"
              : '',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.accentBlue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Team Selection Dropdown Widget
class _TeamSelectionDropdown extends ConsumerWidget {
  const _TeamSelectionDropdown({
    required this.selectedTeamId,
    required this.onTeamSelected,
    required this.onCreateTeam,
  });

  final int? selectedTeamId;
  final ValueChanged<int?> onTeamSelected;
  final VoidCallback onCreateTeam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(managerTeamsListProvider);

    return teamsAsync.when(
      data: (teams) {
        // Filter out deleted teams and only show active ones
        final activeTeams =
            teams.where((team) => !team.deleted && team.status).toList();

        if (activeTeams.isEmpty) {
          return Container(
            padding: AppResponsive.padding(context, all: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: AppResponsive.borderRadius(context, 16),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentBlue,
                  size: AppResponsive.icon(context, 20),
                ),
                SizedBox(width: AppResponsive.s(context, 12)),
                Expanded(
                  child: Text(
                    'No teams available. Create a team first.',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onCreateTeam,
                  child: Text(
                    'Create',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Find the selected team from the list
        final selectedTeam = selectedTeamId != null
            ? activeTeams.firstWhere(
                (team) => team.id == selectedTeamId,
                orElse: () => activeTeams.first,
              )
            : null;

        return AppDropdown(
          label: 'Select Team',
          hint: 'Select a Team',
          items: activeTeams,
          value: selectedTeam,
          onChanged: (team) => onTeamSelected(team?.id),
          itemLabel: (team) => team.name,
          prefixIcon: Icons.groups_outlined,
          enabled: true,
        );
      },
      loading: () => Container(
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: AppResponsive.borderRadius(context, 16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppResponsive.s(context, 20),
              height: AppResponsive.s(context, 20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 12)),
            Text(
              'Loading teams...',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: AppResponsive.borderRadius(context, 16),
          border: Border.all(
            color: Colors.red.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: AppResponsive.icon(context, 20),
            ),
            SizedBox(width: AppResponsive.s(context, 12)),
            Expanded(
              child: Text(
                'Failed to load teams',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  color: Colors.red.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: onCreateTeam,
              child: Text(
                'Create',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

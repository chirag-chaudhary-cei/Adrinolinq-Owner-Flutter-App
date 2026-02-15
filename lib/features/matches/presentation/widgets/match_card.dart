import 'package:flutter/material.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';

class MatchCard extends StatelessWidget {
  final bool isLive;
  final String player1Name;
  final String player2Name;
  final String player1Section;
  final String player2Section;
  final String? score;
  final String? dateTime;
  final String court;
  final String roundOrSet;
  final String? matchStatus;
  final String? tieSheetStatus;

  const MatchCard({
    super.key,
    required this.isLive,
    required this.player1Name,
    required this.player2Name,
    required this.player1Section,
    required this.player2Section,
    this.score,
    this.dateTime,
    required this.court,
    required this.roundOrSet,
    this.matchStatus,
    this.tieSheetStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppResponsive.padding(
        context,
        horizontal: 16,
        vertical: 8,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFBDD7F5),
            Color(0xFF67A9F4),
            Color(0xFF1377E8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppResponsive.s(context, 33)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: AppResponsive.padding(
              context,
              horizontal: 26,
              vertical: 1,
              top: 45,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPlayerColumn(context, player1Name, player1Section),
                    Expanded(
                      child: Column(
                        children: [
                          if (isLive) ...[
                            Text(
                              score ?? "00 : 00",
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 32),
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 4)),
                            Text(
                              court,
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 12),
                                color: const Color(0xFF454545),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "VS",
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 24),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 4)),
                            Text(
                              dateTime ?? "",
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 8)),
                            GestureDetector(
                              onTap: () => _showSelectCourtDialog(context),
                              child: Container(
                                padding: AppResponsive.padding(
                                  context,
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Select Court",
                                      style: TextStyle(
                                        fontFamily: 'SFProRounded',
                                        fontSize:
                                            AppResponsive.font(context, 10),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: AppResponsive.icon(context, 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildPlayerColumn(context, player2Name, player2Section),
                  ],
                ),
                SizedBox(height: AppResponsive.s(context, 20)),
                if (isLive)
                  Container(
                    width: double.infinity,
                    padding: AppResponsive.padding(context, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(33),
                    ),
                    child: Text(
                      "Watch Live",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  )
                else if (tieSheetStatus != null)
                  Container(
                    width: double.infinity,
                    padding: AppResponsive.padding(
                      context,
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(33),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tie sheet",
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        _buildTieSheetStatus(context, tieSheetStatus!),
                      ],
                    ),
                  ),
                if (isLive || tieSheetStatus != null)
                  SizedBox(height: AppResponsive.s(context, 10)),
              ],
            ),
          ),
          Positioned(
            top: AppResponsive.s(context, 16),
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  roundOrSet,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 15),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isLive)
            Positioned(
              top: AppResponsive.s(context, 16),
              right: AppResponsive.s(context, 16),
              child: Container(
                padding:
                    AppResponsive.padding(context, horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDB0C00),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppResponsive.s(context, 4)),
                    Text(
                      "Live",
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 12),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (matchStatus != null)
            Positioned(
              top: AppResponsive.s(context, 16),
              right: AppResponsive.s(context, 16),
              child: _buildMatchStatusBadge(context, matchStatus!),
            ),
        ],
      ),
    );
  }

  void _showSelectCourtDialog(BuildContext context) {
    final courts = ['Court 1', 'Court 2', 'Court 3', 'Court 4'];
    String? selectedCourt;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => GenericFormDialog(
          title: "Select Court",
          subtitle: "Choose a court for this match",
          submitLabel: "Save",
          onSubmit: () {
            Navigator.pop(context);
          },
          fields: [
            AppDropdown<String>(
              label: "Select Court",
              value: selectedCourt,
              items: courts,
              itemLabel: (court) => court,
              hint: "Choose a court",
              onChanged: (court) {
                setState(() {
                  selectedCourt = court;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerColumn(BuildContext context, String name, String section) {
    return Column(
      children: [
        SizedBox(height: AppResponsive.s(context, 8)),
        CircleAvatar(
          backgroundImage: const AssetImage('assets/images/profileimg.jpg'),
          radius: AppResponsive.s(context, 30),
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          section,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF454545),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchStatusBadge(BuildContext context, String status) {
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = const Color(0xFF3AA318);
        break;
      case 'abandoned':
        bgColor = const Color(0xFF5C5C5C);
        break;
      case 'pending':
        bgColor = const Color(0xFFC8D723);
        break;
      default:
        bgColor = const Color(0xFFCCFF00);
    }

    return Container(
      padding: AppResponsive.padding(context, horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: AppResponsive.font(context, 12),
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTieSheetStatus(BuildContext context, String status) {
    Color textColor;
    IconData? icon;
    Color? iconColor;

    switch (status.toLowerCase()) {
      case 'approved':
        textColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'denied':
        textColor = const Color(0xFFDB0C00);
        icon = Icons.error;
        iconColor = const Color(0xFFDB0C00);
        break;
      case 'pending':
        textColor = const Color(0xFF9E9E9E);
        icon = null;
        break;
      default:
        textColor = const Color(0xFF9E9E9E);
        icon = null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppResponsive.icon(context, 18), color: iconColor),
          SizedBox(width: AppResponsive.s(context, 6)),
        ],
        Text(
          status,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 14),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

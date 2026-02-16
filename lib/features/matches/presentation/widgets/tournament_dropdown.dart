import 'package:flutter/material.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../home/data/models/tournament_model.dart';

/// A specialized dropdown widget for tournament selection
class TournamentDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final int? value;
  final List<TournamentModel> tournaments;
  final ValueChanged<int?> onChanged;
  final IconData? icon;
  final bool enabled;
  final bool isLoading;

  const TournamentDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.tournaments,
    required this.onChanged,
    this.value,
    this.icon,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTournament = value != null
        ? tournaments.firstWhere(
            (t) => t.id == value,
            orElse: () => tournaments.first,
          )
        : null;

    return AppDropdown<TournamentModel>(
      label: label,
      value: selectedTournament,
      items: tournaments,
      itemLabel: (tournament) => tournament.name,
      hint: hint,
      enabled: enabled && !isLoading,
      isLoading: isLoading,
      prefixIcon: icon,
      borderRadius: 46,
      onChanged: (tournament) => onChanged(tournament?.id),
    );
  }
}

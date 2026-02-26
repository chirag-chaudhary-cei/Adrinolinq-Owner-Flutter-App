/// Data model representing a single bid in the player auction.
class BidModel {
  final int points;
  final String teamName;
  final String ownerName;
  final String timestamp;

  const BidModel({
    required this.points,
    required this.teamName,
    required this.ownerName,
    required this.timestamp,
  });
}

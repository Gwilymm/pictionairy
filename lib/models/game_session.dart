class GameSession {
  final String id;
  final int gameStarterId;
  final List<String> redTeamPlayers;
  final List<String> blueTeamPlayers;

  GameSession({
    required this.id,
    required this.gameStarterId,
    this.redTeamPlayers = const [],
    this.blueTeamPlayers = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameStarterId': gameStarterId,
    'redTeamPlayers': redTeamPlayers,
    'blueTeamPlayers': blueTeamPlayers,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'].toString(),
      gameStarterId: json['gameStarterId'],
      redTeamPlayers: List<String>.from(json['redTeamPlayers'] ?? []),
      blueTeamPlayers: List<String>.from(json['blueTeamPlayers'] ?? []),
    );
  }
}

class GameSession {
  final String sessionId;
  final List<String> redTeamPlayers;
  final List<String> blueTeamPlayers;

  GameSession({
    required this.sessionId,
    required this.redTeamPlayers,
    required this.blueTeamPlayers,
  });

  // Factory method to create a GameSession instance from JSON
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['session_id'] as String,
      redTeamPlayers: List<String>.from(json['red_team_players']),
      blueTeamPlayers: List<String>.from(json['blue_team_players']),
    );
  }

  // Method to convert GameSession instance to JSON (if needed for serialization)
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'red_team_players': redTeamPlayers,
      'blue_team_players': blueTeamPlayers,
    };
  }
}

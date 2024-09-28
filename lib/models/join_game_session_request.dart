class JoinGameSessionRequest {
  final String color; // either 'red' or 'blue'

  JoinGameSessionRequest({
    required this.color,
  });

  // Method to convert JoinGameSessionRequest instance to JSON for API call
  Map<String, dynamic> toJson() {
    return {
      'color': color,
    };
  }
}

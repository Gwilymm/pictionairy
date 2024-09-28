class Player {
  final String id;
  final String name;

  Player({
    required this.id,
    required this.name,
  });

  // Factory method to create a Player instance from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // Method to convert Player instance to JSON (if needed for serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
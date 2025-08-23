class SelectedRoom {
  final String name;
  final double pricePerNight;
  final int maxAdults;
  final int maxChildren;
  final String imageUrl;
  final List<String> amenities;

  const SelectedRoom({
    required this.name,
    required this.pricePerNight,
    required this.maxAdults,
    required this.maxChildren,
    required this.imageUrl,
    required this.amenities,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pricePerNight': pricePerNight,
      'maxAdults': maxAdults,
      'maxChildren': maxChildren,
      'imageUrl': imageUrl,
      'amenities': amenities,
    };
  }

  factory SelectedRoom.fromJson(Map<String, dynamic> json) {
    return SelectedRoom(
      name: json['name'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      maxAdults: json['maxAdults'] as int,
      maxChildren: json['maxChildren'] as int,
      imageUrl: json['imageUrl'] as String,
      amenities: List<String>.from(json['amenities'] as List),
    );
  }

  @override
  String toString() {
    return 'SelectedRoom(name: $name, pricePerNight: $pricePerNight, maxAdults: $maxAdults, maxChildren: $maxChildren)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedRoom &&
        other.name == name &&
        other.pricePerNight == pricePerNight &&
        other.maxAdults == maxAdults &&
        other.maxChildren == maxChildren &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        pricePerNight.hashCode ^
        maxAdults.hashCode ^
        maxChildren.hashCode ^
        imageUrl.hashCode;
  }
}

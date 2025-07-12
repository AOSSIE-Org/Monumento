class TripPreferences {
  final int duration;
  final double budget;
  final String tripType;
  final List<String> interests;
  final String location;
  final String accommodation;
  final String transportation;

  TripPreferences({
    required this.duration,
    required this.budget,
    required this.tripType,
    required this.interests,
    required this.location,
    required this.accommodation,
    required this.transportation,
  });

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'budget': budget,
        'tripType': tripType,
        'interests': interests,
        'location': location,
        'accommodation': accommodation,
        'transportation': transportation,
      };
}

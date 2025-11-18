class ItineraryDay {
  final int day;
  final List<Activity> activities;
  final double estimatedCost;

  ItineraryDay({
    required this.day,
    required this.activities,
    required this.estimatedCost,
  });
}

class Activity {
  final String name;
  final String description;
  final String timeSlot;
  final double cost;
  final String category;
  final String location;

  Activity({
    required this.name,
    required this.description,
    required this.timeSlot,
    required this.cost,
    required this.category,
    required this.location,
  });
}

class GeneratedItinerary {
  final String title;
  final List<ItineraryDay> days;
  final double totalCost;
  final String overview;

  GeneratedItinerary({
    required this.title,
    required this.days,
    required this.totalCost,
    required this.overview,
  });
}

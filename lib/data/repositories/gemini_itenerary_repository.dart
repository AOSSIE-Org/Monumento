import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:monumento/data/models/itenerary_day_model.dart';
import 'package:monumento/data/models/trip_prefrences_model.dart';

class GeminiItineraryRepo {
  late final GenerativeModel _model;

  GeminiItineraryRepo(String apiKey) {
    _model = GenerativeModel(
      model: "gemini-2.0-flash",
      apiKey: apiKey,
    );
  }

  Future<GeneratedItinerary> generateItinerary(
      TripPreferences preferences) async {
    final prompt = _buildPrompt(preferences);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseItineraryResponse(response.text ?? '');
    } catch (e) {
      throw Exception('Failed to generate itinerary: $e');
    }
  }

  String _buildPrompt(TripPreferences preferences) {
    return '''
Create a detailed travel itinerary for monuments and cultural sites with the following specifications:

Location: ${preferences.location}
Duration: ${preferences.duration} days
Budget: \$${preferences.budget}
Trip Type: ${preferences.tripType}
Interests: ${preferences.interests.join(', ')}
Accommodation: ${preferences.accommodation}
Transportation: ${preferences.transportation}

Please provide a JSON response with the following structure:
{
  "title": "Trip title",
  "overview": "Brief overview of the trip",
  "totalCost": estimated_total_cost,
  "days": [
    {
      "day": 1,
      "estimatedCost": daily_cost,
      "activities": [
        {
          "name": "Activity name",
          "description": "Activity description", 
          "timeSlot": "9:00 AM - 11:00 AM",
          "cost": activity_cost,
          "category": "Monument/Museum/Cultural",
          "location": "Specific location"
        }
      ]
    }
  ]
}

Focus on monuments, historical sites, museums, and cultural experiences. Include realistic costs and time slots. Ensure the total stays within the budget.
''';
  }

  GeneratedItinerary _parseItineraryResponse(String response) {
    try {
      String jsonStr = response;
      if (response.contains('```json')) {
        jsonStr = response.split('```json')[1].split('```')[0].trim();
      } else if (response.contains('```')) {
        jsonStr = response.split('```')[1].split('```')[0].trim();
      }

      final data = json.decode(jsonStr);

      List<ItineraryDay> days = (data['days'] as List).map((dayData) {
        List<Activity> activities =
            (dayData['activities'] as List).map((actData) {
          return Activity(
            name: actData['name'] ?? '',
            description: actData['description'] ?? '',
            timeSlot: actData['timeSlot'] ?? '',
            cost: (actData['cost'] ?? 0).toDouble(),
            category: actData['category'] ?? '',
            location: actData['location'] ?? '',
          );
        }).toList();

        return ItineraryDay(
          day: dayData['day'] ?? 0,
          activities: activities,
          estimatedCost: (dayData['estimatedCost'] ?? 0).toDouble(),
        );
      }).toList();

      return GeneratedItinerary(
        title: data['title'] ?? 'Your Monument Trip',
        overview: data['overview'] ?? '',
        totalCost: (data['totalCost'] ?? 0).toDouble(),
        days: days,
      );
    } catch (e) {
      throw Exception('Failed to parse itinerary response: $e');
    }
  }
}

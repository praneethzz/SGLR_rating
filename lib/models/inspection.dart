class InspectionResult {
  final String resortName;
  final String area;
  final int resortId;
  final DateTime dateTime;
  final Map<String, bool> checklistAnswers;
  final int totalMarks;
  final int maxMarks;
  final int starRating;
  final String notes;

  InspectionResult({
    required this.resortName,
    required this.area,
    required this.resortId,
    required this.dateTime,
    required this.checklistAnswers,
    required this.totalMarks,
    required this.maxMarks,
    required this.starRating,
    required this.notes,
  });

  // Returns percentage score
  double get percentage => (totalMarks / maxMarks) * 100;

  // Derives star rating from marks out of 200
  static int calculateStars(int marks) {
    if (marks >= 170) return 5;
    if (marks >= 130) return 4;
    if (marks >= 90) return 3;
    if (marks >= 50) return 2;
    return 1;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'resortName': resortName,
      'area': area,
      'resortId': resortId,
      'dateTime': dateTime.toIso8601String(),
      'checklistAnswers': checklistAnswers,
      'totalMarks': totalMarks,
      'maxMarks': maxMarks,
      'starRating': starRating,
      'notes': notes,
    };
  }

  // Create from JSON for retrieval
  factory InspectionResult.fromJson(Map<String, dynamic> json) {
    return InspectionResult(
      resortName: json['resortName'] as String,
      area: json['area'] as String,
      resortId: json['resortId'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      checklistAnswers: Map<String, bool>.from(json['checklistAnswers']),
      totalMarks: json['totalMarks'] as int,
      maxMarks: json['maxMarks'] as int,
      starRating: json['starRating'] as int,
      notes: json['notes'] as String,
    );
  }
}

class InspectionResult {
  final String resortName;
  final String area;
  final DateTime dateTime;
  final Map<String, bool> checklistAnswers;
  final int totalMarks;
  final int maxMarks;
  final int starRating;
  final String notes;

  InspectionResult({
    required this.resortName,
    required this.area,
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
}
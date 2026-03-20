import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inspection.dart';

class StorageService {
  // ── Key helpers ──────────────────────────────────────────────────────
  static String _statusKey(int id) => 'resort_status_$id';
  static String _draftKey(int id) => 'draft_answers_$id';
  static String _resultKey(int id) => 'inspection_result_$id';

  // ── Resort Status ─────────────────────────────────────────────────────

  // Returns 'unrated', 'pending', or 'approved'
  static Future<String> getResortStatus(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_statusKey(resortId)) ?? 'unrated';
  }

  // Sets the status for a resort
  static Future<void> setResortStatus(int resortId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey(resortId), status);
  }

  // ── Draft Management ──────────────────────────────────────────────────

  // Saves checklist answers as a draft
  static Future<void> saveDraft(int resortId, Map<String, bool> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(answers);
    await prefs.setString(_draftKey(resortId), encoded);
  }

  // Loads a saved draft — returns null if no draft exists
  static Future<Map<String, bool>?> loadDraft(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey(resortId));
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as bool));
  }

  // Deletes the draft for a resort
  static Future<void> clearDraft(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey(resortId));
  }

  // ── Inspection Results ────────────────────────────────────────────────

  // Saves the full InspectionResult to storage
  static Future<void> saveInspectionResult(
    int resortId,
    InspectionResult result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(result.toJson());
    await prefs.setString(_resultKey(resortId), encoded);
  }

  // Loads and returns the saved InspectionResult — null if not found
  static Future<InspectionResult?> loadInspectionResult(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resultKey(resortId));
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return InspectionResult.fromJson(decoded);
  }

  // ── District Committee Actions ────────────────────────────────────────

  // Returns all resort IDs with status 'pending'
  static Future<List<int>> getPendingResortIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final pendingIds = <int>[];
    for (final key in keys) {
      if (key.startsWith('resort_status_')) {
        final value = prefs.getString(key);
        if (value == 'pending') {
          final idStr = key.replaceFirst('resort_status_', '');
          final id = int.tryParse(idStr);
          if (id != null) pendingIds.add(id);
        }
      }
    }
    return pendingIds;
  }

  // Approves an inspection — freezes the rating
  static Future<void> approveInspection(int resortId) async {
    await setResortStatus(resortId, 'approved');
  }

  // Unfreezes an approved inspection — sets back to pending
  static Future<void> unfreezeInspection(int resortId) async {
    await setResortStatus(resortId, 'pending');
  }

  // Completely removes all data for a resort — back to unrated
  static Future<void> removeInspection(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statusKey(resortId));
    await prefs.remove(_resultKey(resortId));
    await prefs.remove(_draftKey(resortId));
  }

  // Sends back for reevaluation — resets everything
  static Future<void> sendForReevaluation(int resortId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statusKey(resortId));
    await prefs.remove(_resultKey(resortId));
    await prefs.remove(_draftKey(resortId));
  }
}

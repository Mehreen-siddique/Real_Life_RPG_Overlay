import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'package:real_life_rpg/Models/daily_health_data.dart';

class HealthDataSummary {
  final int steps;
  final double distanceKm;
  final double calories;
  final double sleepHours;
  final List<String> workoutTypes;
  final int activeMinutes;
  final bool hasCycling;
  final DateTime fetchedAt;

  HealthDataSummary({
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.sleepHours,
    required this.workoutTypes,
    required this.activeMinutes,
    required this.hasCycling,
    required this.fetchedAt,
  });

  factory HealthDataSummary.empty() => HealthDataSummary(
        steps: 0, distanceKm: 0.0, calories: 0.0, sleepHours: 0.0,
        workoutTypes: [], activeMinutes: 0, hasCycling: false, fetchedAt: DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'steps': steps, 'distanceKm': distanceKm, 'calories': calories,
        'sleepHours': sleepHours, 'workoutTypes': workoutTypes,
        'exerciseMinutes': activeMinutes, 'hasCycling': hasCycling, 'fetchedAt': fetchedAt,
      };
}

class HealthConnectService {
  static final HealthConnectService _instance = HealthConnectService._internal();
  factory HealthConnectService() => _instance;
  HealthConnectService._internal();

  final Health _health = Health();
  bool _isConfigured = false;
  bool _isAuthorized = false;

  /// Configure and initialize Health Connect.
  /// Must be called before any other method.
  Future<void> initialize() async {
    try {
      // Step 1: Configure the plugin
      if (!_isConfigured) {
        debugPrint('[HEALTH] Configuring Health plugin...');
        await _health.configure();
        _isConfigured = true;
        debugPrint('[HEALTH] Health plugin configured.');
      }

      // Step 2: Check Health Connect availability
      debugPrint('[HEALTH] Checking Health Connect availability...');
      final isAvailable = await _health.isHealthConnectAvailable();
      debugPrint('[HEALTH] Health Connect Available: $isAvailable');

      if (!isAvailable) {
        debugPrint('[HEALTH] Health Connect NOT available. Prompting install...');
        await _health.installHealthConnect();
        debugPrint('[HEALTH] installHealthConnect() called. User must install from Play Store.');
        return;
      }

      // Step 3: Request authorization
      await _requestAuthorization();

      debugPrint('[HEALTH] Initialization complete. Authorized: $_isAuthorized');
    } catch (e) {
      debugPrint('[HEALTH] ERROR during initialization: $e');
      rethrow;
    }
  }

  /// Map to track which permissions are granted
  Map<HealthDataType, bool> _permissionStatus = {};
  Map<HealthDataType, bool> get permissionStatus => Map.unmodifiable(_permissionStatus);

  /// The 6 Health Connect data types that map to manifest permissions:
  /// STEPS → READ_STEPS, HEART_RATE → READ_HEART_RATE,
  /// DISTANCE_DELTA → READ_DISTANCE, ACTIVE_ENERGY_BURNED → READ_ACTIVE_CALORIES_BURNED,
  /// SLEEP_ASLEEP → READ_SLEEP, WORKOUT → READ_EXERCISE
  static const List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
  ];

  /// Request READ permissions for all activity types.
  Future<void> _requestAuthorization() async {
    final types = _readTypes;
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    debugPrint('[HEALTH] ========== REQUESTING AUTHORIZATION ==========');
    debugPrint('[HEALTH] Requesting: ${types.map((t) => t.name).join(', ')}');

    try {
      // Request all permissions at once
      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      debugPrint('[HEALTH] Overall authorization result: $authorized');

      // Check each permission individually
      _permissionStatus.clear();
      debugPrint('[HEALTH] ========== PERMISSION STATUS ==========');
      for (int i = 0; i < types.length; i++) {
        try {
          final hasPermission = await _health.hasPermissions(
            [types[i]],
            permissions: [permissions[i]],
          );
          _permissionStatus[types[i]] = hasPermission ?? false;
          final icon = (hasPermission ?? false) ? '✓' : '✗';
          debugPrint('[HEALTH] $icon ${types[i].name}: ${hasPermission ?? false}');
        } catch (e) {
          _permissionStatus[types[i]] = false;
          debugPrint('[HEALTH] ✗ ${types[i].name}: Error checking - $e');
        }
      }
      debugPrint('[HEALTH] ============================================');

      // Consider authorized if at least steps permission is granted
      final hasSteps = _permissionStatus[HealthDataType.STEPS] ?? false;
      _isAuthorized = hasSteps;

      debugPrint('[HEALTH] Final authorized status: $_isAuthorized (based on steps: $hasSteps)');

      // Request Health Data History permission (for reading data older than 30 days)
      try {
        debugPrint('[HEALTH] Requesting Health Data History permission...');
        final historyAuthorized =
            await _health.requestHealthDataHistoryAuthorization();
        debugPrint('[HEALTH] Health Data History authorized: $historyAuthorized');
      } catch (e) {
        debugPrint('[HEALTH] Health Data History permission request failed (non-critical): $e');
      }
    } catch (e) {
      debugPrint('[HEALTH] ERROR requesting authorization: $e');
      _isAuthorized = false;
      rethrow;
    }
  }

  /// Check if a specific permission is granted
  bool hasPermission(HealthDataType type) {
    return _permissionStatus[type] ?? false;
  }

  /// Get list of permissions that are NOT granted
  List<String> getMissingPermissions() {
    final missing = <String>[];
    _permissionStatus.forEach((type, granted) {
      if (!granted) {
        missing.add(type.name);
      }
    });
    return missing;
  }

  /// Get today's total steps.
  /// Returns 0 if no data available.
  Future<int> getStepsToday() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      debugPrint('[HEALTH] Fetching steps from $start to $now');

      // Use getTotalStepsInInterval for efficient step counting
      final steps = await _health.getTotalStepsInInterval(start, now);
      debugPrint('[HEALTH] getTotalStepsInInterval result: $steps');

      if (steps != null && steps > 0) {
        return steps;
      }

      // Fallback: use getHealthDataFromTypes
      debugPrint('[HEALTH] Fallback: using getHealthDataFromTypes for steps...');
      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: now,
      );

      debugPrint('[HEALTH] getHealthDataFromTypes returned ${results.length} step records');

      int totalSteps = 0;
      for (final point in results) {
        if (point.type == HealthDataType.STEPS) {
          final value = (point.value as NumericHealthValue).numericValue.toInt();
          totalSteps += value;
          debugPrint('[HEALTH] Step record: $value steps (${point.dateFrom} to ${point.dateTo})');
        }
      }

      debugPrint('[HEALTH] Total steps calculated: $totalSteps');
      return totalSteps;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching steps: $e');
      rethrow;
    }
  }

  /// Get the latest heart rate reading.
  /// Returns null if no data available.
  Future<double?> getLatestHeartRate() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();

      // Try expanding time ranges until we find data
      final ranges = [
        DateTime(now.year, now.month, now.day, now.hour - 1), // Last hour
        DateTime(now.year, now.month, now.day),               // Today
        DateTime(now.year, now.month, now.day - 1),           // Yesterday
        DateTime(now.year, now.month, now.day - 7),           // Last week
      ];

      for (final start in ranges) {
        debugPrint('[HEALTH] Fetching heart rate from $start to $now');

        final results = await _health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: start,
          endTime: now,
        );

        debugPrint('[HEALTH] Found ${results.length} heart rate records');

        if (results.isNotEmpty) {
          // Sort by most recent
          results.sort((a, b) => b.dateTo.compareTo(a.dateFrom));
          final latest = results.first;
          final bpm = (latest.value as NumericHealthValue).numericValue.toDouble();
          debugPrint('[HEALTH] Latest heart rate: $bpm bpm (from ${latest.dateFrom})');
          return bpm;
        }
      }

      debugPrint('[HEALTH] No heart rate data found in any time range');
      return null;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching heart rate: $e');
      rethrow;
    }
  }

  /// Get weekly steps data (last 7 days).
  /// Returns a map of {dateString: stepCount}.
  Future<Map<String, int>> getWeeklySteps() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day - 6);

      debugPrint('[HEALTH] Fetching weekly steps from $weekStart to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: weekStart,
        endTime: now,
      );

      debugPrint('[HEALTH] Found ${results.length} step records for the week');

      final Map<String, int> dailySteps = {};

      for (int i = 0; i < 7; i++) {
        final day = DateTime(now.year, now.month, now.day - i);
        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        dailySteps[key] = 0;
      }

      for (final point in results) {
        if (point.type == HealthDataType.STEPS) {
          final value = (point.value as NumericHealthValue).numericValue.toInt();
          final dayKey = '${point.dateFrom.year}-${point.dateFrom.month.toString().padLeft(2, '0')}-${point.dateFrom.day.toString().padLeft(2, '0')}';
          dailySteps[dayKey] = (dailySteps[dayKey] ?? 0) + value;
        }
      }

      debugPrint('[HEALTH] Weekly steps: $dailySteps');
      return dailySteps;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching weekly steps: $e');
      rethrow;
    }
  }

  /// Get weekly heart rate data (last 7 days).
  /// Returns a map of {dateString: avgBpm}.
  Future<Map<String, double>> getWeeklyHeartRate() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day - 6);

      debugPrint('[HEALTH] Fetching weekly heart rate from $weekStart to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: weekStart,
        endTime: now,
      );

      debugPrint('[HEALTH] Found ${results.length} heart rate records for the week');

      final Map<String, List<double>> dailyHeartRates = {};

      for (int i = 0; i < 7; i++) {
        final day = DateTime(now.year, now.month, now.day - i);
        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        dailyHeartRates[key] = [];
      }

      for (final point in results) {
        if (point.type == HealthDataType.HEART_RATE) {
          final bpm = (point.value as NumericHealthValue).numericValue.toDouble();
          final dayKey = '${point.dateFrom.year}-${point.dateFrom.month.toString().padLeft(2, '0')}-${point.dateFrom.day.toString().padLeft(2, '0')}';
          if (dailyHeartRates.containsKey(dayKey)) {
            dailyHeartRates[dayKey]!.add(bpm);
          }
        }
      }

      // Calculate daily averages
      final Map<String, double> dailyAvg = {};
      dailyHeartRates.forEach((key, values) {
        if (values.isNotEmpty) {
          dailyAvg[key] = values.reduce((a, b) => a + b) / values.length;
        }
      });

      debugPrint('[HEALTH] Weekly avg heart rate: $dailyAvg');
      return dailyAvg;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching weekly heart rate: $e');
      rethrow;
    }
  }

  // ─── Weekly Health Data for charts ──────────────────────────────────────

  /// Fetch daily health data for last 7 days.
  Future<List<DailyHealthData>> getWeeklyHealthData() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final List<DailyHealthData> weekData = [];

      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day - i);
        final nextDay = DateTime(now.year, now.month, now.day - i + 1);

        // Steps
        int steps = 0;
        try {
          final stepResults = await _health.getHealthDataFromTypes(
            types: [HealthDataType.STEPS],
            startTime: day,
            endTime: i == 0 ? now : nextDay,
          );
          for (final p in stepResults) {
            if (p.type == HealthDataType.STEPS) {
              steps += (p.value as NumericHealthValue).numericValue.toInt();
            }
          }
        } catch (_) {}

        // Distance
        double distMeters = 0;
        try {
          final distResults = await _health.getHealthDataFromTypes(
            types: [HealthDataType.DISTANCE_DELTA],
            startTime: day,
            endTime: i == 0 ? now : nextDay,
          );
          for (final p in distResults) {
            if (p.type == HealthDataType.DISTANCE_DELTA) {
              distMeters += (p.value as NumericHealthValue).numericValue.toDouble();
            }
          }
        } catch (_) {}

        // Calories
        double calories = 0;
        try {
          final calResults = await _health.getHealthDataFromTypes(
            types: [HealthDataType.ACTIVE_ENERGY_BURNED],
            startTime: day,
            endTime: i == 0 ? now : nextDay,
          );
          for (final p in calResults) {
            if (p.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              calories += (p.value as NumericHealthValue).numericValue.toDouble();
            }
          }
        } catch (_) {}

        // Active minutes (from workouts)
        int activeMin = 0;
        try {
          final workResults = await _health.getHealthDataFromTypes(
            types: [HealthDataType.WORKOUT],
            startTime: day,
            endTime: i == 0 ? now : nextDay,
          );
          for (final p in workResults) {
            if (p.type == HealthDataType.WORKOUT) {
              activeMin += p.dateTo.difference(p.dateFrom).inMinutes;
            }
          }
        } catch (_) {}

        weekData.add(DailyHealthData(
          date: day,
          steps: steps,
          distanceKm: distMeters / 1000.0,
          calories: calories,
          activeMinutes: activeMin,
        ));

        debugPrint('[HEALTH] Weekly ${day.month}/${day.day}: '
            'steps=$steps, dist=${(distMeters / 1000).toStringAsFixed(2)}km, '
            'cal=${calories.toStringAsFixed(0)}, active=${activeMin}min');
      }

      return weekData;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching weekly data: $e');
      return [];
    }
  }

  // ─── NEW: Fetch all activity data for quest tracking ────────────────────

  /// Get today's distance in kilometers.
  Future<double> getDistanceToday() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      debugPrint('[HEALTH] Fetching distance from $start to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: start,
        endTime: now,
      );

      double totalMeters = 0;
      for (final point in results) {
        if (point.type == HealthDataType.DISTANCE_DELTA) {
          final meters = (point.value as NumericHealthValue).numericValue.toDouble();
          totalMeters += meters;
        }
      }

      final km = totalMeters / 1000.0;
      debugPrint('[HEALTH] Total distance: ${km.toStringAsFixed(2)} km');
      return km;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching distance: $e');
      return 0.0;
    }
  }

  /// Get today's active calories burned.
  Future<double> getCaloriesToday() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      debugPrint('[HEALTH] Fetching calories from $start to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: now,
      );

      double totalCalories = 0;
      for (final point in results) {
        if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          final calories = (point.value as NumericHealthValue).numericValue.toDouble();
          totalCalories += calories;
        }
      }

      debugPrint('[HEALTH] Total calories: ${totalCalories.toStringAsFixed(0)}');
      return totalCalories;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching calories: $e');
      return 0.0;
    }
  }

  /// Get today's sleep duration in hours.
  Future<double> getSleepToday() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      debugPrint('[HEALTH] Fetching sleep from $start to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: start,
        endTime: now,
      );

      double totalMinutes = 0;
      for (final point in results) {
        if (point.type == HealthDataType.SLEEP_ASLEEP) {
          final minutes = (point.value as NumericHealthValue).numericValue.toDouble();
          totalMinutes += minutes;
        }
      }

      final hours = totalMinutes / 60.0;
      debugPrint('[HEALTH] Total sleep: ${hours.toStringAsFixed(1)} hours');
      return hours;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching sleep: $e');
      return 0.0;
    }
  }

  /// Get today's workout types and exercise duration.
  Future<Map<String, dynamic>> getWorkoutsToday() async {
    try {
      if (!_isConfigured) await initialize();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      debugPrint('[HEALTH] Fetching workouts from $start to $now');

      final results = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: now,
      );

      List<String> workoutTypes = [];
      int totalMinutes = 0;

      for (final point in results) {
        if (point.type == HealthDataType.WORKOUT) {
          final workoutValue = point.value as WorkoutHealthValue;
          final typeName = workoutValue.workoutActivityType.name.toLowerCase();
          workoutTypes.add(typeName);

          // Calculate duration from dateFrom to dateTo
          final durationMin = point.dateTo.difference(point.dateFrom).inMinutes;
          totalMinutes += durationMin;
        }
      }

      // Remove duplicates
      workoutTypes = workoutTypes.toSet().toList();

      debugPrint('[HEALTH] Workouts: $workoutTypes, Duration: $totalMinutes min');
      return {
        'types': workoutTypes,
        'minutes': totalMinutes,
      };
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching workouts: $e');
      return {'types': <String>[], 'minutes': 0};
    }
  }

  /// Check if cycling workout was performed today.
  Future<bool> hasCyclingToday() async {
    try {
      final workouts = await getWorkoutsToday();
      final types = workouts['types'] as List<String>;

      final hasCycling = types.any((type) =>
          type.contains('cycling') ||
          type.contains('biking') ||
          type.contains('bike'));

      debugPrint('[HEALTH] Has cycling today: $hasCycling');
      return hasCycling;
    } catch (e) {
      debugPrint('[HEALTH] ERROR checking cycling: $e');
      return false;
    }
  }

  /// Get all activity data for quest evaluation in one call.
  /// Returns a HealthDataSummary with all 7 activity types.
  Future<HealthDataSummary> getAllActivityData() async {
    try {
      debugPrint('[HEALTH] ========== FETCHING ALL ACTIVITY DATA ==========');

      final results = await Future.wait([
        getStepsToday(),
        getDistanceToday(),
        getCaloriesToday(),
        getSleepToday(),
        getWorkoutsToday(),
      ]);

      final steps = results[0] as int;
      final distance = results[1] as double;
      final calories = results[2] as double;
      final sleep = results[3] as double;
      final workouts = results[4] as Map<String, dynamic>;

      final workoutTypes = workouts['types'] as List<String>;
      final activeMinutes = workouts['minutes'] as int? ?? 0;

      final hasCycling = workoutTypes.any((type) =>
          type.contains('cycling') ||
          type.contains('biking') ||
          type.contains('bike'));

      final summary = HealthDataSummary(
        steps: steps,
        distanceKm: distance,
        calories: calories,
        sleepHours: sleep,
        workoutTypes: workoutTypes,
        activeMinutes: activeMinutes,
        hasCycling: hasCycling,
        fetchedAt: DateTime.now(),
      );

      debugPrint('[HEALTH] ========== ACTIVITY SUMMARY ==========');
      debugPrint('[HEALTH] STEPS:         $steps');
      debugPrint('[HEALTH] DISTANCE:      ${distance.toStringAsFixed(2)} km');
      debugPrint('[HEALTH] CALORIES:      ${calories.toStringAsFixed(0)} kcal');
      debugPrint('[HEALTH] SLEEP:         ${sleep.toStringAsFixed(1)} hours');
      debugPrint('[HEALTH] WORKOUT TYPES: $workoutTypes');
      debugPrint('[HEALTH] ACTIVE MINUTES: $activeMinutes min');
      debugPrint('[HEALTH] HAS CYCLING:   $hasCycling');
      debugPrint('[HEALTH] ============================================');

      return summary;
    } catch (e) {
      debugPrint('[HEALTH] ERROR fetching all activity data: $e');
      return HealthDataSummary.empty();
    }
  }

  bool get isAuthorized => _isAuthorized;
}

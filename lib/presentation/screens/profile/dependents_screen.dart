import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fatripy_app/data/api/plan_api_client.dart';
import 'package:fatripy_app/data/repositories/catalog_repository.dart';
import 'package:fatripy_app/data/repositories/family_repository.dart';
import 'package:fatripy_app/data/repositories/trip_repository.dart';
import 'package:fatripy_app/domain/entities/trip_plan.dart';
import 'package:fatripy_app/core/constants/supported_cities.dart';

import '../../localization/app_localizations_ext.dart';
import '../../theme/responsive_scale.dart';

class DependentsScreen extends StatefulWidget {
  const DependentsScreen({super.key});

  @override
  State<DependentsScreen> createState() => _DependentsScreenState();
}

class _DependentsScreenState extends State<DependentsScreen> {
  static const Color _cream = Color(0xFFFFF4E8);
  static const Color _frame = Color(0xFFE18299);
  static const Color _shape = Color(0xFFF5C9D4);
  static const Color _text = Color(0xFF2A2A2A);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FamilyRepository _familyRepository = FamilyRepository();

  int _adults = 2;
  int _children = 2;
  int _infant = 0;

  List<int> _adultAges = [0, 0];
  List<int> _childAges = [0, 0];
  List<int> _infantAges = [];

  String _budget = '21000SAR';
  String _city = AppCities.values.first;
  String _duration = '7 days & 6 nights';
  String _start = '1 dec 2026';
  String _end = '7 dec 2026';
  DateTime? _startDateValue;
  DateTime? _endDateValue;

  bool _generating = false;
  bool _localizedDefaultsApplied = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizedDefaultsApplied) return;
    final l10n = context.l10n;
    if (_budget == '21000SAR') {
      _budget = l10n.dependentsDefaultBudget;
    }
    if (_duration == '7 days & 6 nights') {
      _duration = l10n.dependentsDefaultDuration;
    }
    if (_start == '1 dec 2026') {
      _start = l10n.dependentsDefaultStartDate;
    }
    if (_end == '7 dec 2026') {
      _end = l10n.dependentsDefaultEndDate;
    }
    _localizedDefaultsApplied = true;
  }

  int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  List<int> _normalizeAgeList(List<int> list, int count) {
    if (list.length < count) {
      list.addAll(List.filled(count - list.length, 0));
    } else if (list.length > count) {
      list.removeRange(count, list.length);
    }
    return list;
  }

  List<int> _parseAgeList(dynamic value, int count) {
    final raw = value is List ? value : const <dynamic>[];
    final parsed = <int>[];
    for (final v in raw) {
      parsed.add(_parseInt(v, 0));
    }
    return _normalizeAgeList(parsed, count);
  }

  int _extractDurationDays(String rawDuration) {
    final normalized = rawDuration
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
    final match = RegExp(r'\d+').firstMatch(normalized);
    return int.tryParse(match?.group(0) ?? '') ?? 7;
  }

  double _safeBudgetValue(String rawBudget) {
    return double.tryParse(rawBudget.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        21000.0;
  }

  String _formatDateLabel(DateTime date) {
    const months = <String>[
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  DateTime? _parseDateLabel(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return iso;
    }

    final normalized = value
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    final match = RegExp(
      r'^(\d{1,2}) ([a-z]{3,9}) (\d{4})$',
    ).firstMatch(normalized);
    if (match == null) return null;

    const monthMap = <String, int>{
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'sept': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };

    final day = int.tryParse(match.group(1) ?? '');
    final month = monthMap[match.group(2)];
    final year = int.tryParse(match.group(3) ?? '');
    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  Future<void> _loadFamilyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final aggregate = await _familyRepository.getFamilyData(user.uid);
      if (aggregate != null) {
        final adultAges = aggregate.members
            .where((m) => m.ageGroup.toLowerCase() == 'adult')
            .map((m) => m.age)
            .toList();
        final childAges = aggregate.members
            .where((m) => m.ageGroup.toLowerCase() == 'child')
            .map((m) => m.age)
            .toList();
        final infantAges = aggregate.members
            .where((m) => m.ageGroup.toLowerCase() == 'infant')
            .map((m) => m.age)
            .toList();

        if (!mounted) return;
        setState(() {
          _adults = aggregate.adults > 0 ? aggregate.adults : adultAges.length;
          _children = aggregate.children > 0
              ? aggregate.children
              : childAges.length;
          _infant = aggregate.infants > 0
              ? aggregate.infants
              : infantAges.length;
          _adultAges = _normalizeAgeList(adultAges, _adults);
          _childAges = _normalizeAgeList(childAges, _children);
          _infantAges = _normalizeAgeList(infantAges, _infant);
          _budget = (aggregate.budgetLabel?.trim().isNotEmpty ?? false)
              ? aggregate.budgetLabel!.trim()
              : '${aggregate.familyGroup.budget.toStringAsFixed(0)} SAR';
          if (aggregate.destinationCity.trim().isNotEmpty) {
            _city = aggregate.destinationCity.trim();
          }
          if (aggregate.durationDays > 0) {
            final nights = aggregate.durationDays > 1
                ? aggregate.durationDays - 1
                : 0;
            _duration = '${aggregate.durationDays} days & $nights nights';
          }
          _startDateValue = aggregate.familyGroup.startDate;
          _endDateValue = aggregate.familyGroup.endDate;
          _start = (aggregate.startLabel?.trim().isNotEmpty ?? false)
              ? aggregate.startLabel!.trim()
              : _formatDateLabel(aggregate.familyGroup.startDate);
          _end = (aggregate.endLabel?.trim().isNotEmpty ?? false)
              ? aggregate.endLabel!.trim()
              : _formatDateLabel(aggregate.familyGroup.endDate);
        });
        return;
      }

      // Backward-compatible fallback for legacy users.family documents.
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final family = data?['family'] as Map<String, dynamic>?;
      if (family == null) return;
      if (!mounted) return;
      setState(() {
        _adults = _parseInt(family['adults'], _adults);
        _children = _parseInt(family['children'], _children);
        _infant = _parseInt(family['infants'], _infant);
        _adultAges = _parseAgeList(family['adultAges'], _adults);
        _childAges = _parseAgeList(family['childAges'], _children);
        _infantAges = _parseAgeList(family['infantAges'], _infant);
        _budget = (family['budget'] as String?)?.trim().isNotEmpty == true
            ? family['budget'] as String
            : _budget;
        _city = (family['city'] as String?)?.trim().isNotEmpty == true
            ? family['city'] as String
            : _city;
        _duration = (family['duration'] as String?)?.trim().isNotEmpty == true
            ? family['duration'] as String
            : _duration;
        _start = (family['start'] as String?)?.trim().isNotEmpty == true
            ? family['start'] as String
            : _start;
        _end = (family['end'] as String?)?.trim().isNotEmpty == true
            ? family['end'] as String
            : _end;
        _startDateValue = _parseDateLabel(_start);
        _endDateValue = _parseDateLabel(_end);
      });
    } catch (e) {
      debugPrint('Error loading family data: $e');
    }
  }

  Future<void> _saveFamilyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final durationDays = _extractDurationDays(_duration);
    final startDate =
        _startDateValue ?? _parseDateLabel(_start) ?? DateTime.now();
    final endDate =
        _endDateValue ??
        _parseDateLabel(_end) ??
        startDate.add(Duration(days: durationDays > 1 ? durationDays - 1 : 0));
    final budgetValue = _safeBudgetValue(_budget);
    final groupName = (user.displayName?.trim().isNotEmpty ?? false)
        ? '${user.displayName!.trim()} Family Group'
        : 'Family Group';

    await _familyRepository.saveFamilyData(
      ownerId: user.uid,
      groupName: groupName,
      budget: budgetValue,
      startDate: startDate,
      endDate: endDate,
      destinationCity: _city,
      durationDays: durationDays,
      adultAges: _adultAges,
      childAges: _childAges,
      infantAges: _infantAges,
      budgetLabel: _budget,
      startLabel: _start,
      endLabel: _end,
    );
  }

  Future<void> _editValue({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    onSave(result);
  }

  Future<void> _editAges({
    required String title,
    required List<int> current,
    required ValueChanged<List<int>> onSave,
  }) async {
    final controllers = [
      for (int i = 0; i < current.length; i++)
        TextEditingController(
          text: current[i] == 0 ? '' : current[i].toString(),
        ),
    ];

    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: controllers.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return TextField(
                controller: controllers[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.dependentsAgeField(index + 1),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              final ages = controllers
                  .map((c) => int.tryParse(c.text.trim()) ?? 0)
                  .toList();
              Navigator.of(context).pop(ages);
            },
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );

    if (result == null) return;
    onSave(result);
  }

  String _formatAges(List<int> ages) {
    if (ages.isEmpty) return '-';
    return ages.map((a) => a == 0 ? '-' : a.toString()).join(', ');
  }

  Future<void> _selectCity() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.dependentsCity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppCities.values.length,
                  itemBuilder: (context, index) {
                    final c = AppCities.values[index];
                    return ListTile(
                      title: Text(
                        localizeCityLabel(context.l10n, c),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _city = result);
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _frame,
              onPrimary: Colors.white,
              surface: _cream,
              onSurface: _text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (date != null) {
      final formatted = MaterialLocalizations.of(
        context,
      ).formatMediumDate(date);
      setState(() {
        if (isStart) {
          _start = formatted;
          _startDateValue = DateTime(date.year, date.month, date.day);
        } else {
          _end = formatted;
          _endDateValue = DateTime(date.year, date.month, date.day);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scale = AppScale.of(context);
    final showBack = Navigator.of(context).canPop();
    double s(double value) => value * scale;

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: s(24)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: s(16)),
                decoration: const BoxDecoration(color: _shape),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showBack)
                      PositionedDirectional(
                        start: s(6),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: _text,
                            size: s(24),
                          ),
                        ),
                      ),
                    Text(
                      l10n.dependentsTitle,
                      style: TextStyle(
                        fontSize: s(22),
                        fontFamily: 'serif',
                        color: _text,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(s(16), s(24), s(16), s(32)),
                child: Column(
                  children: [
                    _SectionCard(
                      title: l10n.dependentsMyFamily,
                      child: Column(
                        children: [
                          _FamilyCounterRow(
                            label: l10n.dependentsAdults,
                            value: _adults,
                            onDecrement: () => setState(() {
                              _adults = (_adults - 1).clamp(0, 99);
                              _normalizeAgeList(_adultAges, _adults);
                            }),
                            onIncrement: () => setState(() {
                              _adults = (_adults + 1).clamp(0, 99);
                              _normalizeAgeList(_adultAges, _adults);
                            }),
                          ),
                          SizedBox(height: s(8)),
                          _AgesSummaryRow(
                            label: l10n.dependentsAdultAges,
                            agesText: _formatAges(_adultAges),
                            onEdit: () => _editAges(
                              title: l10n.dependentsAdultAges,
                              current: _adultAges,
                              onSave: (ages) =>
                                  setState(() => _adultAges = ages),
                            ),
                          ),
                          SizedBox(height: s(14)),
                          Divider(
                            color: _frame.withValues(alpha: 0.7),
                            thickness: 2,
                          ),
                          SizedBox(height: s(14)),
                          _FamilyCounterRow(
                            label: l10n.dependentsChildren,
                            value: _children,
                            onDecrement: () => setState(() {
                              _children = (_children - 1).clamp(0, 99);
                              _normalizeAgeList(_childAges, _children);
                            }),
                            onIncrement: () => setState(() {
                              _children = (_children + 1).clamp(0, 99);
                              _normalizeAgeList(_childAges, _children);
                            }),
                          ),
                          SizedBox(height: s(8)),
                          _AgesSummaryRow(
                            label: l10n.dependentsChildAges,
                            agesText: _formatAges(_childAges),
                            onEdit: () => _editAges(
                              title: l10n.dependentsChildAges,
                              current: _childAges,
                              onSave: (ages) =>
                                  setState(() => _childAges = ages),
                            ),
                          ),
                          SizedBox(height: s(14)),
                          Divider(
                            color: _frame.withValues(alpha: 0.7),
                            thickness: 2,
                          ),
                          SizedBox(height: s(14)),
                          _FamilyCounterRow(
                            label: l10n.dependentsInfant,
                            value: _infant,
                            onDecrement: () => setState(() {
                              _infant = (_infant - 1).clamp(0, 99);
                              _normalizeAgeList(_infantAges, _infant);
                            }),
                            onIncrement: () => setState(() {
                              _infant = (_infant + 1).clamp(0, 99);
                              _normalizeAgeList(_infantAges, _infant);
                            }),
                          ),
                          SizedBox(height: s(8)),
                          _AgesSummaryRow(
                            label: l10n.dependentsInfantAges,
                            agesText: _formatAges(_infantAges),
                            onEdit: () => _editAges(
                              title: l10n.dependentsInfantAges,
                              current: _infantAges,
                              onSave: (ages) =>
                                  setState(() => _infantAges = ages),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: s(22)),

                    _SectionCard(
                      title: l10n.dependentsTripInfo,
                      child: Column(
                        children: [
                          _TripInfoRow(
                            label: l10n.dependentsBudget,
                            value: _budget,
                            onTap: () => _editValue(
                              title: l10n.dependentsBudget,
                              currentValue: _budget,
                              keyboardType: TextInputType.number,
                              onSave: (value) =>
                                  setState(() => _budget = value),
                            ),
                          ),
                          SizedBox(height: s(12)),
                          _TripInfoRow(
                            label: l10n.dependentsCity,
                            value: localizeCityLabel(l10n, _city),
                            onTap: _selectCity,
                          ),
                          SizedBox(height: s(12)),
                          _TripInfoRow(
                            label: l10n.dependentsDuration,
                            value: _duration,
                            onTap: () => _editValue(
                              title: l10n.dependentsDuration,
                              currentValue: _duration,
                              keyboardType: TextInputType.text,
                              onSave: (value) =>
                                  setState(() => _duration = value),
                            ),
                          ),
                          SizedBox(height: s(12)),
                          _TripInfoRow(
                            label: l10n.dependentsStart,
                            value: _start,
                            onTap: () => _selectDate(true),
                          ),
                          SizedBox(height: s(12)),
                          _TripInfoRow(
                            label: l10n.dependentsEnd,
                            value: _end,
                            onTap: () => _selectDate(false),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: s(36)),

                    Center(
                      child: SizedBox(
                        width: s(160),
                        height: s(54),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _frame,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(s(14)),
                              side: BorderSide(color: _shape, width: s(3)),
                            ),
                          ),
                          onPressed: () async {
                            if (_generating) return;
                            setState(() => _generating = true);
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.dependentsGeneratingPlan),
                                ),
                              );

                              final String cityStr = _city;
                              final double budgetNum = _safeBudgetValue(
                                _budget,
                              );
                              final int daysNum = _extractDurationDays(
                                _duration,
                              );
                              final tripStartDate =
                                  _startDateValue ??
                                  _parseDateLabel(_start) ??
                                  DateTime.now();
                              final tripEndDate =
                                  _endDateValue ??
                                  _parseDateLabel(_end) ??
                                  tripStartDate.add(
                                    Duration(
                                      days: daysNum > 1 ? daysNum - 1 : 0,
                                    ),
                                  );
                              final startDateIso = tripStartDate
                                  .toIso8601String()
                                  .split('T')
                                  .first;
                              final endDateIso = tripEndDate
                                  .toIso8601String()
                                  .split('T')
                                  .first;

                              await _saveFamilyData();

                              final List<String> familyAges = [];
                              for (int i = 0; i < _adults; i++) {
                                familyAges.add('Adult');
                              }
                              for (int i = 0; i < _children; i++) {
                                familyAges.add('Child');
                              }
                              for (int i = 0; i < _infant; i++) {
                                familyAges.add('Infant');
                              }

                              final catalogRepo = CatalogRepository();
                              final hotels = await catalogRepo.getHotelsByCity(
                                cityStr,
                              );
                              final activities = await catalogRepo
                                  .getActivitiesByCity(cityStr);
                              final events = await catalogRepo.getEventsByCity(
                                cityStr,
                              );

                              final apiClient = PlanApiClient();
                              final generatedResult = await apiClient
                                  .generatePlans(
                                    city: cityStr,
                                    budget: budgetNum,
                                    days: daysNum,
                                    startDate: startDateIso,
                                    endDate: endDateIso,
                                    familyAges: familyAges,
                                    accommodations: hotels,
                                    activities: activities,
                                    events: events,
                                  );
                              final generatedPlans =
                                  generatedResult.generatedPlans;
                              final aiElapsedMs = generatedResult.aiElapsedMs;

                              if (aiElapsedMs != null &&
                                  aiElapsedMs > 3000 &&
                                  context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.orange.shade700,
                                    content: Text(
                                      l10n.dependentsAiLatencyWarning(
                                        aiElapsedMs.toStringAsFixed(0),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  'unknown_user';
                              final tripRepo = TripRepository();

                              final newTrip = TripPlan(
                                id: '',
                                ownerId: uid,
                                city: cityStr,
                                days: daysNum,
                                budget: budgetNum,
                                totalCost: 0.0,
                                createdAt: DateTime.now(),
                                status: 'Generated',
                                selected: false,
                                aiElapsedMs: aiElapsedMs,
                                generatedPlans: generatedPlans,
                              );

                              await tripRepo.addPlan(newTrip);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.dependentsGenerationComplete,
                                    ),
                                  ),
                                );
                                Navigator.of(context).maybePop();
                              }
                            } catch (e) {
                              debugPrint("Error saving trip: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.errorWithDetails(e.toString()),
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _generating = false);
                              }
                            }
                          },
                          child: _generating
                              ? SizedBox(
                                  width: s(24),
                                  height: s(24),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.dependentsDone,
                                  style: TextStyle(
                                    fontSize: s(22),
                                    fontFamily: 'serif',
                                    height: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------- Section Card (with notch) -------------------------- */

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  static const Color _frame = Color(0xFFE18299);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    double s(double v) => v * scale;

    final tabH = s(40);
    final tabPadH = s(18);
    final tabTop = -s(18);
    final cardTopPadding = s(44);
    final tabLeft = s(10);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Estimate tab width based on title length.
        final tabW = (title.length * s(11.0)) + (tabPadH * 2);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Draw frame with top notch behind tab label.
            CustomPaint(
              painter: _SectionFramePainter(
                color: _frame,
                stroke: s(2.4),
                radius: s(16),
                tabLeft: tabLeft,
                tabWidth: tabW,
                tabTopInset: s(2),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  s(18),
                  cardTopPadding,
                  s(18),
                  s(20),
                ),
                child: child,
              ),
            ),

            Positioned(
              left: tabLeft,
              top: tabTop,
              child: Container(
                height: tabH,
                padding: EdgeInsets.symmetric(horizontal: tabPadH),
                decoration: BoxDecoration(
                  color: _frame,
                  borderRadius: BorderRadius.circular(s(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: s(10),
                      offset: Offset(0, s(5)),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: s(20),
                    fontFamily: 'serif',
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionFramePainter extends CustomPainter {
  final Color color;
  final double stroke;
  final double radius;

  final double tabLeft;
  final double tabWidth;
  final double tabTopInset;

  _SectionFramePainter({
    required this.color,
    required this.stroke,
    required this.radius,
    required this.tabLeft,
    required this.tabWidth,
    required this.tabTopInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure clear blend mode works correctly.
    canvas.saveLayer(Offset.zero & size, Paint());

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rr, borderPaint);

    // Cut a segment from top border behind tab.
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final cutRect = Rect.fromLTWH(
      tabLeft,
      stroke / 2 + tabTopInset,
      tabWidth,
      stroke + tabTopInset + 3,
    );

    canvas.drawRect(cutRect, erasePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SectionFramePainter old) {
    return old.color != color ||
        old.stroke != stroke ||
        old.radius != radius ||
        old.tabLeft != tabLeft ||
        old.tabWidth != tabWidth ||
        old.tabTopInset != tabTopInset;
  }
}

/* -------------------------- Family Counter Row -------------------------- */

class _FamilyCounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _FamilyCounterRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  static const Color _frame = Color(0xFFE18299);
  static const Color _shape = Color(0xFFF5C9D4);
  static const Color _text = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    double s(double v) => v * scale;

    return Container(
      height: s(54),
      padding: EdgeInsets.symmetric(horizontal: s(22)),
      decoration: BoxDecoration(
        color: _frame,
        borderRadius: BorderRadius.circular(s(28)),
        border: Border.all(color: _shape, width: s(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: s(8),
            offset: Offset(0, s(4)),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: s(18),
              fontFamily: 'serif',
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onDecrement,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(6),
                    vertical: s(8),
                  ),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: s(22),
                      fontFamily: 'serif',
                      color: _text,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              Container(
                width: s(34),
                height: s(34),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _shape,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: s(18),
                    fontFamily: 'serif',
                    color: _text,
                    height: 1.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(6),
                    vertical: s(8),
                  ),
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: s(22),
                      fontFamily: 'serif',
                      color: _text,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* -------------------------- Trip Info Row (label smaller + value left) -------------------------- */

class _TripInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TripInfoRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  static const Color _frame = Color(0xFFE18299);
  static const Color _shape = Color(0xFFF5C9D4);
  static const Color _text = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    double s(double v) => v * scale;

    final h = s(54);
    final labelW = s(86); // Reduced from 96 to make pill smaller
    final radius = s(28);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: _frame,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _shape, width: s(3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: s(8),
              offset: Offset(0, s(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: labelW,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _shape,
                borderRadius: BorderRadius.circular(radius - s(1.5)),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: s(18),
                  fontFamily: 'serif',
                  color: _text,
                  height: 1.1,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: s(8)),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: s(18),
                    fontFamily: 'serif',
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------- Ages Summary Row -------------------------- */

class _AgesSummaryRow extends StatelessWidget {
  final String label;
  final String agesText;
  final VoidCallback onEdit;

  const _AgesSummaryRow({
    required this.label,
    required this.agesText,
    required this.onEdit,
  });

  static const Color _frame = Color(0xFFE18299);
  static const Color _text = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    double s(double v) => v * scale;

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $agesText',
            style: TextStyle(
              fontSize: s(14),
              fontFamily: 'serif',
              color: _text,
              height: 1.2,
            ),
          ),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(foregroundColor: _frame),
          child: Text(
            context.l10n.actionEdit,
            style: TextStyle(fontSize: s(14), fontFamily: 'serif', height: 1.1),
          ),
        ),
      ],
    );
  }
}

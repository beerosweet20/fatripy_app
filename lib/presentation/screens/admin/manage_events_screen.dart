import 'package:flutter/material.dart';

import '../../../data/repositories/admin_content_repository.dart';
import '../../localization/app_localizations_ext.dart';
import 'admin_bottom_nav.dart';
import 'admin_design.dart';
import 'admin_form_support.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final AdminContentRepository _repo = AdminContentRepository();

  Future<void> _openEventForm({AdminDoc? existing}) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final cityOptions = adminCityOptions(context);

    final titleController = TextEditingController(
      text:
          existing?.data['title']?.toString() ??
          existing?.data['name']?.toString() ??
          '',
    );
    final descriptionController = TextEditingController(
      text: existing?.data['description']?.toString() ?? '',
    );

    String? selectedCity = normalizeCityValue(
      existing?.data['city']?.toString(),
      cityOptions,
    );
    String selectedDate = (existing?.data['date']?.toString() ?? '').trim();
    PickedMapLocation? selectedLocation = locationFromData(existing?.data);
    String? locationError;
    String? dateError;

    Future<void> pickDate(void Function(void Function()) setDialogState) async {
      final now = DateTime.now();
      final initialDate = _tryParseDate(selectedDate) ?? now;

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );

      if (picked == null) {
        return;
      }

      setDialogState(() {
        selectedDate = _formatDate(picked);
        dateError = null;
      });
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickFromMap() async {
              final picked = await showMapLocationPicker(
                context,
                title: l10n.adminMapPickerTitle,
                hint: l10n.adminMapTapHint,
                confirmLabel: l10n.adminMapConfirmLocation,
                selectFirstError: l10n.adminMapPickFirst,
                initialLocation: selectedLocation,
              );

              if (picked == null) {
                return;
              }

              setDialogState(() {
                selectedLocation = picked;
                locationError = null;
              });
            }

            return AlertDialog(
              backgroundColor: AdminPalette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                existing == null ? l10n.adminAddContent : l10n.adminEditContent,
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 440,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CrudTextField(
                          controller: titleController,
                          label: l10n.adminLabelNameRequired,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return l10n.adminNameRequiredError;
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCity,
                            decoration: adminInputDecoration(
                              l10n.adminLabelCity,
                            ),
                            isExpanded: true,
                            items: cityOptions
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option.value,
                                    child: Text(option.label),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedCity = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.adminSelectCityError;
                              }
                              return null;
                            },
                          ),
                        ),
                        _DatePickerField(
                          label: l10n.bookingsReceiptDate,
                          value: selectedDate,
                          errorText: dateError,
                          onPickDate: () => pickDate(setDialogState),
                        ),
                        _MapPickerField(
                          label: l10n.adminLabelLocation,
                          selectedLabel:
                              selectedLocation?.label ??
                              l10n.adminLocationPickHint,
                          hasSelection: selectedLocation != null,
                          errorText: locationError,
                          onPickLocation: pickFromMap,
                          onOpenMaps: selectedLocation == null
                              ? null
                              : () =>
                                    openExternalMap(selectedLocation!.mapsUrl),
                        ),
                        _CrudTextField(
                          controller: descriptionController,
                          label: l10n.plansDescriptionLabel,
                          maxLines: 3,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return l10n.adminNameRequiredError;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    if (selectedDate.trim().isEmpty) {
                      setDialogState(() {
                        dateError = l10n.adminDateRequiredError;
                      });
                      return;
                    }
                    if (selectedLocation == null) {
                      setDialogState(() {
                        locationError = l10n.adminLocationRequiredError;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final pickedLocation = selectedLocation;
    if (pickedLocation == null ||
        selectedCity == null ||
        selectedDate.isEmpty) {
      return;
    }

    try {
      await _repo.saveEvent(
        id: existing?.id,
        title: titleController.text.trim(),
        date: selectedDate,
        location: pickedLocation.label,
        description: descriptionController.text.trim(),
        city: selectedCity!,
        latitude: pickedLocation.latitude,
        longitude: pickedLocation.longitude,
        mapsUrl: pickedLocation.mapsUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? l10n.adminSaveAdded(l10n.plansLabelEvents)
                : l10n.adminSaveUpdated(l10n.plansLabelEvents),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSaveFailed(e.toString()))),
      );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _confirmDelete(AdminDoc eventDoc) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.adminDeleteTitle),
        content: Text(l10n.adminDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repo.deleteEvent(eventDoc.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminDeleteSuccess(l10n.plansLabelEvents))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminDeleteFailed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AdminPalette.background,
      appBar: adminAppBar(context, title: l10n.plansLabelEvents),
      body: AdminDecoratedBody(
        child: StreamBuilder<List<AdminDoc>>(
          stream: _repo.watchCollection('events'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return adminEmptyState(
                context: context,
                icon: Icons.error_outline,
                message: l10n.adminLoadError(l10n.plansLabelEvents),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = [...(snapshot.data ?? const <AdminDoc>[])];
            events.sort((a, b) {
              final aTitle = (a.data['title'] ?? a.data['name'] ?? '')
                  .toString()
                  .toLowerCase();
              final bTitle = (b.data['title'] ?? b.data['name'] ?? '')
                  .toString()
                  .toLowerCase();
              return aTitle.compareTo(bTitle);
            });

            if (events.isEmpty) {
              return adminEmptyState(
                context: context,
                icon: Icons.event_outlined,
                message: l10n.adminNoRecords(l10n.plansLabelEvents),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final eventDoc = events[index];
                final data = eventDoc.data;
                final title =
                    (data['title'] ?? data['name'] ?? l10n.adminUnknownName)
                        .toString();
                final date = (data['date'] ?? '').toString();
                final city = (data['city'] ?? '').toString();
                final location = (data['location'] ?? '').toString();

                final details = [
                  if (date.isNotEmpty) '${l10n.bookingsReceiptDate}: $date',
                  if (city.isNotEmpty) '${l10n.adminLabelCity}: $city',
                  if (location.isNotEmpty) l10n.adminLocationValue(location),
                ].join(' | ');

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: adminCardShape(accentIndex: index + 2),
                  child: ListTile(
                    leading: Icon(
                      Icons.event_outlined,
                      color: AdminPalette.accentAt(index + 2),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AdminPalette.text,
                      ),
                    ),
                    subtitle: Text(
                      details.isEmpty ? l10n.adminNoExtraDetails : details,
                      style: const TextStyle(color: AdminPalette.navy),
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: l10n.adminTooltipEdit,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openEventForm(existing: eventDoc),
                        ),
                        IconButton(
                          tooltip: l10n.adminTooltipDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(eventDoc),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(current: AdminNavTab.events),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEventForm,
        backgroundColor: AdminPalette.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.adminAddContent),
      ),
    );
  }

  DateTime? _tryParseDate(String value) {
    try {
      if (value.trim().isEmpty) {
        return null;
      }
      return DateTime.parse(value.trim());
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _CrudTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;

  const _CrudTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: adminInputDecoration(label),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final String? errorText;
  final VoidCallback onPickDate;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.errorText,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AdminPalette.navy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AdminPalette.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminPalette.blush),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AdminPalette.navy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value.isEmpty ? l10n.adminDatePickerHint : value,
                  style: TextStyle(
                    color: value.isEmpty
                        ? AdminPalette.mutedText
                        : AdminPalette.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickDate,
          icon: const Icon(Icons.date_range_outlined),
          label: Text(l10n.adminPickDate),
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminPalette.navy,
            side: const BorderSide(color: AdminPalette.navy),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _MapPickerField extends StatelessWidget {
  final String label;
  final String selectedLabel;
  final bool hasSelection;
  final String? errorText;
  final VoidCallback onPickLocation;
  final VoidCallback? onOpenMaps;

  const _MapPickerField({
    required this.label,
    required this.selectedLabel,
    required this.hasSelection,
    required this.errorText,
    required this.onPickLocation,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AdminPalette.navy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AdminPalette.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminPalette.blush),
          ),
          child: Row(
            children: [
              const Icon(Icons.place_outlined, color: AdminPalette.navy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedLabel,
                  style: TextStyle(
                    color: hasSelection
                        ? AdminPalette.text
                        : AdminPalette.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onPickLocation,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(l10n.adminAddLocation),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminPalette.navy,
                side: const BorderSide(color: AdminPalette.navy),
              ),
            ),
            if (onOpenMaps != null)
              TextButton.icon(
                onPressed: onOpenMaps,
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.actionOpenInMaps),
              ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

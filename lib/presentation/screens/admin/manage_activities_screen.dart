import 'package:flutter/material.dart';

import '../../../data/repositories/admin_content_repository.dart';
import '../../localization/app_localizations_ext.dart';
import 'admin_bottom_nav.dart';
import 'admin_design.dart';
import 'admin_form_support.dart';

class ManageActivitiesScreen extends StatefulWidget {
  const ManageActivitiesScreen({super.key});

  @override
  State<ManageActivitiesScreen> createState() => _ManageActivitiesScreenState();
}

class _ManageActivitiesScreenState extends State<ManageActivitiesScreen> {
  final AdminContentRepository _repo = AdminContentRepository();

  Future<void> _openActivityForm({AdminDoc? existing}) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();

    final cityOptions = adminCityOptions(context);
    final ratingOptions = adminRatingOptions();
    final categoryOptions = [...adminCategoryOptions(context)];

    final existingCategoryRaw =
        existing?.data['category']?.toString().trim() ?? '';
    final initialCategory = normalizeCategoryValue(
      existingCategoryRaw,
      categoryOptions,
    );
    if (initialCategory == null && existingCategoryRaw.isNotEmpty) {
      categoryOptions.insert(
        0,
        AdminCategoryOption(
          value: existingCategoryRaw,
          label: existingCategoryRaw,
        ),
      );
    }

    final titleController = TextEditingController(
      text:
          existing?.data['title']?.toString() ??
          existing?.data['name']?.toString() ??
          '',
    );
    final descriptionController = TextEditingController(
      text: existing?.data['description']?.toString() ?? '',
    );

    String? selectedCategory =
        initialCategory ??
        (existingCategoryRaw.isNotEmpty ? existingCategoryRaw : null);
    String? selectedCity = normalizeCityValue(
      existing?.data['city']?.toString(),
      cityOptions,
    );
    double? selectedRating = normalizeRatingValue(
      toDouble(existing?.data['rating']),
      ratingOptions,
    );
    PickedMapLocation? selectedLocation = locationFromData(existing?.data);
    String? locationError;

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
                existing == null
                    ? l10n.adminAddActivity
                    : l10n.adminEditContent,
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
                            initialValue: selectedCategory,
                            decoration: adminInputDecoration(
                              l10n.compareKindLabel,
                            ),
                            isExpanded: true,
                            items: categoryOptions
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option.value,
                                    child: Text(option.label),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.adminSelectCategoryError;
                              }
                              return null;
                            },
                          ),
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<double>(
                            initialValue: selectedRating,
                            decoration: adminInputDecoration(
                              l10n.adminLabelRating,
                            ),
                            isExpanded: true,
                            items: ratingOptions
                                .map(
                                  (value) => DropdownMenuItem<double>(
                                    value: value,
                                    child: Text(ratingLabel(value)),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedRating = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return l10n.adminSelectRatingError;
                              }
                              return null;
                            },
                          ),
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
        selectedCategory == null ||
        selectedCity == null ||
        selectedRating == null) {
      return;
    }

    try {
      await _repo.saveActivity(
        id: existing?.id,
        title: titleController.text.trim(),
        category: selectedCategory!,
        city: selectedCity!,
        location: pickedLocation.label,
        rating: selectedRating!,
        description: descriptionController.text.trim(),
        latitude: pickedLocation.latitude,
        longitude: pickedLocation.longitude,
        mapsUrl: pickedLocation.mapsUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? l10n.adminSaveAdded(l10n.adminTabActivities)
                : l10n.adminSaveUpdated(l10n.adminTabActivities),
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

  Future<void> _confirmDelete(AdminDoc activity) async {
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
      await _repo.deleteActivity(activity.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminDeleteSuccess(l10n.adminTabActivities)),
        ),
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
      appBar: adminAppBar(context, title: l10n.adminTabActivities),
      body: AdminDecoratedBody(
        child: StreamBuilder<List<AdminDoc>>(
          stream: _repo.watchCollection('activities'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return adminEmptyState(
                context: context,
                icon: Icons.error_outline,
                message: l10n.adminLoadError(l10n.adminTabActivities),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final activities = [...(snapshot.data ?? const <AdminDoc>[])];
            activities.sort((a, b) {
              final aName = (a.data['title'] ?? a.data['name'] ?? '')
                  .toString()
                  .toLowerCase();
              final bName = (b.data['title'] ?? b.data['name'] ?? '')
                  .toString()
                  .toLowerCase();
              return aName.compareTo(bName);
            });

            if (activities.isEmpty) {
              return adminEmptyState(
                context: context,
                icon: Icons.local_activity_outlined,
                message: l10n.adminNoRecords(l10n.adminTabActivities),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: activities.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final data = activity.data;
                final title =
                    (data['title'] ?? data['name'] ?? l10n.adminUnknownName)
                        .toString();
                final category = (data['category'] ?? '').toString();
                final city = (data['city'] ?? '').toString();
                final location = (data['location'] ?? '').toString();
                final rating = (data['rating'] ?? '').toString();

                final details = [
                  if (category.isNotEmpty)
                    '${l10n.compareKindLabel}: $category',
                  if (city.isNotEmpty) '${l10n.adminLabelCity}: $city',
                  if (location.isNotEmpty) l10n.adminLocationValue(location),
                  if (rating.isNotEmpty) l10n.adminRatingValue(rating),
                ].join(' | ');

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: adminCardShape(accentIndex: index + 1),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_activity_outlined,
                      color: AdminPalette.accentAt(index + 1),
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
                          onPressed: () =>
                              _openActivityForm(existing: activity),
                        ),
                        IconButton(
                          tooltip: l10n.adminTooltipDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(activity),
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
      bottomNavigationBar: const AdminBottomNav(
        current: AdminNavTab.activities,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openActivityForm,
        backgroundColor: AdminPalette.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.adminAddActivity),
      ),
    );
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

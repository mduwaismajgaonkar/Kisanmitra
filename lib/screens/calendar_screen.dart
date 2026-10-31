import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../services/app_strings.dart';

const String storageKey = 'activities';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<Activity> activities = [];
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return;

    final list = jsonDecode(raw) as List;
    if (!mounted) return;
    setState(() {
      activities
        ..clear()
        ..addAll(list.map((e) => Activity.fromJson(e as Map<String, dynamic>)));
    });
  }

  Future<void> saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final text = jsonEncode(activities.map((a) => a.toJson()).toList());
    await prefs.setString(storageKey, text);
  }

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Activity> activitiesOn(DateTime day) =>
      activities.where((a) => sameDay(a.date, day)).toList();

  Future<void> confirmDelete(Activity a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(dialogContext, 'delete_q')),
        content: Text(
            '${tr(dialogContext, 'act_${a.type.name}')} · ${a.date.day}/${a.date.month}/${a.date.year}\n${tr(dialogContext, 'delete_msg')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr(dialogContext, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr(dialogContext, 'delete')),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => activities.remove(a));
      saveActivities();
    }
  }

  Future<void> showActivityDialog({Activity? existing}) async {
    ActivityType type = existing?.type ?? ActivityType.irrigation;
    final noteController = TextEditingController(text: existing?.note ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(tr(dialogContext,
                  existing == null ? 'act_add' : 'act_edit')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<ActivityType>(
                    value: type,
                    isExpanded: true,
                    items: ActivityType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(tr(dialogContext, 'act_${t.name}')),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => type = v);
                    },
                  ),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                        labelText: tr(dialogContext, 'act_note')),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(tr(dialogContext, 'cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      final updated = Activity(
                        date: existing?.date ?? selectedDate,
                        type: type,
                        note: noteController.text,
                      );
                      if (existing == null) {
                        activities.add(updated);
                      } else {
                        final i = activities.indexOf(existing);
                        if (i != -1) activities[i] = updated;
                      }
                    });
                    saveActivities();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(tr(dialogContext, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);
    final todays = activitiesOn(selectedDate);
    final dateText =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'cal_title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActivityDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TableCalendar<Activity>(
              locale: lang,
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              eventLoader: activitiesOn,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDate = selected;
                  focusedDay = focused;
                });
              },
              onPageChanged: (focused) => focusedDay = focused,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '${tr(context, 'activities')} · $dateText',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          if (todays.isEmpty) Text(tr(context, 'none_yet')),
          for (final a in todays)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: Icon(Icons.agriculture, color: Colors.green.shade700),
                ),
                title: Text(tr(context, 'act_${a.type.name}')),
                subtitle: a.note.isEmpty ? null : Text(a.note),
                onTap: () => showActivityDialog(existing: a),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: tr(context, 'delete'),
                  onPressed: () => confirmDelete(a),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
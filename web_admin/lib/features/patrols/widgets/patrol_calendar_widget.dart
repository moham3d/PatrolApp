import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/models/patrol.dart';
import '../providers/patrols_provider.dart';

/// Patrol calendar widget with scheduling capabilities
class PatrolCalendarWidget extends ConsumerWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const PatrolCalendarWidget({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDayPatrols = ref.watch(patrolsByDateProvider(selectedDay));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Calendar
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patrol Schedule',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TableCalendar<Patrol>(
                        firstDay:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(selectedDay, day),
                        eventLoader: (day) => _getPatrolsForDay(ref, day),
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          markerDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        onDaySelected: onDaySelected,
                        onPageChanged: (focusedDay) {
                          // Load patrols for the new month if needed
                          ref.read(patrolsProvider.notifier).loadPatrols(
                                dateFrom: DateTime(
                                    focusedDay.year, focusedDay.month, 1),
                                dateTo: DateTime(
                                    focusedDay.year, focusedDay.month + 1, 0),
                              );
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, patrols) {
                            return _buildMarkers(context, patrols);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Selected day details
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatSelectedDay(selectedDay),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Patrol count summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.route,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedDayPatrols.length} Patrol${selectedDayPatrols.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patrol list for selected day
                    Expanded(
                      child: selectedDayPatrols.isEmpty
                          ? _buildEmptyDayView()
                          : _buildPatrolList(context, selectedDayPatrols),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Patrol> _getPatrolsForDay(WidgetRef ref, DateTime day) {
    return ref.read(patrolsProvider.notifier).getPatrolsForDate(day);
  }

  Widget _buildMarkers(BuildContext context, List<Patrol> patrols) {
    if (patrols.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: patrols.take(3).map((patrol) {
        return Container(
          margin: const EdgeInsets.only(top: 5, right: 1),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _getPatrolStatusColor(patrol.status),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyDayView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No patrols scheduled',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatrolList(BuildContext context, List<Patrol> patrols) {
    return ListView.builder(
      itemCount: patrols.length,
      itemBuilder: (context, index) {
        final patrol = patrols[index];
        return _buildPatrolCard(context, patrol);
      },
    );
  }

  Widget _buildPatrolCard(BuildContext context, Patrol patrol) {
    final statusColor = _getPatrolStatusColor(patrol.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patrol.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(patrol.scheduledStart)} - ${_formatTime(patrol.scheduledEnd)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (patrol.assignedTo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patrol.assignedTo!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            if (patrol.site != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patrol.site!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                patrol.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPatrolStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatSelectedDay(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

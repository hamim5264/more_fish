import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/cattle_notifications_controller.dart';

class CattleNotificationsView extends StatelessWidget {
  const CattleNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CattleNotificationsController>();

    return Scaffold(
      backgroundColor: const Color(0xffebffff),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.error.value),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.fetchNotifications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text('No notifications found.'));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              final bool isRead = notification.isRead ?? false;

              return Card(
                elevation: isRead ? 0 : 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isRead ? Colors.grey.shade200 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.urgency?.toUpperCase() ?? 'INFO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _getUrgencyColor(notification.urgency),
                            ),
                          ),
                          Text(
                            _formatDate(notification.notifiedAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message ?? '--',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                          color: isRead ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (notification.sensorName != null)
                        Text(
                          "Sensor: ${notification.sensorName}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toUpperCase()) {
      case 'WARNING':
        return Colors.red;
      case 'DANGER':
        return Colors.red;
      case 'ALERT':
        return Colors.redAccent;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    try {
      final dt = DateTime.parse(dateStr).toLocal();

      final adjustedDt = dt.add(const Duration(hours: 6));
      return DateFormat('dd MMM yyyy, hh:mm a').format(adjustedDt);
    } catch (_) {
      return dateStr;
    }
  }
}

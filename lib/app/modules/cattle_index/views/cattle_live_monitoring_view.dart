import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/cattle_live_monitoring_controller.dart';
import '../controllers/cattle_header_controller.dart';
import '../../../response/cattle_farrm_dashboard_response.dart' as resp;

import 'package:intl/intl.dart';

class CattleLiveMonitoringView extends StatelessWidget {
  const CattleLiveMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<CattleHeaderController>();
    final ctrl = Get.put(CattleLiveMonitoringController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          children: [
            _CattleCareHeader(header: header),
            Expanded(
              child: GetBuilder<CattleLiveMonitoringController>(
                builder: (controller) {
                  return _LoggedInDashboard(controller: controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CattleCareHeader extends StatelessWidget {
  const _CattleCareHeader({required this.header});

  final CattleHeaderController header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/icons/dma_cattle_care.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            header.district.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Obx(
                          () => Text(
                            header.description.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff546e7a),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Obx(
                          () => header.sunlight.value.isNotEmpty
                              ? Text(
                                  "Sunlight: ${header.sunlight.value}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => Text(
                            header.tempText.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Text(
                          "  |  ",
                          style: TextStyle(color: Colors.black26),
                        ),
                        Obx(
                          () => Text(
                            header.humidityText.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      header.formattedDate.value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      header.formattedTime.value,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInDashboard extends StatelessWidget {
  const _LoggedInDashboard({required this.controller});

  final CattleLiveMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dashboard = controller.cattleFarmDashboardResponse.value?.data;

      if (controller.isLoading.value && dashboard == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty && dashboard == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load: ${controller.error.value}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.fetchFarmList,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshLiveData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                _DeviceDropdown(controller: controller),
                const SizedBox(height: 10),
                if (dashboard?.device != null)
                  _DeviceHeader(
                    deviceName: dashboard!.device!.deviceName ?? '--',
                    deviceStatus: dashboard.device!.deviceStatus ?? 'Offline',
                    lastSync: dashboard.device!.sensors?.isNotEmpty == true
                        ? dashboard.device!.sensors!.first.dataTime ?? '--'
                        : '--',
                  ),
                const SizedBox(height: 10),
                if (dashboard?.device?.sensors != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: dashboard!.device!.sensors!.map((sensor) {
                      return _MetricCard(
                        iconAsset: _getSensorIcon(sensor.name),
                        title: _getSensorDisplayName(sensor.name),
                        value: '${sensor.lastValue} ${sensor.unit}',
                        isDanger:
                            sensor.dangerStatus?.toLowerCase() == 'danger',
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                if (dashboard?.device?.switches != null &&
                    dashboard!.device!.switches!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Switches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: (dashboard.device!.isOnline ?? false)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: dashboard.device!.switches!.map((sw) {
                      return _SwitchTile(
                        switchItem: sw,
                        isOnline: (dashboard.device!.isOnline ?? false),
                        onChanged: (val) {
                          if (sw.switchId != null) {
                            controller.toggleSwitch(sw.switchId!, val);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 254, 254),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Note: The parameters are changeable according to installation of device.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                if (controller.error.value.isNotEmpty)
                  Text(
                    'Last error: ${controller.error.value}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getSensorIcon(String? name) {
    final n = name?.toLowerCase() ?? '';
    if (n.contains('temperature')) return 'assets/icons/cattle_temperature.png';
    if (n.contains('humidity')) return 'assets/icons/cattle_humidity.png';
    if (n.contains('nh3')) return 'assets/icons/cattle_nh3.png';
    if (n.contains('tvoc')) return 'assets/icons/cattle_voc.png';
    if (n.contains('co2')) return 'assets/icons/cattle_co2.png';
    if (n.contains('pm2_5')) return 'assets/icons/cattle_pm25.png';
    if (n.contains('pm1_0')) return 'assets/icons/cattle_pm10.png';
    if (n.contains('methane')) return 'assets/icons/cattle_nh3.png';
    return 'assets/icons/cattle_nh3.png';
  }

  String _getSensorDisplayName(String? name) {
    final n = name?.toLowerCase() ?? '';
    if (n == 'temperature') return 'Temperature';
    if (n == 'humidity') return 'Humidity';
    if (n == 'nh3_gas') return 'Ammonia (NH3)';
    if (n == 'tvoc') return 'TVOC';
    if (n == 'co2') return 'Carbon dioxide';
    if (n == 'pm2_5') return 'PM 2.5';
    if (n == 'pm1_0') return 'PM 1.0';
    if (n == 'methane_ppm') return 'Methane (CH4)';
    return n.toUpperCase();
  }
}

class _DeviceDropdown extends StatelessWidget {
  const _DeviceDropdown({required this.controller});

  final CattleLiveMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final farms = controller.cattleFarmListResponse.value?.data ?? [];
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 230, 230),
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedDeviceId.value.isEmpty
                ? null
                : controller.selectedDeviceId.value,
            hint: const Text('Select farm'),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: farms
                .map(
                  (f) => DropdownMenuItem<String>(
                    value: f.id.toString(),
                    child: Text(
                      f.name ?? 'Unknown Farm',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) controller.onDeviceChanged(v);
            },
          ),
        ),
      );
    });
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({
    required this.deviceName,
    required this.deviceStatus,
    required this.lastSync,
  });

  final String deviceName;
  final String deviceStatus;
  final String lastSync;

  @override
  Widget build(BuildContext context) {
    String displayTime = lastSync;
    try {
      DateFormat format = DateFormat("dd MMM yyyy hh:mm a");
      DateTime dateTime = format.parse(lastSync);
      DateTime updatedTime = dateTime.add(const Duration(hours: 6));
      displayTime = format.format(updatedTime);
    } catch (e) {
      displayTime = lastSync;
    }

    final bool isActuallyOnline = deviceStatus.toLowerCase() == 'online';

    return Row(
      children: [
        Icon(
          Icons.circle,
          color: isActuallyOnline ? Colors.green : Colors.red,
          size: 12,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            deviceName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          displayTime,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.isDanger,
  });

  final String iconAsset;
  final String title;
  final String value;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 14 * 2 - 12) / 2;
    return SizedBox(
      width: w,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconAsset, height: 56, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDanger ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.switchItem,
    required this.onChanged,
    required this.isOnline,
  });

  final resp.Switch switchItem;
  final ValueChanged<bool> onChanged;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CattleLiveMonitoringController>();
    final w = (MediaQuery.of(context).size.width - 14 * 2 - 10) / 2;
    final bool automationEnabled =
        controller.cattleFarmDashboardResponse.value?.data?.automationEnabled ??
        false;
    final bool canToggle =
        isOnline && (switchItem.isActive ?? false) && !automationEnabled;

    return Container(
      width: w,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: canToggle ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          if (canToggle)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switchItem.switchName ?? 'Unknown',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: canToggle ? Colors.black : Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (automationEnabled)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Auto Mode',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Switch(
            value: switchItem.isOn ?? false,
            onChanged: canToggle ? onChanged : null,
            activeTrackColor: Colors.green.shade200,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

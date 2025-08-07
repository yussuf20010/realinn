import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/dynamic_config.dart';
import '../modals/location_filter_modal.dart';
import '../providers/home_providers.dart';

class HotelsSectionHeader extends ConsumerWidget {
  const HotelsSectionHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicConfig = ref.watch(dynamicConfigProvider);
    final primaryColor = dynamicConfig.primaryColor ?? Color(0xFF895ffc);
    final selectedLocations = ref.watch(selectedLocationsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'hotels'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          Spacer(),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLocations.isNotEmpty ? Colors.orange : primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(0, 36),
                ),
                icon: Icon(Icons.filter_list, size: 18),
                label: Text(
                  selectedLocations.isNotEmpty
                    ? 'filtered'.tr(namedArgs: {'count': selectedLocations.length.toString()})
                    : 'filter'.tr(),
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () async {
                  final selected = await showModalBottomSheet<List<String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => LocationFilterModal(),
                  );
                  if (selected != null) {
                    ref.read(selectedLocationsProvider.notifier).state = selected;
                  }
                },
              ),
              SizedBox(width: 8),
              if (selectedLocations.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size(0, 36),
                  ),
                  icon: Icon(Icons.clear, size: 18),
                  label: Text('clear'.tr(), style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    ref.read(selectedLocationsProvider.notifier).state = [];
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}


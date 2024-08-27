import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:task_manager/app/appwidgets/settings/widgets/settings_cart.dart';
import 'package:task_manager/app/controller/taskscontroller.dart';
import 'package:task_manager/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final todoController = Get.put(TasksController());
  final themeController = Get.put(ThemeController());
  String? appVersion;

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  void initState() {
    infoVersion();
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              icon: const Icon(Iconsax.brush_1),
              text: 'appearance'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom),
                      child: StatefulBuilder(
                        builder: (BuildContext context, setState) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Text(
                                    'appearance'.tr,
                                    style:
                                        context.textTheme.titleLarge?.copyWith(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(Iconsax.moon),
                                  text: 'theme'.tr,
                                  dropdown: true,
                                  dropdownName: themeController.themeapp.value.tr,
                                  dropdownList: <String>[
                                    'system'.tr,
                                    'dark'.tr,
                                    'light'.tr
                                  ],
                                  dropdownCange: (String? newValue) {
                                    ThemeMode themeMode =
                                        newValue?.tr == 'system'.tr
                                            ? ThemeMode.system
                                            : newValue?.tr == 'dark'.tr
                                                ? ThemeMode.dark
                                                : ThemeMode.light;
                                    String theme = newValue?.tr == 'system'.tr
                                        ? 'system'
                                        : newValue?.tr == 'dark'.tr
                                            ? 'dark'
                                            : 'light';
                                    themeController.saveTheme(theme);
                                    themeController.changeThemeMode(themeMode);
                                    setState(() {});
                                  },
                                ),
                                const Gap(10),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.hierarchy_square_2),
              text: 'version'.tr,
              info: true,
              textInfo: '$appVersion',
            ),
          ],
        ),
      ),
    );
  }
}
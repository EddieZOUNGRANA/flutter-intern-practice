import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager/app/appwidgets/profil/profil.dart';
import 'package:task_manager/app/appwidgets/settings/view/settings.dart';
import 'package:task_manager/app/appwidgets/tasks/view/dashboard.dart';
import 'package:task_manager/app/appwidgets/tasks/widgets/tasks_action.dart';
import 'package:task_manager/app/appwidgets/todos/view/tasks.dart';
import 'package:task_manager/app/appwidgets/todos/widgets/taskstodo_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabIndex = 0;

  final pages = const [
    Dashboard(),
    Tasks(),
    SettingsPage(),
    ProfilePage(),
  ];

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Iconsax.folder_2),
            selectedIcon: const Icon(Iconsax.folder_25),
            label: 'Dashboard'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.task_square),
            selectedIcon: const Icon(Iconsax.task_square5),
            label: 'Task'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.setting_4),
            selectedIcon: const Icon(Iconsax.setting_45),
            label: 'settings'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.profile_circle),
            selectedIcon: const Icon(Iconsax.profile_circle5),
            label: 'Profile'.tr,
          ),
        ],
      ),
      floatingActionButton: tabIndex == 2 || tabIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  enableDrag: false,
                  isDismissible: false,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return tabIndex == 0
                        ? TasksAction(
                            text: 'create'.tr,
                            edit: false,
                          )
                        : TakstodosAction(
                            text: 'create'.tr,
                            edit: false,
                            category: true,
                          );
                  },
                );
              },
              child: const Icon(Iconsax.add),
            ),
    );
  }
}

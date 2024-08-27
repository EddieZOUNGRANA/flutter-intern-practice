import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager/app/appwidgets/tasks/widgets/task_list.dart';
import 'package:task_manager/app/controller/taskscontroller.dart';
import 'package:task_manager/app/appwidgets/tasks/widgets/statistics.dart';
import 'package:task_manager/app/common/my_delegate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final tasksController = Get.put(TasksController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var createdTasks = tasksController.createdTasks();
        var completedTasks = tasksController.completedTasks();
        var precent = (completedTasks / createdTasks * 100).toStringAsFixed(0);

        return PopScope(
          canPop: tasksController.isPop.value,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            
            if (tasksController.isMultiSelectionTask.isTrue) {
              tasksController.doMultiSelectionTaskClear();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: tasksController.isMultiSelectionTask.isTrue
                  ? IconButton(
                      onPressed: () =>
                          tasksController.doMultiSelectionTaskClear(),
                      icon: const Icon(
                        Iconsax.close_square,
                        size: 20,
                      ),
                    )
                  : null,
              title: Text(
                'Dashboard'.tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Visibility(
                  visible: tasksController.selectedTask.isNotEmpty,
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.trush_square,
                      size: 20,
                    ),
                    onPressed: () async {
                      await showAdaptiveDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog.adaptive(
                            title: Text(
                              'deleteCategory'.tr,
                              style: context.textTheme.titleLarge,
                            ),
                            content: Text(
                              'deleteCategoryQuery'.tr,
                              style: context.textTheme.titleMedium,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('cancel'.tr,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: Colors.blueAccent))),
                              TextButton(
                                  onPressed: () {
                                    // tasksController.deleteTask(
                                    //     tasksController.selectedTask);
                                    tasksController.doMultiSelectionTaskClear();
                                    //
                                    // Get.back();
                                  },
                                  child: Text('delete'.tr,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(color: Colors.red))),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: tasksController.selectedTask.isNotEmpty,
                  child: IconButton(
                    icon: Icon(
                      tabController.index == 0
                          ? Iconsax.archive_1
                          : Iconsax.refresh_left_square,
                      size: 20,
                    ),
                    onPressed: () async {
                      await showAdaptiveDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog.adaptive(
                            title: Text(
                              tabController.index == 0
                                  ? 'archiveCategory'.tr
                                  : 'noArchiveCategory'.tr,
                              style: context.textTheme.titleLarge,
                            ),
                            content: Text(
                              tabController.index == 0
                                  ? 'archiveCategoryQuery'.tr
                                  : 'noArchiveCategoryQuery'.tr,
                              style: context.textTheme.titleMedium,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('cancel'.tr,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: Colors.blueAccent))),
                              TextButton(
                                  onPressed: () {
                                    // tabController.index == 0
                                    //     ? tasksController.archiveTask(
                                    //         tasksController.selectedTask)
                                    //     : tasksController.noArchiveTask(
                                    //         tasksController.selectedTask);
                                     tasksController.doMultiSelectionTaskClear();
                                    // Get.back();
                                  },
                                  child: Text(
                                      tabController.index == 0
                                          ? 'archive'.tr
                                          : 'noArchive'.tr,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(color: Colors.red))),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                physics: const NeverScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Statistics(
                            createdTasks: createdTasks,
                            completedTasks: completedTasks,
                            precent: precent,
                          ),
                        ],
                      ),
                    ),
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverPersistentHeader(
                        delegate: MyDelegate(
                          TabBar(
                            tabAlignment: TabAlignment.start,
                            controller: tabController,
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                return Colors.transparent;
                              },
                            ),
                            tabs: [
                              Tab(text: 'active'.tr),
                              Tab(text: 'archive'.tr),
                            ],
                          ),
                        ),
                        floating: true,
                        pinned: true,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: tabController,
                  children: const [
                    TasksList(
                      archived: false,
                    ),
                    TasksList(
                      archived: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

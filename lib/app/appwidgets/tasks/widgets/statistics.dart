import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:task_manager/main.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.createdTasks,
    required this.completedTasks,
    required this.precent,
  });
  final int createdTasks;
  final int completedTasks;
  final String precent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tâche terminée'.tr,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '$completedTasks/$createdTasks ${'terminée'.tr}',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat.MMMMEEEEd(locale.languageCode)
                        .format(DateTime.now()),
                    style: context.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SleekCircularSlider(
              appearance: CircularSliderAppearance(
                animationEnabled: false,
                angleRange: 360,
                startAngle: 270,
                size: 70,
                infoProperties: InfoProperties(
                  modifier: (percentage) {
                    return createdTasks != 0 ? '$precent%' : '0%';
                  },
                  mainLabelStyle:
                      context.textTheme.labelLarge?.copyWith(fontSize: 18),
                ),
                customColors: CustomSliderColors(
                  progressBarColors: <Color>[
                    Colors.blueAccent,
                    Colors.greenAccent,
                  ],
                  trackColor: Colors.grey.shade300,
                ),
                customWidths: CustomSliderWidths(
                  progressBarWidth: 7,
                  trackWidth: 3,
                  handlerSize: 0,
                  shadowWidth: 0,
                ),
              ),
              min: 0,
              max: createdTasks != 0 ? createdTasks.toDouble() : 1,
              initialValue: completedTasks.toDouble(),
            ),
          ],
        ),
      ),
    );
  }
}

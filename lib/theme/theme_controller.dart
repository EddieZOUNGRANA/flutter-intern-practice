import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  late Box _box;
  final themeapp = ''.obs;

  ThemeMode get theme => themeapp.value == 'system'
      ? ThemeMode.system
      : themeapp.value == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
    loadTheme();
  }

  Future<void> saveTheme(String themeMode) async {
    themeapp.value = themeMode;
    await _box.put('theme', themeMode); 
  }

  void loadTheme() {
    themeapp.value = _box.get('theme') ?? 'system'; 
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('theme'); 
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}

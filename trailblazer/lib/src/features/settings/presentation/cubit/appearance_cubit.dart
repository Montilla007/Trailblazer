import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppearanceCubit extends Cubit<ThemeMode> {
  AppearanceCubit() : super(ThemeMode.light);

  void setDarkMode(bool enabled) {
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
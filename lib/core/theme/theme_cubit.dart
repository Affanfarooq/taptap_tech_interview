import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

/// Cubit for managing app theme
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Toggle between light and dark mode
  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  /// Set theme mode explicitly
  void setThemeMode(bool isDark) {
    emit(state.copyWith(isDarkMode: isDark));
  }
}

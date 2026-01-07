import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../blocs/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context,
              title: 'Appearance',
              children: [
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return ListTile(
                      leading: Icon(
                        state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        state.isDarkMode
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                      ),
                      trailing: Switch(
                        value: state.isDarkMode,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleTheme(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'Account',
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(state.username ?? 'User'),
                      subtitle: const Text('Logged in'),
                      trailing: OutlinedButton.icon(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Logout'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'About',
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Framework'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Flutter Web',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

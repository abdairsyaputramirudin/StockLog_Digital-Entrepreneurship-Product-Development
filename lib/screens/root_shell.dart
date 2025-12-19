import 'package:flutter/material.dart';
import 'home_shell.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeShell(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: const Color(0xFFE9EEF9),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Colors.blue);
              }
              return const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.black54);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.blue);
              }
              return const IconThemeData(color: Colors.black54);
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined), label: "Home"),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: "Profil"),
          ],
        ),
      ),
    );
  }
}

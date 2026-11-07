import 'package:flutter/material.dart';

import 'theme.dart';
import 'ui/root_navigation.dart';

void main() {
  runApp(const TugaskuApp());
}

class TugaskuApp extends StatelessWidget {
  const TugaskuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugasku',
      debugShowCheckedModeBanner: false,
      theme: temaTerang,
      darkTheme: temaGelap,
      themeMode: ThemeMode.system,
      home: const RootNavigation(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/providers/Category/category_provider.dart';
import 'package:vegiffyy_vendor/providers/Profile/vendor_provider.dart';
import 'package:vegiffyy_vendor/providers/vendor_plan_provider.dart';
import 'package:vegiffyy_vendor/views/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/dashboard_provider.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VegiffyyVendorApp());
}

class VegiffyyVendorApp extends StatelessWidget {
  const VegiffyyVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => VendorNavigationProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(
  create: (_) => VendorPlanProvider(),
),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Vegiffyy Vendor',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.mode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

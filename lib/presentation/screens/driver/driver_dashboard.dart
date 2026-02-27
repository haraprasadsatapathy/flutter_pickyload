import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/routes.dart';
import '../../cubit/driver/home/home_tab_bloc.dart';
import '../../cubit/driver/home/home_tab_event.dart';
import 'tabs/home_tab.dart';
import 'tabs/my_loads_tab.dart';
import 'tabs/profile_tab.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> with RouteAware {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const MyLoadsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Initial fetch for home tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeTabBloc>().add(FetchHomePage());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when a route has been popped and this route is now visible
    // Refresh home tab data when returning from another screen
    if (_selectedIndex == 0) {
      context.read<HomeTabBloc>().add(FetchHomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            context.read<HomeTabBloc>().add(FetchHomePage());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'My Loads',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/work_in_progress_view.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const WorkInProgressView(
      title: 'Dashboard',
      description: 'Vista de dashboard antigua en desuso.',
    );
  }
}

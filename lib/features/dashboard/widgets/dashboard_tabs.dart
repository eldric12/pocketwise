import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketwise/features/auth/services/auth_service.dart';
import 'package:pocketwise/features/auth/screens/login_screen.dart';
import 'package:pocketwise/features/auth/providers/auth_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../models/dashboard_ui_models.dart';
import '../models/transaction.dart';
import '../utils/dashboard_ui_helpers.dart';
import 'dashboard_common_widgets.dart';

part 'dashboard_tabs/budget_calculation.dart';
part 'dashboard_tabs/home_tab.dart';
part 'dashboard_tabs/activity_tab.dart';
part 'dashboard_tabs/budgets_tab.dart';
part 'dashboard_tabs/more_tab.dart';
part 'dashboard_tabs/home_summary_widgets.dart';
part 'dashboard_tabs/spending_overview.dart';
part 'dashboard_tabs/transaction_widgets.dart';
part 'dashboard_tabs/budget_widgets.dart';
part 'dashboard_tabs/setting_tab.dart';
part 'dashboard_tabs/report_analytics.dart';
part 'dashboard_tabs/spending_chart_data.dart';
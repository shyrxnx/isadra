import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/state/storybook_state.dart';
import '../../../core/state/sound_state.dart';
import '../../../core/state/processed_image.dart';
import '../../../models/storybook.dart';
import '../../../core/services/animation_cache_manager.dart';
import '../../../core/theme/app_colors.dart';

class ReportSettings extends StatefulWidget {
  const ReportSettings({super.key});

  @override
  State<ReportSettings> createState() => _ReportSettingsState();
}

class _ReportSettingsState extends State<ReportSettings> {
  bool _isLoading = true;
  int _totalStorybooks = 0;
  int _totalSlides = 0;
  int _totalAnimations = 0;
  bool _soundEnabled = false;
  String _selectedSound = '';
  DateTime _lastUsed = DateTime.now();
  int _appOpenCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      // Load storybook data
      final storybooks = await Storybook.loadStorybooks();
      int totalSlides = 0;
      for (var book in storybooks) {
        totalSlides += book.slides.length;
      }

      // Load animations data
      final animations = await AnimationCacheManager.getSavedAnimations();

      // Load app usage data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final appOpenCount = prefs.getInt('app_open_count') ?? 0;
      final lastUsedMillis = prefs.getInt('last_used_timestamp');
      final lastUsed = lastUsedMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastUsedMillis)
          : DateTime.now();

      // Check if this is the first load (not a refresh)
      if (_appOpenCount == 0) {
        // Update app usage data
        await prefs.setInt('app_open_count', appOpenCount + 1);
      }

      await prefs.setInt('last_used_timestamp', DateTime.now().millisecondsSinceEpoch);

      setState(() {
        _totalStorybooks = storybooks.length;
        _totalSlides = totalSlides;
        _totalAnimations = animations.length;
        _appOpenCount = appOpenCount + 1; // This will still show the count correctly
        _lastUsed = lastUsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get state from providers
    final soundState = Provider.of<SoundState>(context);
    final storybookState = Provider.of<StorybookState>(context);
    final processedImageProvider = Provider.of<ProcessedImageProvider>(context);

    _soundEnabled = soundState.isSoundEnabled;
    _selectedSound = soundState.soundOptions
        .firstWhere((option) => option.assetPath == soundState.selectedSound, 
        orElse: () => soundState.soundOptions.first)
        .displayName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Report'),
        backgroundColor: const Color(0xFF5AC8FA),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildReportCard(
                    title: 'App Usage',
                    icon: Icons.analytics_outlined,
                    color: AppColors.primary,
                    children: [
                      _buildReportItem('App opened', '$_appOpenCount times'),
                      _buildReportItem('Last used', _formatDate(_lastUsed)),
                      _buildReportItem('Current session', _formatDate(DateTime.now())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReportCard(
                    title: 'Content Statistics',
                    icon: Icons.auto_stories,
                    color: AppColors.secondary,
                    children: [
                      _buildReportItem('Storybooks created', '$_totalStorybooks'),
                      _buildReportItem('Total slides', '$_totalSlides'),
                      _buildReportItem('Storybook feature', storybookState.isEnabled ? 'Enabled' : 'Disabled'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReportCard(
                    title: 'Animations',
                    icon: Icons.animation,
                    color: AppColors.accent,
                    children: [
                      _buildReportItem('Animations saved', '$_totalAnimations'),
                      _buildReportItem('Processing status',
                          processedImageProvider.originalImageUrl != null ? 'Active' : 'None'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReportCard(
                    title: 'Sound Settings',
                    icon: Icons.volume_up,
                    color: AppColors.info,
                    children: [
                      _buildReportItem('Sound', _soundEnabled ? 'Enabled' : 'Disabled'),
                      if (_soundEnabled)
                        _buildReportItem('Selected sound', _selectedSound),
                    ],
                  ),
                ],
              ),
            ),
    ));
  }
  
  // Header with title and description
  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.analytics_outlined, color: Colors.teal, size: 28),
                SizedBox(width: 12),
                Text(
                  'ISADRA Usage Report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'View your app usage statistics and content information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              // Move dynamic values into a non-const builder
              final now = DateTime.now();
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5AC8FA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Report date: ${_formatDate(now)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  // Grid of statistics cards
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Storybooks', '$_totalStorybooks', Icons.auto_stories, AppColors.primary),
        _buildStatCard('Slides', '$_totalSlides', Icons.slideshow, AppColors.secondary),
        _buildStatCard('Animations', '$_totalAnimations', Icons.animation, AppColors.accent),
        _buildStatCard('App Opens', '$_appOpenCount', Icons.touch_app, AppColors.info),
      ],
    );
  }
  
  // Statistic card for the grid
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.teal, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Professional report card
  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }



  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
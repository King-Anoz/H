import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  String _selectedQuality = 'high';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildUrlInput(),
            _buildQualitySelector(),
            _buildDownloadButton(),
            _buildProgressIndicator(),
            const Spacer(),
            _buildDownloadedFiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'تحميل الفيديو',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
        ),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(text: 'يوتيوب'),
          Tab(text: 'انستجرام'),
          Tab(text: 'تيك توك'),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          hintText: 'ضع رابط الفيديو هنا',
          prefixIcon: const Icon(Icons.link),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'high',
            label: Text('جودة عالية'),
            icon: Icon(Icons.high_quality),
          ),
          ButtonSegment(
            value: 'low',
            label: Text('جودة منخفضة'),
            icon: Icon(Icons.low_priority),
          ),
        ],
        selected: {_selectedQuality},
        onSelectionChanged: (Set<String> selection) {
          setState(() {
            _selectedQuality = selection.first;
          });
        },
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: provider.isDownloading
                ? null
                : () async {
                    try {
                      await provider.downloadYouTubeVideo(
                        _urlController.text,
                        _selectedQuality,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم التحميل بنجاح!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.download),
            label: const Text('تحميل'),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        if (!provider.isDownloading) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              LinearProgressIndicator(value: provider.progress),
              const SizedBox(height: 8),
              Text(provider.currentTask),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadedFiles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملفات المحملة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // TODO: Implement file list
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}

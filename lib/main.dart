import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const ARCNTVApp());
}

class ARCNTVApp extends StatelessWidget {
  const ARCNTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARCN TV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C851), // ARCN green
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ARCNTVLiveScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ARCNTVLiveScreen extends StatefulWidget {
  const ARCNTVLiveScreen({super.key});

  @override
  State<ARCNTVLiveScreen> createState() => _ARCNTVLiveScreenState();
}

class _ARCNTVLiveScreenState extends State<ARCNTVLiveScreen>
    with TickerProviderStateMixin {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Replace with your livestream URL. Supports HLS (.m3u8) for best compatibility.
  static const String _streamUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_streamUrl));
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
    _initializeAndPlay();
    _hideControlsAfterDelay();
  }

  Future<void> _initializeAndPlay() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load stream';
          _isLoading = false;
        });
      }
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        _fadeController.forward();
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _fadeController.reverse();
      _hideControlsAfterDelay();
    } else {
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (_errorMessage != null)
              _buildErrorState()
            else if (_isLoading)
              _buildLoadingState()
            else
              _buildVideoPlayer(),

            // Overlay Controls
            if (_showControls) _buildOverlayControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Stream Unavailable',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initializeAndPlay();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C851),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF00C851),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Connecting to ARCN TV...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio == 0
          ? 16 / 9
          : _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  Widget _buildOverlayControls() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(150, 0, 0, 0),
                  Color.fromARGB(100, 0, 0, 0),
                  Color.fromARGB(150, 0, 0, 0),
                ],
              ),
            ),
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // ARCN TV Logo
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00C851),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tv,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // ARCN TV Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCN TV',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'LIVE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF00C851),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Live indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                },
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Volume Control
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  // Toggle mute
                  _controller.setVolume(_controller.value.volume > 0 ? 0.0 : 1.0);
                },
                icon: Icon(
                  _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
            // Fullscreen Button
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  // Toggle fullscreen
                  SystemChrome.setEnabledSystemUIMode(
                    _showControls ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
                  );
                },
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class EmergencySiren extends StatefulWidget {
  const EmergencySiren({super.key});

  @override
  State<EmergencySiren> createState() => _EmergencySirenState();
}

class _EmergencySirenState extends State<EmergencySiren> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.onPlayerComplete.listen((event) {
      if (_isPlaying && mounted) {
        _player.play(AssetSource('sounds/siren.mp3'));
      }
    });
    _loadSirenState();
    _checkSirenStatePeriodically();
  }

  void _checkSirenStatePeriodically() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        final sirenState = prefs.getString('flutter.siren_state') ?? 'stopped';
        final isPlayingFromPrefs = sirenState == 'playing';

        if (isPlayingFromPrefs != _isPlaying) {
          if (isPlayingFromPrefs) {
            await _playSiren();
          } else {
            await _stopSiren();
          }
        }
      } catch (_) {}
      if (mounted) _checkSirenStatePeriodically();
    });
  }

  Future<void> _loadSirenState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPlaying = prefs.getBool('siren_playing') ?? false;
      if (mounted) {
        setState(() => _isPlaying = isPlaying);
        if (isPlaying) await _playSiren();
      }
    } catch (_) {}
  }

  Future<void> _playSiren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sirenState = prefs.getString('flutter.siren_state') ?? 'stopped';

      if (sirenState == 'playing' && !_isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _errorMessage = null;
          });
        }
        return;
      }

      await FlutterVolumeController.setVolume(1.0);
      if (!_isPlaying) {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource('sounds/siren.mp3'));
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _errorMessage = null;
          });
          await prefs.setString('flutter.siren_state', 'playing');
          await prefs.setBool('siren_playing', true);
          await WidgetService.updateSirenState(true);
        }
      }
    } catch (e) {
      if (mounted) {
        final message = '${context.l10n.playError}: ${e.toString()}';
        setState(() {
          _errorMessage = message;
          _isPlaying = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _stopSiren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutter.siren_state', 'stopped');
      await prefs.setBool('siren_playing', false);

      if (_isPlaying) {
        await _player.stop();
        await _player.setReleaseMode(ReleaseMode.release);
      }

      if (mounted) {
        setState(() {
          _isPlaying = false;
          _errorMessage = null;
        });
        await WidgetService.updateSirenState(false);
      }
    } catch (e) {
      if (mounted) {
        final message = '${context.l10n.stopError}: ${e.toString()}';
        setState(() => _errorMessage = message);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.siren,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _isPlaying ? Colors.red.shade100 : Colors.green.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? Colors.red : Colors.green)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    size: 80,
                    color: _isPlaying ? Colors.red[700] : Colors.green[700],
                  ),
                  onPressed: _isPlaying ? _stopSiren : _playSiren,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor:
                      _isPlaying ? Colors.red[700] : Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isPlaying ? _stopSiren : _playSiren,
                child: Text(
                  _isPlaying ? l10n.stopSiren : l10n.startSiren,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

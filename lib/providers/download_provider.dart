import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class DownloadProvider with ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();
  bool _isDownloading = false;
  double _progress = 0.0;
  String _currentTask = '';

  bool get isDownloading => _isDownloading;
  double get progress => _progress;
  String get currentTask => _currentTask;

  Future<String> get _downloadPath async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      final directory = await getExternalStorageDirectory();
      return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<void> downloadYouTubeVideo(String url, String quality) async {
    try {
      _isDownloading = true;
      _progress = 0;
      _currentTask = 'جاري تحليل الرابط...';
      notifyListeners();

      if (!kIsWeb) {
        if (Platform.isIOS) {
          var status = await Permission.photos.request();
          if (!status.isGranted) {
            throw Exception('تم رفض إذن الوصول إلى الصور');
          }
        } else {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('تم رفض إذن التخزين');
          }
        }
      }

      // Get video metadata
      var video = await _yt.videos.get(url);
      var manifest = await _yt.videos.streamsClient.getManifest(url);
      var streamInfo = quality == 'high' 
          ? manifest.muxed.withHighestBitrate()
          : manifest.muxed.withLowestBitrate();

      _currentTask = 'جاري التحميل...';
      notifyListeners();

      final downloadDir = await _downloadPath;
      var filePath = '$downloadDir/${video.title}.mp4';
      var file = File(filePath);
      var fileStream = file.openWrite();

      var stream = await _yt.videos.streamsClient.get(streamInfo);
      var len = streamInfo.size.totalBytes;
      var count = 0;

      await for (final data in stream) {
        count += data.length;
        _progress = count / len;
        fileStream.add(data);
        notifyListeners();
      }

      await fileStream.flush();
      await fileStream.close();

      // Share the video file
      if (Platform.isIOS) {
        await Share.shareXFiles([XFile(filePath)], text: video.title);
      }

      _isDownloading = false;
      _progress = 1.0;
      _currentTask = 'تم التحميل بنجاح!';
      notifyListeners();
    } catch (e) {
      _isDownloading = false;
      _progress = 0;
      _currentTask = 'حدث خطأ: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }
}

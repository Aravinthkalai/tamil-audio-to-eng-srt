import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

void main() {
  runApp(const TamilSubtitleApp());
}

class TamilSubtitleApp extends StatelessWidget {
  const TamilSubtitleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tamil AI Subtitle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const SubtitleHomePage(),
    );
  }
}

class SubtitleHomePage extends StatefulWidget {
  const SubtitleHomePage({super.key});

  @override
  State<SubtitleHomePage> createState() => _SubtitleHomePageState();
}

class _SubtitleHomePageState extends State<SubtitleHomePage> {
  String? selectedFilePath;
  String? selectedFileName;

  String selectedQuality = 'Fast';

  bool isProcessing = false;
  int progress = 0;

  String resultText = '';

  // Select Whisper model based on the selected quality.
  WhisperModel getSelectedModel() {
    switch (selectedQuality) {
      case 'Balanced':
        return WhisperModel.medium;

      case 'High Accuracy':
        return WhisperModel.large;

      case 'Fast':
      default:
        return WhisperModel.small;
    }
  }

  Future<void> pickFile() async {
final result = await FilePicker.platform.pickFiles(
  type: FileType.audio,
);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
        selectedFileName = result.files.single.name;
        resultText = '';
        progress = 0;
      });
    }
  }

  String formatSrtTimestamp(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')},'
        '${milliseconds.toString().padLeft(3, '0')}';
  }

  String createSrt(List<WhisperTranscribeSegment> segments) {
    final buffer = StringBuffer();

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];

      final text = segment.text.trim();

      // Skip completely empty segments.
      if (text.isEmpty) {
        continue;
      }

      buffer.writeln(i + 1);

      buffer.writeln(
        '${formatSrtTimestamp(segment.fromTs)} --> '
        '${formatSrtTimestamp(segment.toTs)}',
      );

      buffer.writeln(text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<void> generateSubtitle() async {
    if (selectedFilePath == null) {
      setState(() {
        resultText = 'Please select an audio/video file first.';
      });
      return;
    }

    setState(() {
      isProcessing = true;
      progress = 0;
      resultText = 'Preparing Whisper model...';
    });

    try {
      final model = getSelectedModel();

      final controller = WhisperController();

      // Download the selected model if it is not already cached.
      await controller.downloadModel(model);

      final modelPath = await controller.getPath(model);

      if (!mounted) return;

      setState(() {
        resultText = 'Transcribing Tamil audio...';
      });

      final whisper = Whisper(model: model);

      final response = await whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: selectedFilePath!,
          language: 'ta',
          isTranslate: true,
          isNoTimestamps: false,
          splitOnWord: false,
        ),
        modelPath: modelPath,
        onProgress: (value) {
          if (mounted) {
            setState(() {
              progress = value;
              resultText = 'Transcribing... $value%';
            });
          }
        },
      );

      if (!mounted) return;

      final segments = response.segments ?? [];

      if (segments.isEmpty) {
        setState(() {
          isProcessing = false;
          resultText =
              'Transcription completed, but no timestamped segments '
              'were returned.';
        });
        return;
      }

      // Create SRT content from Whisper timestamped segments.
      final srtContent = createSrt(segments);

      if (srtContent.trim().isEmpty) {
        setState(() {
          isProcessing = false;
          resultText = 'No subtitle text was generated.';
        });
        return;
      }

      // Create the output filename using the input filename.
      final inputName = selectedFileName ?? 'subtitle';

      final baseName = inputName.replaceFirst(
        RegExp(r'\.[^.]+$'),
        '',
      );

      final srtFileName = '$baseName.srt';

      if (!mounted) return;

      setState(() {
        resultText = 'Subtitle generated. Choose where to save the SRT...';
      });

      // Open Android's native save dialog.
        final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save English Subtitle',
        fileName: srtFileName,
        bytes: Uint8List.fromList(
          utf8.encode(srtContent),
        ),
        allowedExtensions: ['srt'],
      );

      if (!mounted) return;

      if (savedPath != null) {
        setState(() {
          isProcessing = false;
          progress = 100;

          resultText =
              'Subtitle generated successfully!\n\n'
              'File: $srtFileName\n\n'
              'Saved to:\n$savedPath\n\n'
              'Total subtitle segments: ${segments.length}';
        });
      } else {
        setState(() {
          isProcessing = false;
          progress = 100;

          resultText =
              'Subtitle generated successfully, '
              'but saving was cancelled.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
        resultText = 'Error:\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil AI Subtitle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tamil → English Subtitles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: isProcessing ? null : pickFile,
              icon: const Icon(Icons.audio_file),
              label: const Text('Select Audio / Video'),
            ),

            const SizedBox(height: 12),

            if (selectedFileName != null)
              Text(
                selectedFileName!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedQuality,
              decoration: const InputDecoration(
                labelText: 'Quality',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Fast',
                  child: Text('Fast - Small'),
                ),
                DropdownMenuItem(
                  value: 'Balanced',
                  child: Text('Balanced - Medium'),
                ),
                DropdownMenuItem(
                  value: 'High Accuracy',
                  child: Text('High Accuracy - Large-v3'),
                ),
              ],
              onChanged: isProcessing
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedQuality = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isProcessing ? null : generateSubtitle,
              child: Text(
                isProcessing
                    ? 'Processing... $progress%'
                    : 'Generate Subtitle',
              ),
            ),

            const SizedBox(height: 20),

            if (isProcessing)
              LinearProgressIndicator(
                value: progress > 0 ? progress / 100 : null,
              ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resultText,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
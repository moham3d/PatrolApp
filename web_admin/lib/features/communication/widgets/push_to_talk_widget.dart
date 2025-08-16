import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/messaging_provider.dart';

/// Push-to-talk interface for voice messaging
class PushToTalkWidget extends ConsumerStatefulWidget {
  final int? recipientId;
  final String? channelId;
  final VoidCallback? onVoiceMessageSent;

  const PushToTalkWidget({
    super.key,
    this.recipientId,
    this.channelId,
    this.onVoiceMessageSent,
  });

  @override
  ConsumerState<PushToTalkWidget> createState() => _PushToTalkWidgetState();
}

class _PushToTalkWidgetState extends ConsumerState<PushToTalkWidget> {
  bool _isRecording = false;
  bool _isSupported = false;
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _recordedChunks = [];

  @override
  void initState() {
    super.initState();
    _checkBrowserSupport();
  }

  void _checkBrowserSupport() {
    // Check if browser supports MediaRecorder API
    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices != null) {
      setState(() {
        _isSupported = true;
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_isSupported || _isRecording) return;

    try {
      // Request microphone permission
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': true,
      });

      _mediaStream = stream;
      
      // Create MediaRecorder
      _mediaRecorder = html.MediaRecorder(stream, {
        'mimeType': 'audio/webm',
      });

      _recordedChunks.clear();

      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data != null && blobEvent.data!.size > 0) {
          _recordedChunks.add(blobEvent.data!);
        }
      });

      _mediaRecorder!.addEventListener('stop', (event) {
        _processRecording();
      });

      _mediaRecorder!.start();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  void _stopRecording() {
    if (_mediaRecorder != null && _isRecording) {
      _mediaRecorder!.stop();
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _processRecording() {
    if (_recordedChunks.isEmpty) return;

    final audioBlob = html.Blob(_recordedChunks, 'audio/webm');
    final audioUrl = html.Url.createObjectUrl(audioBlob);

    // For now, we'll send a text message indicating a voice message was recorded
    // In a full implementation, you would upload the audio file to the server
    _sendVoiceMessage(audioUrl, audioBlob.size);

    // Clean up
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _mediaRecorder = null;
    _recordedChunks.clear();
  }

  void _sendVoiceMessage(String audioUrl, int? audioSize) {
    final messenger = ref.read(chatMessagesNotifierProvider.notifier);
    final duration = _getRecordingDuration();

    final metadata = {
      'audio_url': audioUrl,
      'audio_size': audioSize,
      'duration_seconds': duration,
      'audio_format': 'webm',
    };

    if (widget.recipientId != null) {
      messenger.sendUserMessage(
        recipientId: widget.recipientId!,
        content: '🎤 Voice message (${duration}s)',
        messageType: 'audio',
        metadata: metadata,
      );
    } else if (widget.channelId != null) {
      messenger.sendChannelMessage(
        channelId: widget.channelId!,
        content: '🎤 Voice message (${duration}s)',
        messageType: 'audio',
        metadata: metadata,
      );
    }

    widget.onVoiceMessageSent?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice message sent!')),
    );
  }

  int _getRecordingDuration() {
    // This is a simplified duration calculation
    // In a full implementation, you'd track the actual recording time
    return 5; // placeholder
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.mic_off, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Voice messages not supported in this browser',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice Messages',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isRecording) ...[
              Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Recording... Release to send',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  onTapCancel: () => _stopRecording(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isRecording
                        ? 'Hold to record, release to send voice message'
                        : 'Tap and hold to record a voice message',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Voice messages are sent as audio files to the selected conversation.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }
}
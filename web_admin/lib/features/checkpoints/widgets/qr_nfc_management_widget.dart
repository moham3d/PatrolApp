import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../shared/models/checkpoint.dart';

/// Widget for managing QR codes and NFC tags for checkpoints
class QrNfcManagementWidget extends ConsumerStatefulWidget {
  final Checkpoint checkpoint;
  
  const QrNfcManagementWidget({
    super.key,
    required this.checkpoint,
  });

  @override
  ConsumerState<QrNfcManagementWidget> createState() => _QrNfcManagementWidgetState();
}

class _QrNfcManagementWidgetState extends ConsumerState<QrNfcManagementWidget> {
  bool _isGeneratingQr = false;
  bool _isGeneratingNfc = false;
  String? _qrCodeData;
  String? _nfcTagData;

  @override
  void initState() {
    super.initState();
    _qrCodeData = widget.checkpoint.qrCode;
    _nfcTagData = widget.checkpoint.nfcTag;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Code & NFC Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.checkpoint.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Code section
                      _buildQrCodeSection(),
                      const SizedBox(height: 32),
                      
                      // NFC section
                      _buildNfcSection(),
                      const SizedBox(height: 32),
                      
                      // Instructions
                      _buildInstructions(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'QR Code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_qrCodeData != null) ...[
              // QR Code preview
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QR Code',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.checkpoint.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Code Data',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _qrCodeData!,
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _copyToClipboard(_qrCodeData!),
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy to clipboard',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // QR Code actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _downloadQrCode,
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _printQrCode,
                                icon: const Icon(Icons.print),
                                label: const Text('Print'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _shareQrCode,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Generate QR Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No QR Code Generated',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate a unique QR code for this checkpoint to enable mobile scanning.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isGeneratingQr ? null : _generateQrCode,
                      icon: _isGeneratingQr 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.qr_code),
                      label: Text(_isGeneratingQr ? 'Generating...' : 'Generate QR Code'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNfcSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nfc, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'NFC Tag',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_nfcTagData != null) ...[
              // NFC Tag info
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.nfc,
                            size: 80,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NFC Tag',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.checkpoint.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NFC Tag Data',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _nfcTagData!,
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _copyToClipboard(_nfcTagData!),
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy to clipboard',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // NFC actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _writeNfcTag,
                                icon: const Icon(Icons.nfc),
                                label: const Text('Write Tag'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _testNfcTag,
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Test'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Generate NFC Tag
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.nfc,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No NFC Tag Generated',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate a unique NFC tag identifier for this checkpoint to enable NFC scanning.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isGeneratingNfc ? null : _generateNfcTag,
                      icon: _isGeneratingNfc 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.nfc),
                      label: Text(_isGeneratingNfc ? 'Generating...' : 'Generate NFC Tag'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Usage Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              '• QR Code: Print and place at the checkpoint location for guards to scan with the mobile app',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• NFC Tag: Write the NFC data to a physical NFC tag and attach it to the checkpoint',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Both methods will automatically record checkpoint visits and validate patrol routes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Make sure tags are placed in weatherproof locations and are easily accessible to guards',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateQrCode() async {
    setState(() {
      _isGeneratingQr = true;
    });

    try {
      // Generate QR code data
      final qrData = 'checkpoint:${widget.checkpoint.id}:${DateTime.now().millisecondsSinceEpoch}';
      
      // In a real implementation, this would call the backend API
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _qrCodeData = qrData;
        _isGeneratingQr = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingQr = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating QR Code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateNfcTag() async {
    setState(() {
      _isGeneratingNfc = true;
    });

    try {
      // Generate NFC tag data
      final nfcData = 'nfc:checkpoint:${widget.checkpoint.id}:${DateTime.now().millisecondsSinceEpoch}';
      
      // In a real implementation, this would call the backend API
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _nfcTagData = nfcData;
        _isGeneratingNfc = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NFC Tag data generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingNfc = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating NFC Tag: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _downloadQrCode() {
    // TODO: Implement QR code download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code download functionality coming soon')),
    );
  }

  void _printQrCode() {
    // TODO: Implement QR code printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code printing functionality coming soon')),
    );
  }

  void _shareQrCode() {
    // TODO: Implement QR code sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code sharing functionality coming soon')),
    );
  }

  void _writeNfcTag() {
    // TODO: Implement NFC tag writing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NFC tag writing functionality coming soon')),
    );
  }

  void _testNfcTag() {
    // TODO: Implement NFC tag testing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NFC tag testing functionality coming soon')),
    );
  }
}
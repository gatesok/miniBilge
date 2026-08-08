import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../models/certificate_data.dart';
import 'achievement_certificate.dart';

Future<void> showCertificatePreview(
  BuildContext context,
  CertificateData certificate,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CertificatePreviewDialog(certificate: certificate),
  );
}

class _CertificatePreviewDialog extends StatefulWidget {
  final CertificateData certificate;

  const _CertificatePreviewDialog({required this.certificate});

  @override
  State<_CertificatePreviewDialog> createState() =>
      _CertificatePreviewDialogState();
}

class _CertificatePreviewDialogState extends State<_CertificatePreviewDialog> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share(BuildContext buttonContext) async {
    if (_isSharing) return;
    final buttonBox = buttonContext.findRenderObject() as RenderBox?;
    final origin = buttonBox == null
        ? null
        : buttonBox.localToGlobal(Offset.zero) & buttonBox.size;
    setState(() => _isSharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _certificateKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Sertifika hazırlanamadı.');

      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('Sertifika görseli oluşturulamadı.');

      final safeTopic = widget.certificate.topicName.replaceAll(
        RegExp(r'[^a-zA-Z0-9ğüşöçıİĞÜŞÖÇ]+'),
        '_',
      );
      final file = File(
        '${Directory.systemTemp.path}/minibilge_sertifika_$safeTopic.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            '${widget.certificate.studentName}, ${widget.certificate.subjectName} • '
            '${widget.certificate.topicName} quizini '
            '${widget.certificate.correctCount}/${widget.certificate.totalQuestions} '
            'sonuçla tamamladı.',
        subject: 'MiniBilge Başarı Sertifikası',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertifika paylaşılamadı. Lütfen tekrar dene.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _certificateKey,
                  child: AchievementCertificate(data: widget.certificate),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSharing ? null : () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) => FilledButton.icon(
                      onPressed: _isSharing
                          ? null
                          : () => _share(buttonContext),
                      icon: _isSharing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded),
                      label: Text(_isSharing ? 'Hazırlanıyor...' : 'Paylaş'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

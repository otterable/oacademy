// lib/screens/presentation_view_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PresentationViewScreen extends StatelessWidget {
  final String fileUrl; // e.g. http://localhost:5656/uploads/myFile.pptx
  final String fileName; // e.g. myFile.pptx

  const PresentationViewScreen({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    // We detect if file is pdf or pptx
    final ext = fileName.split('.').last.toLowerCase();

    Widget viewerWidget;

    if (ext == 'pdf') {
      // We can directly embed PDF in an <iframe> with 'pdf' plugin
      final embedUrl = 'https://docs.google.com/gview?embedded=true&url=$fileUrl';
      viewerWidget = _IframeWidget(embedUrl: embedUrl);
    } else if (ext == 'pptx') {
      // For pptx, also use docs.google.com/viewer
      final embedUrl = 'https://docs.google.com/gview?embedded=true&url=$fileUrl';
      viewerWidget = _IframeWidget(embedUrl: embedUrl);
    } else {
      // If unknown extension, just show a download link or open in new tab
      viewerWidget = Center(
        child: ElevatedButton(
          onPressed: () async {
            if (await canLaunch(fileUrl)) {
              await launch(fileUrl);
            }
          },
          child: Text('Open $fileName in new tab'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Viewing $fileName'),
        backgroundColor: const Color(0xFF003058),
      ),
      body: viewerWidget,
    );
  }
}

class _IframeWidget extends StatelessWidget {
  final String embedUrl;

  const _IframeWidget({required this.embedUrl});

  @override
  Widget build(BuildContext context) {
    // The embed url calls google docs viewer
    // Add a fallback or resizing
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(
          viewType: 'iframe-$embedUrl',
        ),
      ),
    );
  }
}

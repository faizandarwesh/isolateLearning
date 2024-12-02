import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';



class FileDownload extends StatefulWidget {
  const FileDownload({super.key});

  @override
  State<FileDownload> createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {

  String _result = "Click 'Start Download' to begin";

  final rootIsolateToken = RootIsolateToken.instance!;

  Future<void> _startDownloadTask() async {
    final receivePort = ReceivePort();

    // Start the isolate
    await Isolate.spawn(_downloadFile, receivePort.sendPort);

    // Listen for data from the isolate
    receivePort.listen((message) {
      setState(() {
        if (message == 'success') {
          _result = "Download Complete!";
        } else {
          _result = "Download Failed!";
        }
      });
    });
  }

  // Function to download a file in the isolate
  static Future<void> _downloadFile(SendPort sendPort) async {
    try {

      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      // File URL
     /* RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;*/

      // BackgroundIsolateBinaryMessenger.ensureInitialized();

      //final url = 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-text-file.txt';
      const url = 'https://www.learningcontainer.com/wp-content/uploads/2020/04/sample-text-file.txt';

      // Fetch the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the path to store the downloaded file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/downloaded_file.txt';

        // Save the file to the device
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Send success message to the main isolate
        sendPort.send('success');
      } else {
        // Send failure message if the download fails
        sendPort.send('failure');
      }
    } catch (e) {
      // Handle any exceptions
      sendPort.send('failure');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Isolate File Download"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startDownloadTask,
              child: const Text('Start Download'),
            ),
          ],
        ),
      ),
    );
  }
}

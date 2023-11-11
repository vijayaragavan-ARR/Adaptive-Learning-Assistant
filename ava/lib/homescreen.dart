import 'dart:io';
import 'package:ava/message.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  File? _pickedFile;
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);

      // Save the picked file locally
      String localPath = (await getApplicationDocumentsDirectory()).path;
      String fileName = result.files.single.name;
      File localFile = File('$localPath/$fileName');
      await localFile.writeAsBytes(await pickedFile.readAsBytes());

      readPdf(localFile);

      setState(() {
        _pickedFile = localFile;
      });
      print('uploaded');
    }
  }

  void readPdf(File file) async {
    final PdfDocument document =
        PdfDocument(inputBytes: file.readAsBytesSync());
    String pdfText = PdfTextExtractor(document).extractText();
    List<String> lines = pdfText.split(' ');

    // Remove empty lines
    lines.removeWhere((line) => line.trim().isEmpty);

    // Join the lines back into a single string
    pdfText = lines.join(' ');
    print('Modified Text: $pdfText');
    addMessage([pdfText], false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              // tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: const Text('AVA'),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color.fromARGB(255, 91, 91, 92),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _pickFile(),
                  icon: const Icon(Icons.add,
                      color: Colors.white), // Attachment icon
                ),
                Expanded(
                    child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                )),
                IconButton(
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      // print('Message is empty');
    } else {
      setState(() {
        addMessage([text], true);
      });
    }
  }

  void addMessage(List<String> list, [bool? isUserMessage]) {
    if (isUserMessage == false) {
      String combinedText = list.join(' ');
      list.clear();
      list.add(combinedText);
    }
    messages.add({'message': list, 'isUserMessage': isUserMessage});
  }
}

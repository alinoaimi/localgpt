import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeIconButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeMaterial.dart';
import 'package:localgptflutter/data/settings.dart';
import 'package:localgptflutter/networking/CustomDio.dart';
import 'package:localgptflutter/widgets/ParentDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter_download_manager/flutter_download_manager.dart';


class DownloadPopup extends StatefulWidget {
  VoidCallback? onDownloadComplete;
  VoidCallback? onDownloadFailed;
  String url;
  String destination;


  DownloadPopup({Key? key, this.onDownloadComplete, this.onDownloadFailed ,required this.url, required this.destination}) : super(key: key);

  @override
  State<DownloadPopup> createState() => _DownloadPopupState();
}

class _DownloadPopupState extends State<DownloadPopup> {
  List<DropdownMenuItem> modelChildren = [];
  ModelObject? _selectedModel;

  String fileName = '';
  double? downloadProgress;

  DownloadManager? downloadManager;
  DownloadTask? downloadTask;
  double? progressValue;
  DownloadStatus _downloadStatus = DownloadStatus.queued;

  pauseDownload() async {

    downloadManager?.pauseDownload(widget.url);

  }
  resumeDownload() async {

    downloadManager?.resumeDownload(widget.url);

  }

  cancelDownload() async {

    await downloadManager?.cancelDownload(widget.url);

    if(widget.onDownloadFailed != null) {
      widget.onDownloadFailed!();
    }
    Navigator.of(context).pop();


  }

  download() async {
    try {
      downloadManager = DownloadManager();
      await downloadManager?.addDownload(widget.url, widget.destination);

      downloadTask = downloadManager?.getDownload(widget.url);

      downloadTask?.status.addListener(() {
        debugPrint('status value');
        print(downloadTask?.status.value);
        _downloadStatus = downloadTask!.status.value!;
        setState(() {
          
        });
      });

      downloadTask?.progress.addListener(() {

        debugPrint('progress value');
        print(downloadTask?.progress.value);
        progressValue = downloadTask?.progress.value;

        setState(() {

        });
      });
      _downloadStatus = downloadTask!.status.value!;


      await downloadManager?.whenDownloadComplete(widget.url);
      debugPrint('download complete :D');
    } catch(ex) {
      debugPrint('error at download()');
      debugPrint(ex.toString());
    }
  }


  @override
  void initState() {
    super.initState();

    fileName = widget.destination.split(Platform.pathSeparator).last; // my_image.jpg

    download();

  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    List<Widget> children = [];

    children.add(Text('downloading: $fileName'));
    children.add(const SizedBox(height: 10,));
    children.add(Text('from: ${widget.url}'));

    children.add(const SizedBox(height: 10,));


    LinearProgressIndicator linearProgressIndicator = LinearProgressIndicator(
      // value: downloadProgress == null ? null : (downloadProgress!/100.0),
      value: progressValue,
    );

    children.add(linearProgressIndicator);
    
    children.add(const SizedBox(height: 10));
    
    // pause / cancel buttons
    List<Widget> controlsRowChildren = [];

    if(_downloadStatus == DownloadStatus.downloading) {
      controlsRowChildren.add(NativeIconButton(icon: Icon(Icons.pause), onPressed: () { pauseDownload(); },));
      controlsRowChildren.add(NativeIconButton(icon: Icon(Icons.cancel), onPressed: () { cancelDownload(); },));
    }
    if(_downloadStatus == DownloadStatus.paused) {
      controlsRowChildren.add(NativeIconButton(icon: Icon(Icons.play_arrow), onPressed: () { resumeDownload(); },));
      controlsRowChildren.add(NativeIconButton(icon: Icon(Icons.cancel), onPressed: () { cancelDownload(); },));
    }

    if(_downloadStatus == DownloadStatus.completed) {
      children.add(const SizedBox(height: 10,));
      children.add(const Icon(Icons.check, color: Colors.green,));
      children.add(const SizedBox(height: 10,));
      children.add(const Text('Download Complete'));
      children.add(const SizedBox(height: 10,));
      children.add(NativeButton(child: Text('Start Conversation'), onPressed: () {
        if(widget.onDownloadComplete != null) {
          widget.onDownloadComplete!();
          Navigator.pop(context);
        }
      },));
    }
    
    
    children.add(Row(
      children: controlsRowChildren,
    ));

    body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    return ParentDialog(title: 'Download', child: body);
  }
}

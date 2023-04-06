import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeMaterial.dart';
import 'package:localgptflutter/data/settings.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}



class _SetupScreenState extends State<SetupScreen> {
  final List<ModelObject> _models = [
    ModelObject(key: 'gpt4all-lora-quantized', label: 'gpt4all-lora-quantized', size: '4.21 GB', downloadUrl: 'https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-quantized.bin', localPath: 'models/gpt4all/gpt4all-lora-quantized.bin'),
    ModelObject(key: 'gpt4all-lora-unfiltered-quantized', label: 'gpt4all-lora-unfiltered-quantized', size: '4.21 GB', downloadUrl: 'https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-unfiltered-quantized.bin', localPath: 'models/gpt4all/gpt4all-lora-unfiltered-quantized.bin'),
  ];
  List<ModelObject> _selectedModels = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(Text(
      'LocalGPT',
      style: TextStyle(fontSize: 30),
    ));
    children.add(SizedBox(
      height: 10,
    ));
    children.add(Text(
      'your own, offline & private AI',
      style: TextStyle(fontSize: 15),
    ));

    children.add(const SizedBox(
      height: 20,
    ));

    children.add(const Text('Engine'));
    children.add(const SizedBox(
      height: 5,
    ));
    children.add(NativeMaterial(
      child: DropdownButton(
          hint: Text('Engine'),
          items: [DropdownMenuItem(child: Text('gpt4all'))],
          onChanged: (newVal) {}),
    ));

    children.add(const SizedBox(
      height: 20,
    ));

    children.add(const Text('Models'));
    children.add(const SizedBox(
      height: 5,
    ));



    var body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );

    return body;
  }
}

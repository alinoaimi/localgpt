class ModelObject {
  final String key;
  final String label;
  final String size;
  final String downloadUrl;
  final String localPath;

  ModelObject({
    required this.key,
    required this.label,
    required this.size,
    required this.downloadUrl,
    required this.localPath
  });
}

class SettingsData {
  static String apiUrl = 'http://localhost:1092';
  static String apiSocketsUrl = 'http://localhost:1092';

  static String databasePath = '/Users/ghost/Documents/projects/offlinegpt/localgpt-api/database.db';
  static String backendExecPath = '/Users/ghost/Documents/projects/offlinegpt/localgpt-api/executables/api-macos';

  static int backendPort = 1092;

  static List<ModelObject> models = [
    ModelObject(key: 'gpt4all-lora-quantized', label: 'gpt4all-lora-quantized', size: '4.21 GB', downloadUrl: 'https://file-examples.com/wp-content/uploads/2017/10/file-sample_1MB.odt', localPath: 'models/gpt4all/gpt4all-lora-quantized.bin'),
    // ModelObject(key: 'gpt4all-lora-quantized', label: 'gpt4all-lora-quantized', size: '4.21 GB', downloadUrl: 'https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-quantized.bin', localPath: 'models/gpt4all/gpt4all-lora-quantized.bin'),
    ModelObject(key: 'gpt4all-lora-unfiltered-quantized', label: 'gpt4all-lora-unfiltered-quantized', size: '4.21 GB', downloadUrl: 'https://link.testfile.org/15MB', localPath: 'models/gpt4all/gpt4all-lora-unfiltered-quantized.bin'),
    // ModelObject(key: 'gpt4all-lora-unfiltered-quantized', label: 'gpt4all-lora-unfiltered-quantized', size: '4.21 GB', downloadUrl: 'https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-unfiltered-quantized.bin', localPath: 'models/gpt4all/gpt4all-lora-unfiltered-quantized.bin'),
  ];

}
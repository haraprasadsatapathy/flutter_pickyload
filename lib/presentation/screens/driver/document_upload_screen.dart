import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  String? _dlFrontPath;
  String? _dlBackPath;
  String? _rcFrontPath;
  String? _rcBackPath;
  String? _aadharFrontPath;
  String? _aadharBackPath;

  final _dlController = TextEditingController();
  final _rcController = TextEditingController();
  final _aadharController = TextEditingController();

  @override
  void dispose() {
    _dlController.dispose();
    _rcController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onImagePicked(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Documents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please upload the following documents for verification',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 30),
              _buildDocumentSection(
                'Driving License (DL)',
                _dlController,
                _dlFrontPath,
                _dlBackPath,
                (path) => setState(() => _dlFrontPath = path),
                (path) => setState(() => _dlBackPath = path),
              ),
              const SizedBox(height: 30),
              _buildDocumentSection(
                'Registration Certificate (RC)',
                _rcController,
                _rcFrontPath,
                _rcBackPath,
                (path) => setState(() => _rcFrontPath = path),
                (path) => setState(() => _rcBackPath = path),
              ),
              const SizedBox(height: 30),
              _buildDocumentSection(
                'Aadhar Card',
                _aadharController,
                _aadharFrontPath,
                _aadharBackPath,
                (path) => setState(() => _aadharFrontPath = path),
                (path) => setState(() => _aadharBackPath = path),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/driver-dashboard');
                  },
                  // onPressed: _canSubmit()
                  //     ? () {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text('Documents submitted for verification'),
                  //     ),
                  //   );
                  //   context.go('/driver-dashboard');
                  // }
                  //     : null,
                  child: const Text('Submit for Verification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection(
    String title,
    TextEditingController controller,
    String? frontPath,
    String? backPath,
    Function(String) onFrontPicked,
    Function(String) onBackPicked,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Document Number',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImageUploadButton(
                    'Front Side',
                    frontPath,
                    () => _pickImage(onFrontPicked),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageUploadButton(
                    'Back Side',
                    backPath,
                    () => _pickImage(onBackPicked),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadButton(
    String label,
    String? imagePath,
    VoidCallback onTap,
  ) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: imagePath != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            imagePath != null ? Icons.check_circle : Icons.camera_alt_outlined,
            color: imagePath != null
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: imagePath != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

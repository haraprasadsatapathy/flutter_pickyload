import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../domain/repository/driver_repository.dart';
import '../../cubit/driver/upload_documents/upload_documents_bloc.dart';
import '../../cubit/driver/upload_documents/upload_documents_event.dart';
import '../../cubit/driver/upload_documents/upload_documents_state.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _documentNumberController = TextEditingController();

  DateTime? _selectedDateOfBirth;

  // Document type options
  String? _selectedDocumentType;
  final List<String> _documentTypes = [
    'Driving License (DL)',
    'Registration Certificate (RC)'
  ];

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    // Check if document type is selected
    if (_selectedDocumentType == null) {
      return false;
    }

    // Check if document number is provided
    if (_documentNumberController.text.trim().isEmpty) {
      return false;
    }

    // Check if date of birth is selected
    if (_selectedDateOfBirth == null) {
      return false;
    }

    return true;
  }

  void _submitDocument(BuildContext context) {
    // Dispatch the event to submit the document
    context.read<UploadDocumentsBloc>().add(
          SubmitSingleDocument(
            documentType: _selectedDocumentType!,
            documentNumber: _documentNumberController.text.trim(),
            dateOfBirth: _selectedDateOfBirth,
          ),
        );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverRepository = Provider.of<DriverRepository>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => UploadDocumentsBloc(
        context: context,
        driverRepository: driverRepository,
      ),
      child: BlocConsumer<UploadDocumentsBloc, UploadDocumentsState>(
        listener: (context, state) {
          if (state is DocumentsSubmittedSuccess) {
            // Show toast message
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            // Redirect to driver dashboard immediately
            if (context.mounted) {
              context.go('/driver-dashboard');
            }
          } else if (state is DocumentsSubmissionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UploadDocumentsLoading;

          return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Document Upload',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload Your Document',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide your document type and number to verify your identity.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Document Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isDark
                            ? Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Document Type',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      ' *',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.outline.withValues(alpha: 0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDocumentType,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select document type *',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  dropdownColor: colorScheme.surface,
                                  items: _documentTypes.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedDocumentType = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Document Number Field
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isDark
                            ? Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.badge_outlined,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Document Number',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      ' *',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _documentNumberController,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                              onChanged: (value) {
                                // Trigger rebuild to update submit button state
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter document number *',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withValues(alpha: 0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date of Birth Field
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isDark
                            ? Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.cake_outlined,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Date of Birth',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      ' *',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDateOfBirth(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDateOfBirth == null
                                          ? 'Select date of birth *'
                                          : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _selectedDateOfBirth == null
                                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isLoading || !_canSubmit()) ? null : () => _submitDocument(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Submit Document',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Skip Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.go('/driver-dashboard');
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Skip for Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
        );
        },
      ),
    );
  }

}

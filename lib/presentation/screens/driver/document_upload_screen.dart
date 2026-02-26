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

  // Document type options - 0 for DL, 1 for RC
  int _selectedDocumentIndex = 0;

  // Track if DL is already uploaded
  bool _hasDrivingLicense = false;

  String get _selectedDocumentType => _selectedDocumentIndex == 0
      ? 'Driving License (DL)'
      : 'Registration Certificate (RC)';

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    // Check if document number is provided
    if (_documentNumberController.text.trim().isEmpty) {
      return false;
    }

    // Check if date of birth is selected (only required for DL, not RC)
    final isRC = _selectedDocumentIndex == 1;
    if (!isRC && _selectedDateOfBirth == null) {
      return false;
    }

    return true;
  }

  void _submitDocument(BuildContext context) {
    // Dispatch the event to submit the document
    context.read<UploadDocumentsBloc>().add(
          SubmitSingleDocument(
            documentType: _selectedDocumentType,
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
    final driverRepository =
        Provider.of<DriverRepository>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => UploadDocumentsBloc(
        context: context,
        driverRepository: driverRepository,
      )..add(FetchExistingDocuments()),
      child: BlocConsumer<UploadDocumentsBloc, UploadDocumentsState>(
        listener: (context, state) {
          if (state is DocumentsFetched) {
            setState(() {
              _hasDrivingLicense = state.hasDrivingLicense;
              // If DL is already uploaded, default to RC
              if (_hasDrivingLicense && _selectedDocumentIndex == 0) {
                _selectedDocumentIndex = 1;
              }
            });
          } else if (state is DocumentsSubmittedSuccess) {
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
                backgroundColor: Colors.grey.shade600,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UploadDocumentsLoading;
          final isLoadingDocuments = state.isLoadingDocuments;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go('/driver-dashboard'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Header
                      Text(
                        'Verify Your\nDocument',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your document details for verification',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Document Type Selection Cards
                      Text(
                        'Select Document Type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // DL Card - Only show if DL is not already uploaded
                          if (!_hasDrivingLicense)
                            Expanded(
                              child: _buildDocumentTypeCard(
                                context: context,
                                index: 0,
                                icon: Icons.badge_outlined,
                                title: 'DL',
                                subtitle: 'Driving License',
                                isSelected: _selectedDocumentIndex == 0,
                                colorScheme: colorScheme,
                                isDark: isDark,
                              ),
                            ),
                          if (!_hasDrivingLicense) const SizedBox(width: 12),
                          // RC Card
                          Expanded(
                            child: _buildDocumentTypeCard(
                              context: context,
                              index: 1,
                              icon: Icons.directions_car_outlined,
                              title: 'RC',
                              subtitle: 'Registration Certificate',
                              isSelected: _selectedDocumentIndex == 1,
                              colorScheme: colorScheme,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : colorScheme.primary.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Document Number Field
                            _buildInputLabel(
                              context,
                              _selectedDocumentIndex == 0
                                  ? 'DL Number'
                                  : 'RC Number',
                              true,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _documentNumberController,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                                letterSpacing: 1,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: _selectedDocumentIndex == 0
                                    ? 'e.g., KA01 20190001234'
                                    : 'e.g., KA01AB1234',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.35),
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0.5,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.numbers,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5)
                                    : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),

                            // Date of Birth Field (only for DL)
                            if (_selectedDocumentIndex == 0) ...[
                              const SizedBox(height: 20),
                              _buildInputLabel(context, 'Date of Birth', true),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDateOfBirth(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.5)
                                        : colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDateOfBirth == null
                                              ? 'Select your date of birth'
                                              : _formatDate(
                                                  _selectedDateOfBirth!),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                _selectedDateOfBirth == null
                                                    ? FontWeight.normal
                                                    : FontWeight.w500,
                                            color: _selectedDateOfBirth == null
                                                ? colorScheme.onSurface
                                                    .withValues(alpha: 0.35)
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDocumentIndex == 0
                                    ? 'Your DL will be verified instantly via government database'
                                    : 'Your RC will be verified instantly via government database',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: (isLoading || !_canSubmit())
                              ? null
                              : () => _submitDocument(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                colorScheme.primary.withValues(alpha: 0.4),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            elevation: 0,
                            shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Verify Document',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentTypeCard({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDocumentIndex = index;
          if (index == 1) {
            _selectedDateOfBirth = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Selection indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String label, bool isRequired) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.error,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

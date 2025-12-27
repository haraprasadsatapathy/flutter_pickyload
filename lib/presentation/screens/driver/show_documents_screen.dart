import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/repository/driver_repository.dart';
import '../../../domain/repository/user_repository.dart';
import '../../../domain/models/document_list_response.dart';
import '../../cubit/driver/document_list/document_list_bloc.dart';
import '../../cubit/driver/document_list/document_list_event.dart';
import '../../cubit/driver/document_list/document_list_state.dart';

class ShowDocumentsScreen extends StatelessWidget {
  const ShowDocumentsScreen({super.key});

  Future<void> _initializeAndFetchDocuments(
    BuildContext context,
    DocumentListBloc bloc,
  ) async {
    // Get user ID
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    final user = await userRepository.getUserDetailsSp();

    final userId = user?.id;
    if (userId != null && context.mounted) {
      bloc.add(FetchDocuments(userId: userId));
    }
  }

  Future<void> _refreshDocuments(BuildContext context) async {
    // Get user ID
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    final user = await userRepository.getUserDetailsSp();

    final userId = user?.id;
    if (userId != null && context.mounted) {
      context.read<DocumentListBloc>().add(RefreshDocuments(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverRepository = Provider.of<DriverRepository>(context, listen: false);

    return BlocProvider(
      create: (context) {
        final bloc = DocumentListBloc(
          context: context,
          driverRepository: driverRepository,
        );
        // Fetch documents on initialization
        _initializeAndFetchDocuments(context, bloc);
        return bloc;
      },
      child: BlocConsumer<DocumentListBloc, DocumentListState>(
        listener: (context, state) {
          // Show error snackbar if error occurs
          if (state is DocumentListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Documents'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refreshDocuments(context),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DocumentListState state) {
    // Show loading for initial load
    if (state is DocumentListLoading && state.documents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading documents...'),
          ],
        ),
      );
    }

    // Show error state only if no documents are available
    if (state is DocumentListError && state.documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _refreshDocuments(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (state.documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Documents Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t uploaded any documents yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Documents'),
              ),
            ],
          ),
        ),
      );
    }

    // Show documents list
    return RefreshIndicator(
      onRefresh: () => _refreshDocuments(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.documents.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderCard(context, state);
          }
          return _buildDocumentCard(context, state.documents[index - 1]);
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, DocumentListState state) {
    final documents = state.documents;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Documents',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${documents.length} document${documents.length != 1 ? "s" : ""} uploaded',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (documents.any((doc) => doc.isExpired || doc.isExpiringSoon)) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              if (documents.any((doc) => doc.isExpired))
                _buildWarningRow(
                  Icons.error,
                  'Expired: ${documents.where((doc) => doc.isExpired).length}',
                  Colors.red,
                ),
              if (documents.any((doc) => doc.isExpiringSoon))
                _buildWarningRow(
                  Icons.warning,
                  'Expiring Soon: ${documents.where((doc) => doc.isExpiringSoon).length}',
                  Colors.orange,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarningRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentInfo document) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Type Header
            Row(
              children: [
                Text(
                  document.documentIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.documentTypeName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        document.documentNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement deactivate functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deactivate functionality coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Deactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // Document Details
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Valid Until',
              document.validTill != null
                  ? dateFormat.format(document.validTill!)
                  : 'Not specified',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.verified,
              'Verified On',
              document.verifiedOn != null
                  ? dateFormat.format(document.verifiedOn!)
                  : 'Not verified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

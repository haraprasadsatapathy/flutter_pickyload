// Method 1: Using intl package with error handling (recommended)
import 'package:intl/intl.dart';

 String convertDateFormatSafe(DateTime dateString) {
  try {
    // Null check
    if (dateString == null || dateString.toString().isEmpty) {
      return 'Invalid date';
    }

    // Parse the input string
    // DateTime dateTime = DateTime.parse(dateString);

    // Format to "yyyy-MM-dd"
    return DateFormat('yyyy-MM-dd').format(dateString);
  } on FormatException catch (e) {
    print('FormatException: Invalid date format - $e');
    return 'Invalid date format';
  } catch (e) {
    print('Error: $e');
    return 'Error converting date';
  }
}
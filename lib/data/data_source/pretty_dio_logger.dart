import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom Dio interceptor for pretty printing JSON requests and responses
class PrettyDioLoggerInterceptor extends Interceptor {
  void _log(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'API');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('\n');
    _log(
      '╔══════════════════════════════════════════════════════════════════════',
    );
    _log('║ REQUEST');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );
    _log('║ ${options.method} ${options.uri}');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );

    // Print headers
    if (options.headers.isNotEmpty) {
      _log('║ HEADERS:');
      options.headers.forEach((key, value) {
        _log('║   $key: $value');
      });
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    // Print query parameters
    if (options.queryParameters.isNotEmpty) {
      _log('║ QUERY PARAMETERS:');
      options.queryParameters.forEach((key, value) {
        _log('║   $key: $value');
      });
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    // Print request body as pretty JSON
    if (options.data != null) {
      _log('║ REQUEST BODY:');
      try {
        final prettyJson = _getPrettyJson(options.data);
        _log(prettyJson);
        // prettyJson.split('\n').forEach((line) {
        //   _log('║ $line');
        // });
      } catch (e) {
        _log('║ ${options.data}');
      }
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    _log(
      '╚══════════════════════════════════════════════════════════════════════',
    );
    _log('\n');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('\n');
    _log(
      '╔══════════════════════════════════════════════════════════════════════',
    );
    _log('║ RESPONSE');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );
    _log('║ ${response.requestOptions.method} ${response.requestOptions.uri}');
    _log('║ Status Code: ${response.statusCode}');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );

    // Print response headers
    if (response.headers.map.isNotEmpty) {
      _log('║ RESPONSE HEADERS:');
      response.headers.map.forEach((key, value) {
        _log('║   $key: ${value.join(', ')}');
      });
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    // Print response data as pretty JSON
    if (response.data != null) {
      _log('║ RESPONSE BODY:');
      try {
        final prettyJson = _getPrettyJson(response.data);
        prettyJson.split('\n').forEach((line) {
          _log('║ $line');
        });
      } catch (e) {
        _log('║ ${response.data}');
      }
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    _log(
      '╚══════════════════════════════════════════════════════════════════════',
    );
    _log('\n');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('\n');
    _log(
      '╔══════════════════════════════════════════════════════════════════════',
    );
    _log('║ ERROR');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );
    _log('║ ${err.requestOptions.method} ${err.requestOptions.uri}');
    _log('║ Error Type: ${err.type}');
    _log('║ Error Message: ${err.message}');
    _log(
      '╠══════════════════════════════════════════════════════════════════════',
    );

    // Print error response data as pretty JSON
    if (err.response?.data != null) {
      _log('║ ERROR RESPONSE BODY:');
      try {
        final prettyJson = _getPrettyJson(err.response!.data);
        prettyJson.split('\n').forEach((line) {
          _log('║ $line');
        });
      } catch (e) {
        _log('║ ${err.response!.data}');
      }
      _log(
        '╠══════════════════════════════════════════════════════════════════════',
      );
    }

    _log(
      '╚══════════════════════════════════════════════════════════════════════',
    );
    _log('\n');

    super.onError(err, handler);
  }

  /// Convert data to pretty printed JSON string
  String _getPrettyJson(dynamic data) {
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (e) {
        return data;
      }
    } else {
      return const JsonEncoder.withIndent('  ').convert(data);
    }
  }
}

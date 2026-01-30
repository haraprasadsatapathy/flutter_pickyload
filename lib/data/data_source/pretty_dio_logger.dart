import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom Dio interceptor that logs requests and responses.
///
/// Uses [developer.log] so output appears cleanly in the IDE's
/// Debug Console (VS Code / Android Studio) without the "I/flutter" prefix.
/// You can copy the pretty-printed JSON directly from there.
class PrettyDioLoggerInterceptor extends Interceptor {
  static const _tag = 'API';
  static const _encoder = JsonEncoder.withIndent('  ');

  void _log(String message) {
    if (kDebugMode) {
      developer.log(message, name: _tag);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('')
      ..writeln('========== REQUEST ==========')
      ..writeln('${options.method} ${options.uri}');

    if (options.headers.isNotEmpty) {
      buf.writeln('HEADERS:');
      options.headers.forEach((key, value) {
        buf.writeln('  $key: $value');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      buf.writeln('QUERY PARAMETERS:');
      buf.writeln(_toPrettyJson(options.queryParameters));
    }

    if (options.data != null) {
      buf.writeln('BODY:');
      buf.writeln(_toPrettyJson(options.data));
    }

    buf.writeln('=============================');
    _log(buf.toString());

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('')
      ..writeln('========== RESPONSE [${response.statusCode}] ==========')
      ..writeln('${response.requestOptions.method} ${response.requestOptions.uri}');

    if (response.data != null) {
      buf.writeln('BODY:');
      buf.writeln(_toPrettyJson(response.data));
    }

    buf.writeln('==========================================');
    _log(buf.toString());

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('')
      ..writeln('========== ERROR ==========')
      ..writeln('${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln('Type    : ${err.type}')
      ..writeln('Message : ${err.message}');

    if (err.response?.data != null) {
      buf.writeln('BODY:');
      buf.writeln(_toPrettyJson(err.response!.data));
    }

    buf.writeln('===========================');
    _log(buf.toString());

    super.onError(err, handler);
  }

  String _toPrettyJson(dynamic data) {
    try {
      if (data is String) {
        return _encoder.convert(jsonDecode(data));
      }
      return _encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

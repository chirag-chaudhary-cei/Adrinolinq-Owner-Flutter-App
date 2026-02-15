/// API Configuration for this project.
/// 
/// This file is generated based on your backend settings.
/// Modify these values to match your API's response structure.
library;

/// Where to extract the authentication token from
enum TokenSource {
  /// Token is in the response body (e.g., { "data": { "accessToken": "..." } })
  body,
  
  /// Token is in a response header (e.g., header 'token: xyz123')
  header,
}

/// Configuration for API communication
class ApiConfig {
  const ApiConfig({
    this.successKey = 'response_code',
    this.successValue = '200',
    this.dataKey = 'obj',
    this.nestedDataPath,
    this.errorMessagePath = 'obj',
    this.errorCodePath = 'response_code',
    this.tokenSource = TokenSource.header,
    this.accessTokenPath = 'token',
    this.refreshTokenPath,
    this.authHeaderName = 'token',
    this.authHeaderPrefix = '',
  });

  // ===== Response Parsing =====
  final String successKey;
  final dynamic successValue;
  final String dataKey;
  final String? nestedDataPath;

  // ===== Error Handling =====
  final String errorMessagePath;
  final String errorCodePath;

  // ===== Token Extraction =====
  final TokenSource tokenSource;
  final String accessTokenPath;
  final String? refreshTokenPath;

  // ===== Token Sending =====
  final String authHeaderName;
  final String authHeaderPrefix;

  /// Extract value from a nested path like 'data.user.token'
  dynamic extractPath(Map<String, dynamic> json, String path) {
    if (path.isEmpty) return json;
    
    final keys = path.split('.');
    dynamic current = json;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  /// Check if response indicates success
  bool isSuccess(Map<String, dynamic> response) {
    if (successKey.isEmpty) return true; // No success key = always success
    final value = extractPath(response, successKey);
    return value == successValue;
  }

  /// Extract the data payload from response
  dynamic getData(Map<String, dynamic> response) {
    final path = nestedDataPath ?? dataKey;
    if (path.isEmpty) return response;
    return extractPath(response, path);
  }

  /// Extract error message from response
  String? getErrorMessage(Map<String, dynamic> response) {
    return extractPath(response, errorMessagePath)?.toString();
  }

  /// Extract error code from response
  String? getErrorCode(Map<String, dynamic> response) {
    return extractPath(response, errorCodePath)?.toString();
  }
}

/// Default configuration instance
const apiConfig = ApiConfig();


import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;

Future<void> naverLogin() async {
  // App specific variables
  String naverClientId = '네이버 개발자 애플리케이션 등록 후 클라이언트id 들고오기';
  String callbackUrlScheme = 'com.example.dragong';

// Construct the url
  final url = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
    'response_type': 'code',
    'client_id': naverClientId,
    'redirect_uri': '$callbackUrlScheme:/',
    'scope': 'email',
  });

// Present the dialog to the user
  final result = await FlutterWebAuth2.authenticate(
      url: url.toString(), callbackUrlScheme: callbackUrlScheme);

// Extract code from resulting url
  final code = Uri.parse(result).queryParameters['code'];

// Construct an Uri to Google's oauth2 endpoint
  final url2 = Uri.https('nid.naver.com', '/oauth2.0/token');

// Use this code to get an access token
  final response = await http.post(url2, body: {
    'client_id': naverClientId,
    'redirect_uri': '$callbackUrlScheme:/',
    'grant_type': 'authorization_code',
    'code': code,
  });

// Get the access token from the response
  final accessToken = jsonDecode(response.body)['access_token'] as String;
  print(accessToken);
}

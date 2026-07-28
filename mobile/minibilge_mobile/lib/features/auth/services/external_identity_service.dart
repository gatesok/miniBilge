import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ExternalSignInCancelledException implements Exception {
  const ExternalSignInCancelledException();
}

class AppleSignInCredential {
  const AppleSignInCredential({
    required this.identityToken,
    required this.authorizationCode,
    required this.rawNonce,
    this.firstName,
    this.lastName,
  });

  final String identityToken;
  final String authorizationCode;
  final String rawNonce;
  final String? firstName;
  final String? lastName;
}

class ExternalIdentityService {
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInitialization;

  Future<String> getGoogleIdToken() async {
    await _initializeGoogle();

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google kimlik bilgisi alınamadı');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const ExternalSignInCancelledException();
      }
      rethrow;
    }
  }

  Future<AppleSignInCredential> getAppleCredential() async {
    final rawNonce = generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw StateError('Apple kimlik bilgisi alınamadı');
      }

      return AppleSignInCredential(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        rawNonce: rawNonce,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const ExternalSignInCancelledException();
      }
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    await _initializeGoogle();
    await _googleSignIn.signOut();
  }

  Future<void> _initializeGoogle() {
    return _googleInitialization ??= _googleSignIn.initialize(
      clientId: _googleIosClientId.isEmpty ? null : _googleIosClientId,
      serverClientId: _googleServerClientId.isEmpty
          ? null
          : _googleServerClientId,
    );
  }
}

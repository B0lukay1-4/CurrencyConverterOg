import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:currency_converter/user_authentication/helper/helper_function.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onSuccess;

  const SocialLoginButtons({super.key, required this.onSuccess});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
        scopes: ['email', 'profile'],
      );

      // await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        displayMessageToUser('Google Sign-In cancelled', context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (context.mounted) onSuccess();
    } catch (e) {
      if (context.mounted) {
        displayMessageToUser('Google Sign-In failed: $e', context);
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      // Ensure Facebook SDK is initialized (optional, handled by flutter_facebook_auth)
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile'
        ], // Request necessary permissions
      );

      // Debug the login result
      print('Facebook Login Status: ${loginResult.status}');
      print('Facebook Access Token: ${loginResult.accessToken?.token}');

      if (loginResult.status != LoginStatus.success) {
        displayMessageToUser(
            'Facebook Sign-In failed: ${loginResult.message}', context);
        return;
      }

      final AccessToken? accessToken = loginResult.accessToken;
      if (accessToken == null) {
        displayMessageToUser('No access token received from Facebook', context);
        return;
      }

      // Create Firebase credential with the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.token);

      // Sign in to Firebase
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      print('Firebase sign-in with Facebook successful');

      if (context.mounted) onSuccess();
    } catch (e) {
      if (context.mounted) {
        displayMessageToUser('Facebook Sign-In failed: $e', context);
      }
      print('Facebook Sign-In Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Or sign in with', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
              onPressed: () => _signInWithGoogle(context),
            ),
            IconButton(
              icon: const Icon(Icons.facebook, size: 40, color: Colors.blue),
              onPressed: () => _signInWithFacebook(context),
            ),
          ],
        ),
      ],
    );
  }
}

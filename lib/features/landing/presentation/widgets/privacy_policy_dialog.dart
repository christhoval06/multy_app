import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/landing_theme.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});
  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  late final Future<String> _policy = rootBundle.loadString(
    'PRIVACY_POLICY.md',
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Multy Privacy Policy'),
    content: SizedBox(
      width: 680,
      child: FutureBuilder<String>(
        future: _policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Unable to load the policy. Please contact christhoval06@gmail.com.',
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return SingleChildScrollView(
            child: SelectableText(snapshot.data!, style: LandingTheme.body),
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}

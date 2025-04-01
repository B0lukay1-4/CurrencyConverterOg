import 'package:flutter/material.dart';

// Displays a customizable message to the user via an AlertDialog with optional auto-dismiss
void displayMessageToUser(
  String message,
  BuildContext context, {
  String title = 'Message', // Default title
  bool dismissible = true, // Whether the dialog can be dismissed
  VoidCallback? onConfirm, // Optional callback for confirm action
  Duration?
      autoDismissDuration, // Optional duration after which the dialog auto-dismisses
}) {
  showDialog(
    context: context,
    barrierDismissible:
        dismissible, // Allow dismissal by tapping outside if true
    builder: (dialogContext) => AlertDialog(
      title: Text(title), // Customizable title
      content: Text(message), // Message as the dialog content
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      actions: [
        // Dismiss button
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
          },
          child: const Text('OK'),
        ),
        // Optional confirm button
        if (onConfirm != null)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
              onConfirm(); // Execute the callback
            },
            child: const Text('Confirm'),
          ),
      ],
    ),
  ).then((_) {
    // Ensure any scheduled auto-dismiss is cancelled when the dialog is manually closed
  });

  // Auto-dismiss the dialog after the specified duration, if provided
  if (autoDismissDuration != null) {
    Future.delayed(autoDismissDuration, () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close the dialog if still open
      }
    });
  }
}

// import 'package:feedback/feedback.dart';
// import 'package:flutter/material.dart';

// import '../utility/mindblooming_color_scheme.dart';
// import '../utility/mindblooming_text_style.dart';
// import 'mindblooming_button.dart';

// class CustomFeedbackForm extends StatefulWidget {
//   const CustomFeedbackForm({
//     super.key,
//     required this.onSubmit,
//     required this.scrollController,
//   });

//   final OnSubmit onSubmit;
//   final ScrollController? scrollController;

//   @override
//   State<CustomFeedbackForm> createState() => _CustomFeedbackFormState();
// }

// class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
//   String? _message;
//   bool _isSubmitting = false;

//   Future<void> _submitFeedback() async {
//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       await widget.onSubmit(_message!);
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Assicurati che il resize avvenga automaticamente
//       resizeToAvoidBottomInset: true,
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Stack(
//           children: [
//             // Drag handle in alto, se presente
//             if (widget.scrollController != null)
//               const Align(
//                 alignment: Alignment.topCenter,
//                 child: FeedbackSheetDragHandle(),
//               ),

//             // Corpo del form (titolo + campo testo)
//             Align(
//               alignment: Alignment.topLeft,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 24), // spazio sotto il drag handle
//                   Text(
//                     'Cosa ci vuoi segnalare?',
//                     style: MindBloomingTextStyle.introductionText,
//                   ),
//                   const SizedBox(height: 16),
// TextFormField(
//   maxLines: null,
//   autofocus: true,
//   onChanged: (newFeedback) => _message = newFeedback,
//   cursorColor: colorScheme.primary,
//   decoration: InputDecoration(
//     focusedBorder: UnderlineInputBorder(
//       borderSide: BorderSide(color: colorScheme.primary),
//     ),
//   ),
// ),
//                 ],
//               ),
//             ),

//             // Pulsante fisso in basso
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: MindBloomingButton(
//                 onPressed:
//                     _message != null && !_isSubmitting ? _submitFeedback : null,
// child: _isSubmitting
//     ? const SizedBox(
//         width: 24,
//         height: 24,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           color: MindBloomingColorScheme.primary,
//         ),
//       )
//     : Text(
//         "INVIA",
//         style: MindBloomingTextStyle.button,
//       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';
import 'mindblooming_button.dart';

/// A simplified feedback form exposing only a multiline text input and submit button.
class CustomFeedbackForm extends StatefulWidget {
  const CustomFeedbackForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final OnSubmit onSubmit;

  @override
  State<CustomFeedbackForm> createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  String _feedbackText = '';
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      await widget.onSubmit(_feedbackText);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Multiline text field
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                labelText: 'Cosa ci vuoi segnalare?',
                labelStyle: TextStyle(color: colorScheme.primary),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              onChanged: (value) {
                setState(() => _feedbackText = value);
              },
            ),
          ),
        ),
        // Submit button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: MindBloomingButton(
            onPressed: !_feedbackText.isEmpty && !_isSubmitting
                ? _submitFeedback
                : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MindBloomingColorScheme.primary,
                    ),
                  )
                : Text(
                    "INVIA",
                    style: MindBloomingTextStyle.button,
                  ),
          ),
        ),
      ],
    );
  }
}

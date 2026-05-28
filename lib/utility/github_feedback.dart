import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:feedback/feedback.dart';

const String _githubApiBase = 'https://api.github.com';
const String _attachmentsBranch = 'feedback-attachments';

/// Uploads a [UserFeedback] (text + screenshot) to a GitHub repository as an issue.
///
/// 1. Pushes the screenshot PNG to [_attachmentsBranch] via the Contents API,
///    creating the branch from the repo's default branch on first use.
/// 2. Opens an issue with the user's text and an inline reference to the
///    screenshot's raw URL.
Future<void> uploadFeedbackToGitHub(
  UserFeedback feedback, {
  required String owner,
  required String repo,
  required String token,
}) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: _githubApiBase,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ),
  );

  String screenshotMarkdown = '';
  try {
    final downloadUrl = await _uploadScreenshot(
      dio,
      owner: owner,
      repo: repo,
      screenshot: feedback.screenshot,
    );
    screenshotMarkdown = '\n\n![screenshot]($downloadUrl)';
  } catch (e) {
    log('Screenshot upload failed: $e', name: 'github_feedback');
    screenshotMarkdown = '\n\n_(Screenshot upload failed)_';
  }

  await dio.post<dynamic>(
    '/repos/$owner/$repo/issues',
    data: {
      'title': _titleFromText(feedback.text),
      'body': '${feedback.text}$screenshotMarkdown',
      'labels': ['feedback'],
    },
  );
}

Future<String> _uploadScreenshot(
  Dio dio, {
  required String owner,
  required String repo,
  required List<int> screenshot,
}) async {
  await _ensureBranchExists(dio, owner: owner, repo: repo);

  final timestamp = DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final path = 'screenshots/feedback-$timestamp.png';

  final response = await dio.put<Map<String, dynamic>>(
    '/repos/$owner/$repo/contents/$path',
    data: {
      'message': 'Add feedback screenshot',
      'content': base64Encode(screenshot),
      'branch': _attachmentsBranch,
    },
  );

  final content = response.data?['content'] as Map<String, dynamic>?;
  final downloadUrl = content?['download_url'] as String?;
  if (downloadUrl == null) {
    throw StateError('Missing download_url in GitHub response');
  }

  return downloadUrl;
}

Future<void> _ensureBranchExists(
  Dio dio, {
  required String owner,
  required String repo,
}) async {
  try {
    await dio.get<dynamic>('/repos/$owner/$repo/branches/$_attachmentsBranch');

    return;
  } on DioException catch (e) {
    if (e.response?.statusCode != 404) rethrow;
  }

  final repoInfo = await dio.get<Map<String, dynamic>>('/repos/$owner/$repo');
  final defaultBranch = repoInfo.data?['default_branch'] as String?;
  if (defaultBranch == null) {
    throw StateError('Could not resolve default branch for $owner/$repo');
  }

  final headRef = await dio.get<Map<String, dynamic>>(
    '/repos/$owner/$repo/git/ref/heads/$defaultBranch',
  );
  final sha =
      (headRef.data?['object'] as Map<String, dynamic>?)?['sha'] as String?;
  if (sha == null) {
    throw StateError('Could not resolve head SHA of $defaultBranch');
  }

  await dio.post<dynamic>(
    '/repos/$owner/$repo/git/refs',
    data: {
      'ref': 'refs/heads/$_attachmentsBranch',
      'sha': sha,
    },
  );
}

String _titleFromText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 'User feedback';
  final firstLine = trimmed.split('\n').first;

  return firstLine.length <= 80 ? firstLine : '${firstLine.substring(0, 77)}...';
}

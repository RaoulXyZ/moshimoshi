import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';

import 'package:http/http.dart' as http;
import 'package:image_network/image_network.dart';
import 'package:printing/printing.dart';

import '../../utility/mindblooming_text_style.dart';
import '../custom_yt_adapter.dart';
import '../custom_audio_adapter.dart';

class QuestionText extends StatelessWidget {
  QuestionText({
    required this.questionText,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
  }) : super(key: Key(questionID));

  final String questionText;
  final String surveyID;
  final String blockID;
  final String questionID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
      child: Column(
        children: [
          _buildHtml(
            context,
            questionText,
            showPdfDownloadRow: false,
          ),
        ],
      ),
    );
  }
}

class CustomHtmlWidget extends StatelessWidget {
  const CustomHtmlWidget({
    super.key,
    required this.questionText,
  });

  final String questionText;

  @override
  Widget build(BuildContext context) {
    return _buildHtml(
      context,
      questionText,
      showPdfDownloadRow: true,
    );
  }
}

Widget _buildHtml(
  BuildContext context,
  String html, {
  required bool showPdfDownloadRow,
}) {
  return HtmlWidget(
    html,
    textStyle: MindBloomingTextStyle.normal,
    factoryBuilder: MyWidgetFactory.new,
    customWidgetBuilder: (element) {
      // ---------------------------
      // iframe (YT)
      // ---------------------------
      if (element.localName == 'iframe') {
        final src = element.attributes['src'];
        if (src == null || src.isEmpty) return null;
        return CustomYTAdapter(url: src);
      }

      // ---------------------------
      // img
      // - Ignora completamente width/height dello style per il sizing finale
      // - Usa ImageStreamListener per ottenere il ratio reale (quando possibile)
      // - Se NON ci sono dimensioni esplicite nello style/attrs -> limita molto l'altezza
      //   così non vengono giganti.
      // ---------------------------
      if (element.localName == 'img') {
        final src = element.attributes['src'];
        if (src == null || src.isEmpty) return null;

        final hasExplicitSize = _hasExplicitSize(element);

        // fallback ratio: se il listener fallisce (CORS), usiamo ratio da attrs/style;
        // se non c'è neanche quello, 1:1.
        final fallbackRatio = _extractAspectRatioFromHtml(element) ?? (1 / 1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SmartAutoSizedImageNetwork(
            url: src,
            borderRadius: BorderRadius.circular(10),
            fitAndroidIos: BoxFit.contain,
            fitWeb: BoxFitWeb.contain,
            fallbackAspectRatio: fallbackRatio,
            // quando non ci sono size nello style/attrs, riduci parecchio:
            maxHeight: hasExplicitSize ? 360 : 220,
          ),
        );
      }

      // ---------------------------
      // audio / video
      // ---------------------------
      if (element.localName == 'audio' || element.localName == 'video') {
        final src = element.children
            .firstWhere(
              (e) => e.localName == "source",
              orElse: () => element,
            )
            .attributes['src'];

        if (src == null || src.isEmpty) return null;
        return CustomAudioAdapter(url: src);
      }

      // ---------------------------
      // a (PDF preview come prima)
      // ---------------------------
      if (element.localName == 'a') {
        final href = element.attributes['href'];
        if (href == null || href.isEmpty) return null;

        final pdfPreview = SizedBox(
          height: 600,
          child: FutureBuilder<Uint8List>(
            future: _fetchPdf(href),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return PdfWithAutoScroll(data: snapshot.data!);
              }
              return const Center(child: Text('No PDF data'));
            },
          ),
        );

        if (!showPdfDownloadRow) return pdfPreview;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0, top: 2.0),
                      child: Icon(
                        Icons.download,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                      child: HtmlWidget(
                        element.outerHtml,
                        factoryBuilder: MyWidgetFactory.new,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pdfPreview,
          ],
        );
      }

      return null;
    },
  );
}

Future<Uint8List> _fetchPdf(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) return response.bodyBytes;
  throw Exception('Failed to load PDF');
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}

// =====================================================
// Helpers: detect/ratio from HTML (solo fallback)
// =====================================================

bool _hasExplicitSize(dynamic element) {
  final wAttr = element.attributes['width'];
  final hAttr = element.attributes['height'];
  if ((wAttr != null && wAttr.trim().isNotEmpty) ||
      (hAttr != null && hAttr.trim().isNotEmpty)) {
    return true;
  }

  final style = element.attributes['style'];
  if (style == null || style.isEmpty) return false;

  final hasW = RegExp(r'width\s*:\s*\d+(\.\d+)?px', caseSensitive: false)
      .hasMatch(style);
  final hasH = RegExp(r'height\s*:\s*\d+(\.\d+)?px', caseSensitive: false)
      .hasMatch(style);

  return hasW || hasH;
}

double? _extractAspectRatioFromHtml(dynamic element) {
  // 1) width/height attributes
  final wAttr = _tryParseDouble(element.attributes['width']);
  final hAttr = _tryParseDouble(element.attributes['height']);
  if (wAttr != null && hAttr != null && wAttr > 0 && hAttr > 0) {
    return wAttr / hAttr;
  }

  // 2) style width/height (solo ratio)
  final style = element.attributes['style'];
  if (style != null && style.isNotEmpty) {
    final wStyle = _extractPx(style, 'width');
    final hStyle = _extractPx(style, 'height');
    if (wStyle != null && hStyle != null && wStyle > 0 && hStyle > 0) {
      return wStyle / hStyle;
    }
  }

  return null;
}

double? _tryParseDouble(String? s) {
  if (s == null) return null;
  final cleaned = s.trim();
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

double? _extractPx(String style, String prop) {
  final reg = RegExp(
    '$prop\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)px',
    caseSensitive: false,
  );
  final m = reg.firstMatch(style);
  if (m == null) return null;
  return double.tryParse(m.group(1) ?? '');
}

// =====================================================
// IMAGE: ImageStreamListener -> ratio reale + FittedBox
// - Evita il taglio su resize (il widget viene scalato, non "clippato")
// - Se non ci sono style/attrs, maxHeight molto basso (ridotte parecchio)
// =====================================================

class SmartAutoSizedImageNetwork extends StatefulWidget {
  const SmartAutoSizedImageNetwork({
    super.key,
    required this.url,
    required this.maxHeight,
    required this.fallbackAspectRatio,
    this.borderRadius = BorderRadius.zero,
    this.fitAndroidIos = BoxFit.contain,
    this.fitWeb = BoxFitWeb.contain,
  });

  final String url;

  /// Limite di altezza del box (riduce immagini senza style/attrs).
  final double maxHeight;

  /// Ratio usato solo se il listener non può leggere le dimensioni (es. CORS su web).
  /// Non guida MAI le dimensioni finali da style: serve solo per evitare box “strani”.
  final double fallbackAspectRatio;

  final BorderRadius borderRadius;
  final BoxFit fitAndroidIos;
  final BoxFitWeb fitWeb;

  @override
  State<SmartAutoSizedImageNetwork> createState() =>
      _SmartAutoSizedImageNetworkState();
}

class _SmartAutoSizedImageNetworkState
    extends State<SmartAutoSizedImageNetwork> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  ui.Size? _intrinsic; // size reale dell'immagine
  bool _listenerFailed = false;

  @override
  void initState() {
    super.initState();
    _resolveIntrinsicSize();
  }

  @override
  void didUpdateWidget(covariant SmartAutoSizedImageNetwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _intrinsic = null;
      _listenerFailed = false;
      _detach();
      _resolveIntrinsicSize();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      try {
        _stream!.removeListener(_listener!);
      } catch (_) {}
    }
    _stream = null;
    _listener = null;
  }

  void _resolveIntrinsicSize() {
    // Usa NetworkImage SOLO per leggere (ImageInfo). Il rendering resta ImageNetwork.
    final provider = NetworkImage(widget.url);

    final stream = provider.resolve(const ImageConfiguration());
    _stream = stream;

    _listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        final img = info.image;
        final w = img.width.toDouble();
        final h = img.height.toDouble();

        if (!mounted) return;

        if (w > 0 && h > 0) {
          setState(() {
            _intrinsic = ui.Size(w, h);
            _listenerFailed = false;
          });
        }
      },
      onError: (Object _, StackTrace? __) {
        if (!mounted) return;
        // Su web può fallire per CORS: in quel caso usiamo fallback ratio e stop.
        setState(() {
          _intrinsic = null;
          _listenerFailed = true;
        });
      },
    );

    stream.addListener(_listener!);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        final availableW = (c.maxWidth.isFinite && c.maxWidth > 0)
            ? c.maxWidth
            : mq.size.width;

        // Limita altezza (molto utile per immagini senza size nel markup)
        final maxH = widget.maxHeight;

        // Se abbiamo la size reale, usiamola per definire il child "base".
        // Altrimenti usiamo un "base size" coerente con il fallback ratio.
        final baseSize = _intrinsic ??
            _fallbackBaseSize(
              ratio: _safeRatio(widget.fallbackAspectRatio),
            );

        // Il box finale: maxWidth = availableW, maxHeight = maxH.
        // Dentro, FittedBox scala il child senza tagli su resize.
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: availableW,
            maxHeight: maxH,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: SizedBox(
                  width: baseSize.width,
                  height: baseSize.height,
                  child: ImageNetwork(
                    image: widget.url,
                    // ImageNetwork richiede width/height: passiamo la base size,
                    // poi FittedBox si occupa di scalare senza clipping.
                    width: baseSize.width,
                    height: baseSize.height,
                    duration: 2000,
                    curve: Curves.easeIn,
                    fitAndroidIos: widget.fitAndroidIos,
                    fitWeb: widget.fitWeb,
                    onLoading: SizedBox(
                      width: math.min(22, maxH),
                      height: math.min(22, maxH),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    onError: const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _safeRatio(double r) {
    if (!r.isFinite || r <= 0) return 1.0;
    return r;
  }

  ui.Size _fallbackBaseSize({required double ratio}) {
    // Base size “ragionevole” per evitare immagini gigantesche quando non abbiamo la size reale.
    // NOTA: non impatta il box finale (che è limitato dal maxHeight e dalla maxWidth),
    // serve solo a dare a ImageNetwork delle dimensioni sensate.
    const double baseW = 800; // abbastanza grande per qualità su web
    final baseH = baseW / ratio;
    return ui.Size(baseW, baseH);
  }
}

// =====================================================
// PDF PREVIEW (AUTO SCROLL SENTINELS)
// =====================================================

class PdfWithAutoScroll extends StatefulWidget {
  const PdfWithAutoScroll({super.key, required this.data});

  final Uint8List data;

  @override
  State<PdfWithAutoScroll> createState() => _PdfWithAutoScrollState();
}

class _PdfWithAutoScrollState extends State<PdfWithAutoScroll> {
  final GlobalKey _sentinelKey = GlobalKey();
  final GlobalKey _topSentinelKey = GlobalKey();

  bool _isAtEnd(ScrollMetrics metrics) =>
      metrics.pixels >= metrics.maxScrollExtent - 2.0;

  bool _isAtStart(ScrollMetrics metrics) =>
      metrics.pixels <= metrics.minScrollExtent + 2.0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;

          if (_isAtEnd(metrics)) {
            final ctx = _sentinelKey.currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(
                ctx,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          } else if (_isAtStart(metrics)) {
            final ctx = _topSentinelKey.currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(
                ctx,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          }
        }
        return false;
      },
      child: Column(
        children: [
          Container(key: _topSentinelKey),
          SizedBox(
            height: 600,
            child: PdfPreview(
              build: (format) async => widget.data,
              useActions: false,
            ),
          ),
          Container(key: _sentinelKey),
        ],
      ),
    );
  }
}

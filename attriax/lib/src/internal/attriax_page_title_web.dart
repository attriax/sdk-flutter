import 'package:web/web.dart' as web;

String? currentAttriaxDocumentTitle() {
  final title = web.window.document.title.trim();
  return title.isEmpty ? null : title;
}
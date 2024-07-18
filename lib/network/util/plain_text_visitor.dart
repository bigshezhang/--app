import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart';
class PlaintextVisitor extends TreeVisitor {
  final StringBuffer _str;

  PlaintextVisitor() : _str = StringBuffer();

  String toString() => _str.toString();

  visitDocument(dom.Document node) {
    visitChildren(node);
  }

  visitDocumentType(dom.DocumentType node) {
    visitChildren(node);
  }

  visitText(dom.Text node) {
    if (node.text=="\n")
      return;
    writeTextNodeAsHtml(_str, node);
  }

  visitElement(dom.Element node) {
    final tag = node.localName;
    if (tag=="li")
      _str.write("\n * ");
    else if (tag=="dt")
      _str.write("  ");
    else if (tag=="p" || tag== "h1" || tag== "h2" || tag=="h3" || tag== "h4" || tag== "h5" || tag=="tr")
      _str.write("\n");
    if (node.nodes.isNotEmpty) {
      visitChildren(node);
    } else if (isVoidElement(tag)) {
      return;
    }
    if (tag=="br" || tag== "dd" || tag=="dt" || tag== "p" || tag== "h1" || tag== "h2" || tag== "h3" || tag== "h4" || tag== "h5")
      _str.write("\n");
  }

}
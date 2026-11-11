import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// En el navegador: el servidor de la radio no permite leer su respuesta
/// directamente, así que se prueba cargarla en un reproductor invisible
/// (sin sonido). Si carga, está transmitiendo; si da error, está apagada.
Future<bool?> radioTransmitiendo(String url) {
  final completo = Completer<bool?>();
  final audio = web.HTMLAudioElement()
    ..preload = 'metadata'
    ..muted = true;

  void terminar(bool? resultado) {
    if (completo.isCompleted) return;
    completo.complete(resultado);
    // Corta la descarga.
    audio.removeAttribute('src');
    audio.load();
  }

  audio.addEventListener(
      'loadedmetadata', ((web.Event _) => terminar(true)).toJS);
  audio.addEventListener('error', ((web.Event _) => terminar(false)).toJS);

  final separador = url.contains('?') ? '&' : '?';
  audio.src = '$url${separador}revisar=${DateTime.now().millisecondsSinceEpoch}';
  audio.load();

  Timer(const Duration(seconds: 12), () => terminar(null));
  return completo.future;
}

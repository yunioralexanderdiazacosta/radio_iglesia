import 'dart:async';
import 'dart:io';

/// En el teléfono: pide la dirección de la radio y mira qué responde.
/// Cuando la radio está apagada, el servidor devuelve una página casi vacía
/// en lugar de audio.
Future<bool?> radioTransmitiendo(String url) async {
  final cliente = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final pedido = await cliente.getUrl(Uri.parse(url))
      // Si el servidor redirige, es hacia el audio: eso ya indica que
      // transmite (apagada responde directo con una página vacía).
      ..followRedirects = false;
    final respuesta =
        await pedido.close().timeout(const Duration(seconds: 10));
    if (respuesta.isRedirect) {
      respuesta.listen(null).cancel();
      return true;
    }
    final tipo = respuesta.headers.contentType?.mimeType ?? '';
    final largo = respuesta.contentLength; // -1 = sin fin (audio en vivo)
    final apagada = respuesta.statusCode >= 400 ||
        tipo.startsWith('text/') ||
        (largo >= 0 && largo < 1024);
    final esAudio = !apagada;
    // No descarga el audio: solo queríamos ver la respuesta.
    respuesta.listen(null).cancel();
    return esAudio;
  } on TimeoutException {
    return null;
  } on HttpException {
    // El servidor respondió, pero no en HTTP normal: los servidores de
    // radio antiguos (Shoutcast) responden así cuando están transmitiendo.
    return true;
  } on IOException {
    return null;
  } finally {
    cliente.close(force: true);
  }
}

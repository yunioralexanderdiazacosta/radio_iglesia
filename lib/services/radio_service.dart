import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../config.dart';
import 'estado_radio.dart';

/// Maneja la reproducción de la radio en vivo.
class RadioService {
  RadioService._();
  static final instance = RadioService._();

  final AudioPlayer player = AudioPlayer();

  /// Texto "sonando ahora" que envía la radio (si lo envía).
  final ValueNotifier<String?> sonandoAhora = ValueNotifier(null);

  /// Mensaje de error para mostrar en pantalla (null = sin error).
  final ValueNotifier<String?> error = ValueNotifier(null);

  /// Tiempo que lleva sonando la radio desde que se tocó "play".
  final ValueNotifier<Duration> tiempoEscuchando =
      ValueNotifier(Duration.zero);

  /// true cuando el audio está saliendo de verdad por el parlante.
  ///
  /// No basta con el estado "ready" del reproductor: en el navegador, con
  /// radios en vivo, se queda en "buffering" aunque esté sonando. Por eso
  /// también se mira si la posición del audio está avanzando.
  final ValueNotifier<bool> alAire = ValueNotifier(false);

  /// Si la radio está transmitiendo: true, false (apagada) o null (revisando).
  /// Mientras esté apagada no se puede dar play.
  final ValueNotifier<bool?> enLinea = ValueNotifier(null);

  /// Avisa cuando la radio estaba apagada y vuelve a transmitir.
  final _volvio = StreamController<void>.broadcast();
  Stream<void> get alVolverAlAire => _volvio.stream;

  bool _quiereSonar = false;
  bool _revisando = false;
  Timer? _reintento;
  Timer? _reloj;
  Timer? _vigilante;
  Duration _ultimaPosicion = Duration.zero;
  DateTime _ultimoAvance = DateTime(2000);

  static const _tick = Duration(milliseconds: 500);

  Future<void> inicializar() async {
    _reloj = Timer.periodic(_tick, (_) => _revisar());

    // Revisa ahora y cada 15 segundos si la radio está transmitiendo.
    revisarSiTransmite();
    _vigilante = Timer.periodic(
        const Duration(seconds: 15), (_) => revisarSiTransmite());

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Lee el título de la canción / programa (metadatos ICY).
    player.icyMetadataStream.listen((meta) {
      final titulo = meta?.info?.title?.trim();
      sonandoAhora.value =
          (titulo == null || titulo.isEmpty) ? null : titulo;
    });

    // Si se corta la conexión, intenta reconectar sola.
    player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        error.value = 'Se perdió la conexión. Reintentando...';
        _programarReintento();
      },
    );
  }

  /// Pregunta al servidor si la radio está transmitiendo.
  Future<void> revisarSiTransmite() async {
    // Si ya está sonando, es obvio que transmite.
    if (alAire.value) {
      _actualizarEnLinea(true);
      return;
    }
    if (_revisando) return;
    _revisando = true;
    try {
      final r = await radioTransmitiendo(Config.urlRadio);
      // null = no se pudo saber (sin internet): se deja como estaba,
      // y si aún no se sabía nada, se permite intentar.
      _actualizarEnLinea(r ?? enLinea.value ?? true);
    } finally {
      _revisando = false;
    }
  }

  void _actualizarEnLinea(bool valor) {
    final antes = enLinea.value;
    if (antes == valor) return;
    enLinea.value = valor;
    if (antes == false && valor) _volvio.add(null);
    if (!valor && _quiereSonar && !alAire.value) {
      // Se apagó la radio mientras intentaba conectar: deja de intentar.
      pausar();
      error.value = null;
    }
  }

  /// Se ejecuta cada medio segundo: decide si está sonando y suma el tiempo.
  void _revisar() {
    final ahora = DateTime.now();
    final pos = player.position;
    if (pos > _ultimaPosicion) _ultimoAvance = ahora;
    _ultimaPosicion = pos;

    final s = player.playerState;
    final suena = s.playing &&
        (s.processingState == ProcessingState.ready ||
            ahora.difference(_ultimoAvance) < const Duration(seconds: 3));

    if (alAire.value != suena) alAire.value = suena;
    if (suena) {
      error.value = null;
      tiempoEscuchando.value += _tick;
    }
  }

  Future<void> _cargar() async {
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(Config.urlRadio),
        tag: MediaItem(
          id: 'radio-en-vivo',
          title: Config.nombreRadio,
          artist: Config.nombreIglesia,
          album: 'En vivo',
        ),
      ),
    );
  }

  Future<void> reproducir() async {
    if (enLinea.value == false) return; // radio apagada
    // Si es un "play" nuevo (no un reintento), el contador empieza de cero.
    if (!_quiereSonar) tiempoEscuchando.value = Duration.zero;
    _quiereSonar = true;
    _ultimoAvance = DateTime(2000);
    error.value = null;
    try {
      // En una radio en vivo siempre recargamos para escuchar
      // lo que suena AHORA y no lo que quedó en pausa.
      await _cargar();
      // Punto de partida para detectar que el audio avanza.
      _ultimaPosicion = player.position;
      _ultimoAvance = DateTime(2000);
      await player.play();
    } catch (e) {
      error.value = 'No se pudo conectar con la radio. Revisa tu internet.';
      _programarReintento();
    }
  }

  Future<void> pausar() async {
    _quiereSonar = false;
    _reintento?.cancel();
    await player.stop();
  }

  Future<void> cambiarVolumen(double v) => player.setVolume(v);

  void dispose() {
    _reloj?.cancel();
    _reintento?.cancel();
    _vigilante?.cancel();
    _volvio.close();
  }

  void _programarReintento() {
    if (!_quiereSonar) return;
    _reintento?.cancel();
    _reintento = Timer(const Duration(seconds: 5), () async {
      // Antes de reintentar, mira si es que la radio se apagó.
      await revisarSiTransmite();
      if (_quiereSonar) reproducir();
    });
  }
}

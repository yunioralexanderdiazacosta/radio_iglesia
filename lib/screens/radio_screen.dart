import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../config.dart';
import '../services/radio_service.dart';
import '../tema.dart';
import '../widgets/programa_widgets.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key, this.alVerProgramacion});

  /// Lleva a la pestaña de Programación.
  final VoidCallback? alVerProgramacion;

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with SingleTickerProviderStateMixin {
  // Una sola animación mueve: rayos, anillo del logo, ondas y ecualizador.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  final radio = RadioService.instance;
  @override
  void initState() {
    super.initState();
    radio.alAire.addListener(_alCambiarAlAire);
    radio.enLinea.addListener(_alCambiarAlAire);
  }

  // Cuando empieza o deja de sonar: redibuja y activa/detiene animaciones.
  void _alCambiarAlAire() {
    if (!mounted) return;
    radio.alAire.value ? _anim.repeat() : _anim.stop();
    setState(() {});
  }

  @override
  void dispose() {
    radio.alAire.removeListener(_alCambiarAlAire);
    radio.enLinea.removeListener(_alCambiarAlAire);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FondoAzul(
      giro: _anim,
      // Los rayos salen desde detrás del logo de la radio.
      centroRayos: const Alignment(0, -0.6),
      oscurecerAbajo: true,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: StreamBuilder<PlayerState>(
              stream: radio.player.playerStateStream,
              builder: (context, snapshot) {
                final sonando = snapshot.data?.playing ?? false;
                final alAire = sonando && radio.alAire.value;
                final cargando = sonando && !alAire;
                // La radio no está transmitiendo: no se puede dar play.
                final apagada = !sonando && radio.enLinea.value == false;

                // El logo se adapta al alto del celular para que el botón
                // de play siempre se vea sin tener que bajar la pantalla.
                final pantalla = MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical;
                final anchoDisponible =
                    math.min(MediaQuery.sizeOf(context).width, 460.0) - 44;
                final altoMax = (pantalla - 520).clamp(120.0, 230.0);
                final anchoLogo =
                    math.min(anchoDisponible, altoMax / _HeroRadio.proporcion);
                final espacio = pantalla < 900 ? 14.0 : 24.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 110),
                  child: Column(
                    children: [
                      _BarraSuperior(
                        alAire: alAire,
                        cargando: cargando,
                        apagada: apagada,
                      ),
                      SizedBox(height: espacio * 0.5),
                      // El logo ya trae el nombre y el lema de la radio.
                      _HeroRadio(
                        anim: _anim,
                        activo: alAire,
                        ancho: anchoLogo,
                      ),
                      SizedBox(height: espacio * 0.7),
                      // El reproductor va primero: el play debe verse
                      // apenas se abre la app.
                      Stack(
                        children: [
                          _Reproductor(
                            anim: _anim,
                            sonando: sonando,
                            cargando: cargando,
                            alAire: alAire,
                            apagada: apagada,
                          ),
                          // Cinta de colores del logo en el borde superior.
                          Positioned(
                            top: 0,
                            left: 48,
                            right: 48,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: Tema.degradadoTricolor,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Config.colorAmarillo
                                        .withValues(alpha: 0.6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (apagada) ...[
                        const SizedBox(height: 12),
                        const _AvisoFueraDelAire(),
                      ],
                      const SizedBox(height: 12),
                      TarjetaProgramaActual(
                        onTap: widget.alVerProgramacion,
                      ),
                      ValueListenableBuilder<String?>(
                        valueListenable: radio.error,
                        builder: (_, msg, __) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: msg == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: _AvisoError(msg),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  const _BarraSuperior({
    required this.alAire,
    required this.cargando,
    required this.apagada,
  });
  final bool alAire;
  final bool cargando;
  final bool apagada;

  String get _saludo {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos días';
    if (h >= 12 && h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _saludo,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
              const Text(
                'Dios te bendiga',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _EtiquetaEnVivo(alAire: alAire, cargando: cargando, apagada: apagada),
      ],
    );
  }
}

/// Logo de la radio con brillo, ondas de sonido y un destello de luz.
class _HeroRadio extends StatefulWidget {
  const _HeroRadio({
    required this.anim,
    required this.activo,
    required this.ancho,
  });

  /// Alto / ancho del logo de la radio.
  static const proporcion = 537 / 1100;

  final Animation<double> anim;
  final bool activo;
  final double ancho;

  @override
  State<_HeroRadio> createState() => _HeroRadioState();
}

class _HeroRadioState extends State<_HeroRadio>
    with SingleTickerProviderStateMixin {
  // Destello que cruza el logo: una vez al abrir y en bucle mientras suena.
  late final _brillo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void initState() {
    super.initState();
    _brillo.forward();
  }

  @override
  void didUpdateWidget(_HeroRadio old) {
    super.didUpdateWidget(old);
    if (widget.activo && !old.activo) {
      _brillo.repeat();
    } else if (!widget.activo && old.activo) {
      _brillo.forward(); // termina la pasada actual y se detiene
    }
  }

  @override
  void dispose() {
    _brillo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alto = widget.ancho * _HeroRadio.proporcion;
    final margen = alto * 0.12;

    final logo = AnimatedBuilder(
      animation: _brillo,
      builder: (_, child) {
        // La franja de luz cruza durante el primer 45 % del ciclo.
        final c = -0.3 + _brillo.value * 3.0;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (r) => LinearGradient(
            begin: const Alignment(-1, -0.4),
            end: const Alignment(1, 0.4),
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.65),
              Colors.white.withValues(alpha: 0),
            ],
            stops: [
              (c - 0.12).clamp(0.0, 1.0),
              c.clamp(0.0, 1.0),
              (c + 0.12).clamp(0.0, 1.0),
            ],
          ).createShader(r),
          child: child,
        );
      },
      child: Image.asset(
        Config.rutaLogoRadio,
        width: widget.ancho,
        height: alto,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: Config.nombreRadio,
      ),
    );

    return RepaintBoundary(
      child: SizedBox(
        width: widget.ancho + margen * 2,
        height: alto + margen * 2,
        child: AnimatedBuilder(
          animation: widget.anim,
          builder: (_, child) {
            final t = widget.anim.value;
            // Late suave al ritmo (solo cuando suena).
            final pulso = widget.activo
                ? math.sin(t * 2 * math.pi * 40).abs()
                : 0.0;
            final flotar =
                widget.activo ? math.sin(t * 2 * math.pi * 6) * 4 : 0.0;
            return CustomPaint(
              painter: _OndasPainter(t: t, activo: widget.activo),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, flotar),
                  child: Transform.scale(
                    scale: 1 + pulso * 0.018,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: logo,
        ),
      ),
    );
  }
}

/// Resplandor detrás del logo y ondas ovaladas cuando suena.
class _OndasPainter extends CustomPainter {
  _OndasPainter({required this.t, required this.activo});

  final double t;
  final bool activo;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final base = Rect.fromCenter(
        center: c, width: size.width * 0.78, height: size.height * 0.72);

    // Resplandor dorado y azul.
    canvas.drawOval(
      base.inflate(size.width * 0.08),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Config.colorAcento.withValues(alpha: activo ? 0.42 : 0.3),
            const Color(0xFF2E5BFF).withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(base.inflate(size.width * 0.08)),
    );

    if (!activo) return;

    const colores = [
      Config.colorAmarillo,
      Config.colorCeleste,
      Config.colorRojo,
    ];
    for (var i = 0; i < 3; i++) {
      final p = (t * 6 + i / 3) % 1.0;
      final r = Rect.fromCenter(
        center: c,
        width: base.width + (size.width - base.width) * p,
        height: base.height + (size.height - base.height) * p,
      );
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - p) + 0.5
          ..color = colores[i].withValues(alpha: 0.6 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_OndasPainter old) =>
      old.t != t || old.activo != activo;
}

class _Reproductor extends StatelessWidget {
  const _Reproductor({
    required this.anim,
    required this.sonando,
    required this.cargando,
    required this.alAire,
    required this.apagada,
  });

  final Animation<double> anim;
  final bool sonando;
  final bool cargando;
  final bool alAire;
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;

    return Vidrio(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Column(
        children: [
          // Sonando ahora
          Row(
            children: [
              _Ecualizador(anim: anim, activo: alAire),
              const SizedBox(width: 14),
              Expanded(
                child: ValueListenableBuilder<String?>(
                  valueListenable: radio.sonandoAhora,
                  builder: (_, titulo, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apagada ? 'ESTADO' : 'SONANDO AHORA',
                        style: TextStyle(
                          color: Config.colorAmarillo.withValues(alpha: 0.9),
                          fontSize: 10.5,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        apagada
                            ? 'Radio fuera del aire'
                            : titulo ??
                                (alAire
                                    ? 'Transmisión en vivo'
                                    : 'Presiona play para escuchar'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 18),

          // Tiempo + botón
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<Duration>(
                  valueListenable: radio.tiempoEscuchando,
                  builder: (_, t, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TIEMPO ESCUCHANDO',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 10.5,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formato(t),
                          style: TextStyle(
                            color: sonando || t > Duration.zero
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 38,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _BotonPlay(
                sonando: sonando,
                cargando: cargando,
                onTap: apagada
                    ? null
                    : (sonando ? radio.pausar : radio.reproducir),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Volumen
          StreamBuilder<double>(
            stream: radio.player.volumeStream,
            builder: (_, snap) {
              final vol = snap.data ?? 1.0;
              return Row(
                children: [
                  IconButton(
                    tooltip: vol == 0 ? 'Activar sonido' : 'Silenciar',
                    onPressed: () =>
                        radio.cambiarVolumen(vol == 0 ? 1.0 : 0.0),
                    icon: Icon(
                      vol == 0
                          ? Icons.volume_off_rounded
                          : Icons.volume_down_rounded,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: Config.colorAmarillo,
                        inactiveTrackColor:
                            Colors.white.withValues(alpha: 0.15),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8),
                        overlayColor:
                            Config.colorAcento.withValues(alpha: 0.2),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: vol,
                        onChanged: radio.cambiarVolumen,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child:
                        Icon(Icons.volume_up_rounded, color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formato(Duration d) {
    String dos(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${dos(h)}:${dos(m)}:${dos(s)}' : '${dos(m)}:${dos(s)}';
  }
}

class _BotonPlay extends StatelessWidget {
  const _BotonPlay({
    required this.sonando,
    required this.cargando,
    required this.onTap,
  });

  final bool sonando;
  final bool cargando;

  /// null = desactivado (radio fuera del aire).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const t = 84.0;
    final activo = onTap != null;
    return Semantics(
      button: true,
      enabled: activo,
      label: !activo
          ? 'Radio fuera del aire'
          : (sonando ? 'Detener radio' : 'Escuchar radio'),
      child: SizedBox(
        width: t + 12,
        height: t + 12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (cargando)
              const SizedBox.expand(
                child: CircularProgressIndicator(
                  color: Config.colorAmarillo,
                  strokeWidth: 3,
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (activo)
                    BoxShadow(
                      color: Config.colorAcento.withValues(alpha: 0.6),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: Ink(
                  width: t,
                  height: t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: activo ? Tema.degradadoDorado : null,
                    color: activo ? null : Colors.white.withValues(alpha: 0.12),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    customBorder: const CircleBorder(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Icon(
                        sonando
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(sonando),
                        size: 50,
                        color: activo ? Config.colorOscuro : Colors.white30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaEnVivo extends StatelessWidget {
  const _EtiquetaEnVivo({
    required this.alAire,
    required this.cargando,
    required this.apagada,
  });
  final bool alAire;
  final bool cargando;
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    final texto = apagada
        ? 'FUERA DEL AIRE'
        : cargando
            ? 'CONECTANDO'
            : (alAire ? 'EN VIVO' : 'RADIO 24/7');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: alAire ? Config.colorRojo : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: alAire
              ? const Color(0xFFFF6F60)
              : Colors.white.withValues(alpha: 0.15),
        ),
        boxShadow: alAire
            ? [
                BoxShadow(
                  color: Config.colorRojo.withValues(alpha: 0.5),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PuntoPulsante(activo: alAire),
          const SizedBox(width: 7),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PuntoPulsante extends StatefulWidget {
  const _PuntoPulsante({required this.activo});
  final bool activo;

  @override
  State<_PuntoPulsante> createState() => _PuntoPulsanteState();
}

class _PuntoPulsanteState extends State<_PuntoPulsante>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _actualizar();
  }

  @override
  void didUpdateWidget(_PuntoPulsante old) {
    super.didUpdateWidget(old);
    _actualizar();
  }

  // Solo parpadea mientras está al aire (así no redibuja sin necesidad).
  void _actualizar() {
    if (widget.activo && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.activo && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.activo) {
      return const Icon(Icons.circle, size: 8, color: Colors.white38);
    }
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: const Icon(Icons.circle, size: 8, color: Colors.white),
    );
  }
}

/// Ecualizador animado.
class _Ecualizador extends StatelessWidget {
  const _Ecualizador({required this.anim, required this.activo});
  final Animation<double> anim;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: Tema.degradadoDorado,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (i) {
            final fase = anim.value * 2 * math.pi * 24 + i * 1.7;
            final alto = activo
                ? 7 + 17 * (0.5 + 0.5 * math.sin(fase) * math.cos(fase / 2.3))
                    .abs()
                : 5.0 + i % 2 * 4;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
              width: 4,
              height: alto,
              decoration: BoxDecoration(
                color: Config.colorOscuro,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AvisoFueraDelAire extends StatelessWidget {
  const _AvisoFueraDelAire();

  @override
  Widget build(BuildContext context) {
    return Vidrio(
      radio: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Config.colorAmarillo.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Config.colorAmarillo, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'La radio no está transmitiendo ahora.\n',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'Te avisaremos aquí apenas vuelva al aire.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              style: TextStyle(color: Colors.white, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoError extends StatelessWidget {
  const _AvisoError(this.mensaje);
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Vidrio(
      radio: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFFF8A80)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

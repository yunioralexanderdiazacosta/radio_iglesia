import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../programacion.dart';
import '../tema.dart';

/// Reconstruye su contenido cada 30 segundos con la hora actual.
class ConHora extends StatefulWidget {
  const ConHora({super.key, required this.builder});
  final Widget Function(BuildContext context, DateTime ahora) builder;

  @override
  State<ConHora> createState() => _ConHoraState();
}

class _ConHoraState extends State<ConHora> {
  DateTime _ahora = DateTime.now();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 30),
        (_) => setState(() => _ahora = DateTime.now()));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _ahora);
}

/// Imagen del programa. Si todavía no tiene, muestra un diseño genérico.
class ImagenPrograma extends StatelessWidget {
  const ImagenPrograma({
    super.key,
    required this.programa,
    required this.tamano,
    this.radio = 18,
    this.alto,
  });

  final Programa programa;
  final double tamano;
  final double? alto;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final h = alto ?? tamano;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: SizedBox(
        width: tamano,
        height: h,
        child: programa.imagen != null
            ? Image.asset(programa.imagen!, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B22C4), Config.colorOscuro],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: RayosPainter(
                          t: 0, centro: const Alignment(0, 1.1)),
                    ),
                    Center(
                      child: Icon(
                        Icons.mic_rounded,
                        size: (h < tamano ? h : tamano) * 0.42,
                        color: Config.colorAmarillo,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Tarjeta "Al aire ahora" / "Próximo programa".
class TarjetaProgramaActual extends StatelessWidget {
  const TarjetaProgramaActual({super.key, this.oscuro = true, this.onTap});

  /// true = para fondo azul (pantalla Radio); false = fondo claro.
  final bool oscuro;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConHora(builder: (context, ahora) {
      final e = Programacion.actualOProxima(ahora);
      final contenido = e == null
          ? _SinProgramas(oscuro: oscuro)
          : _Contenido(emision: e, ahora: ahora, oscuro: oscuro);

      final tarjeta = oscuro
          ? Vidrio(padding: const EdgeInsets.all(14), radio: 24, child: contenido)
          : Tarjeta(padding: const EdgeInsets.all(14), child: contenido);

      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: tarjeta,
      );
    });
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.emision,
    required this.ahora,
    required this.oscuro,
  });

  final Emision emision;
  final DateTime ahora;
  final bool oscuro;

  @override
  Widget build(BuildContext context) {
    final enCurso = emision.alAire(ahora);
    final colorTexto = oscuro ? Colors.white : Config.colorOscuro;
    final colorSuave =
        oscuro ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600;

    final String detalle;
    if (enCurso) {
      detalle =
          'Termina en ${Programacion.duracion(emision.fin.difference(ahora))}';
    } else {
      detalle =
          'Comienza ${Programacion.cuando(emision.inicio, ahora)} a las '
          '${Programacion.hora(emision.inicio)}';
    }

    return Row(
      children: [
        ImagenPrograma(programa: emision.programa, tamano: 84),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Insignia(enCurso: enCurso),
              const SizedBox(height: 6),
              Text(
                emision.programa.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorTexto,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  if (emision.horario.etiqueta.isNotEmpty)
                    emision.horario.etiqueta,
                  Programacion.rango(emision),
                ].join(' · '),
                style: TextStyle(color: colorSuave, fontSize: 12.5),
              ),
              const SizedBox(height: 8),
              if (enCurso) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: emision.progreso(ahora),
                    minHeight: 5,
                    color: Config.colorAmarillo,
                    backgroundColor: oscuro
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(
                detalle,
                style: TextStyle(
                  color: oscuro ? Config.colorAmarillo : const Color(0xFFB36F00),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded,
            color: oscuro ? Colors.white38 : Colors.grey.shade400),
      ],
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.enCurso});
  final bool enCurso;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: enCurso ? const Color(0xFFE53935) : null,
        gradient: enCurso ? null : Tema.degradadoDorado,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enCurso ? Icons.circle : Icons.schedule_rounded,
            size: enCurso ? 7 : 11,
            color: enCurso ? Colors.white : Config.colorOscuro,
          ),
          const SizedBox(width: 5),
          Text(
            enCurso ? 'AL AIRE AHORA' : 'PRÓXIMO PROGRAMA',
            style: TextStyle(
              color: enCurso ? Colors.white : Config.colorOscuro,
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SinProgramas extends StatelessWidget {
  const _SinProgramas({required this.oscuro});
  final bool oscuro;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.music_note_rounded, color: Config.colorAmarillo),
        const SizedBox(width: 12),
        Text(
          'Música y bendición las 24 horas',
          style: TextStyle(
            color: oscuro ? Colors.white : Config.colorOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

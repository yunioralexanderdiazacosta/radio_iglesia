import 'package:flutter/material.dart';

import '../config.dart';
import '../programacion.dart';
import '../tema.dart';
import '../widgets/programa_widgets.dart';

class ProgramacionScreen extends StatefulWidget {
  const ProgramacionScreen({super.key});

  @override
  State<ProgramacionScreen> createState() => _ProgramacionScreenState();
}

class _ProgramacionScreenState extends State<ProgramacionScreen> {
  // Día elegido (1 = lunes ... 7 = domingo). Empieza en hoy.
  int _dia = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConHora(builder: (context, ahora) {
        // Próxima fecha que cae en el día elegido (hoy, o los días que vienen).
        final fecha = DateTime(
            ahora.year, ahora.month, ahora.day + (_dia - ahora.weekday) % 7);
        final emisiones = Programacion.delDia(fecha);

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Encabezado(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TarjetaProgramaActual(oscuro: false),
                        const SizedBox(height: 22),
                        const _Titulo('Programación del día'),
                        const SizedBox(height: 12),
                        _SelectorDia(
                          elegido: _dia,
                          hoy: ahora.weekday,
                          onElegir: (d) => setState(() => _dia = d),
                        ),
                        const SizedBox(height: 14),
                        if (emisiones.isEmpty)
                          const _Vacio()
                        else
                          for (final e in emisiones)
                            _FilaEmision(emision: e, ahora: ahora),
                        const SizedBox(height: 22),
                        _Titulo('Nuestros programas',
                            extra: '${programas.length}'),
                        const SizedBox(height: 12),
                        for (final p in programas) _TarjetaPrograma(p),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return FondoAzul(
      centroRayos: const Alignment(0, -1.2),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 70),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: Tema.degradadoDorado,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Config.colorAcento.withValues(alpha: 0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Config.colorOscuro, size: 34),
              ),
              const SizedBox(height: 18),
              const Text(
                'Programación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sintoniza ${Config.nombreRadio} y no te pierdas ningún programa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.extra});
  final String texto;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          texto,
          style: const TextStyle(
            color: Config.colorOscuro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (extra != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Config.colorPrincipal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              extra!,
              style: const TextStyle(
                color: Config.colorAmarillo,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectorDia extends StatelessWidget {
  const _SelectorDia({
    required this.elegido,
    required this.hoy,
    required this.onElegir,
  });

  final int elegido;
  final int hoy;
  final ValueChanged<int> onElegir;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final dia = i + 1;
        final activo = dia == elegido;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
            child: Semantics(
              button: true,
              selected: activo,
              label: Dia.nombres[i],
              child: GestureDetector(
                onTap: () => onElegir(dia),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: activo ? Tema.degradadoAzul : null,
                    color: activo ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: activo
                          ? Config.colorAmarillo
                          : Colors.grey.shade200,
                    ),
                    boxShadow: activo
                        ? [
                            BoxShadow(
                              color: Config.colorPrincipal
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Dia.cortos[i],
                        style: TextStyle(
                          color: activo ? Colors.white : Config.colorOscuro,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dia == hoy
                              ? Config.colorAmarillo
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FilaEmision extends StatelessWidget {
  const _FilaEmision({required this.emision, required this.ahora});
  final Emision emision;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final enCurso = emision.alAire(ahora);
    final termino = !ahora.isBefore(emision.fin);

    return Opacity(
      opacity: termino ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enCurso ? const Color(0xFFE53935) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: Tema.sombraSuave,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Column(
                children: [
                  Text(
                    Programacion.hora(emision.inicio),
                    style: const TextStyle(
                      color: Config.colorOscuro,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 14,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: Config.colorAcento.withValues(alpha: 0.5),
                  ),
                  Text(
                    Programacion.hora(emision.fin),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ImagenPrograma(programa: emision.programa, tamano: 58, radio: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emision.programa.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Config.colorOscuro,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (emision.horario.etiqueta.isNotEmpty)
                        _Etiqueta(emision.horario.etiqueta),
                      if (enCurso) ...[
                        const SizedBox(width: 6),
                        const _Etiqueta('EN VIVO', rojo: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {this.rojo = false});
  final String texto;
  final bool rojo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: rojo
            ? const Color(0xFFE53935)
            : Config.colorAcento.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: rojo ? Colors.white : const Color(0xFFB36F00),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      child: Row(
        children: [
          const Icon(Icons.music_note_rounded, color: Config.colorAcento),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este día hay música y bendición las 24 horas.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPrograma extends StatelessWidget {
  const _TarjetaPrograma(this.programa);
  final Programa programa;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Tema.sombraSuave,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (_, c) => ImagenPrograma(
              programa: programa,
              tamano: c.maxWidth,
              alto: c.maxWidth * 9 / 16,
              radio: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  programa.nombre,
                  style: const TextStyle(
                    color: Config.colorOscuro,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (programa.conductor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Con ${programa.conductor}',
                    style: const TextStyle(
                      color: Color(0xFFB36F00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (programa.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    programa.descripcion,
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                  ),
                ],
                const SizedBox(height: 14),
                for (final h in programa.horarios)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: Tema.degradadoAzul,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            h.desde < 18
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            size: 17,
                            color: Config.colorAmarillo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  if (h.etiqueta.isNotEmpty) h.etiqueta,
                                  Programacion.dias(h.dias),
                                ].join(' · '),
                                style: const TextStyle(
                                  color: Config.colorOscuro,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                Programacion.rangoHorario(h),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

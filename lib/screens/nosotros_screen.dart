import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../tema.dart';

class NosotrosScreen extends StatelessWidget {
  const NosotrosScreen({super.key, this.alEscucharRadio});

  /// Lleva a la pestaña de Radio.
  final VoidCallback? alEscucharRadio;

  static const _versiculos = [
    ('Jehová es mi pastor; nada me faltará.', 'Salmos 23:1'),
    ('Todo lo puedo en Cristo que me fortalece.', 'Filipenses 4:13'),
    ('Mas buscad primeramente el reino de Dios y su justicia, y todas estas cosas os serán añadidas.', 'Mateo 6:33'),
    ('Fíate de Jehová de todo tu corazón, y no te apoyes en tu propia prudencia.', 'Proverbios 3:5'),
    ('Pero los que esperan a Jehová tendrán nuevas fuerzas; levantarán alas como las águilas.', 'Isaías 40:31'),
    ('Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito.', 'Juan 3:16'),
    ('Recibiréis poder, cuando haya venido sobre vosotros el Espíritu Santo.', 'Hechos 1:8'),
  ];

  /// (icono, nombre, colores, enlace). Solo se muestran las que tienen enlace.
  static final _redes = [
    (
      FontAwesomeIcons.facebookF,
      'Facebook',
      const [Color(0xFF4A90FF), Color(0xFF1877F2)],
      Config.facebook,
    ),
    (
      FontAwesomeIcons.instagram,
      'Instagram',
      const [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976), Color(0xFF962FBF)],
      Config.instagram,
    ),
    (
      FontAwesomeIcons.tiktok,
      'TikTok',
      const [Color(0xFF3A3A3A), Color(0xFF010101)],
      Config.tiktok,
    ),
    (
      FontAwesomeIcons.youtube,
      'YouTube',
      const [Color(0xFFFF4E45), Color(0xFFD90000)],
      Config.youtube,
    ),
  ].where((r) => r.$4.isNotEmpty).toList();

  Future<void> _abrir(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final dia = DateTime.now().difference(DateTime(2024)).inDays;
    final (texto, cita) = _versiculos[dia % _versiculos.length];
    final hoy = DateTime.now().weekday; // 1 = lunes ... 7 = domingo
    final mapa =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(Config.busquedaMapa)}';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Encabezado(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Accesos rápidos
                      Tarjeta(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 8),
                        child: Row(
                          children: [
                            _AccesoRapido(
                              icono: Icons.chat_rounded,
                              texto: 'WhatsApp',
                              colores: const [
                                Color(0xFF2EE07A),
                                Color(0xFF128C7E)
                              ],
                              onTap: () => _abrir(
                                  'https://wa.me/${Config.whatsappPedidos}'),
                            ),
                            _AccesoRapido(
                              icono: Icons.call_rounded,
                              texto: 'Llamar',
                              colores: const [
                                Color(0xFF5B8CFF),
                                Config.colorPrincipal
                              ],
                              onTap: () =>
                                  _abrir('tel:+${Config.whatsappPedidos}'),
                            ),
                            _AccesoRapido(
                              icono: Icons.near_me_rounded,
                              texto: 'Cómo llegar',
                              colores: const [
                                Color(0xFFFF7A6B),
                                Color(0xFFE53935)
                              ],
                              onTap: () => _abrir(mapa),
                            ),
                            _AccesoRapido(
                              icono: Icons.graphic_eq_rounded,
                              texto: 'Radio',
                              colores: const [
                                Config.colorAmarillo,
                                Config.colorAcento
                              ],
                              onTap: alEscucharRadio,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Versículo del día
                      _VersiculoDelDia(texto: texto, cita: cita),
                      const SizedBox(height: 16),

                      // Redes sociales
                      if (_redes.isNotEmpty) ...[
                        Tarjeta(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _TituloSeccion(
                                icono: Icons.favorite_rounded,
                                texto: 'Síguenos en redes',
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  for (final r in _redes)
                                    _BotonRed(
                                      icono: r.$1,
                                      texto: r.$2,
                                      colores: r.$3,
                                      onTap: () => _abrir(r.$4),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Horarios
                      Tarjeta(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TituloSeccion(
                              icono: Icons.event_rounded,
                              texto: 'Horarios de servicio',
                            ),
                            const SizedBox(height: 14),
                            for (var i = 0; i < Config.horarios.length; i++)
                              _FilaHorario(
                                dia: Config.horarios[i].$1,
                                servicio: Config.horarios[i].$2,
                                horas: Config.horarios[i].$3,
                                esHoy: i + 1 == hoy,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dirección
                      Tarjeta(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TituloSeccion(
                              icono: Icons.location_on_rounded,
                              texto: 'Dónde estamos',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Config.direccion,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 14.5),
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => _abrir(mapa),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Config.colorPrincipal,
                                side: const BorderSide(
                                    color: Config.colorPrincipal, width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.map_rounded),
                              label: const Text('Abrir en Google Maps',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return FondoAzul(
      centroRayos: const Alignment(0, -0.2),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 72),
          child: Column(
            children: [
              const LogoCircular(tamano: 150),
              const SizedBox(height: 22),
              ShaderMask(
                shaderCallback: (r) => Tema.degradadoDorado.createShader(r),
                child: const Text(
                  'BIENVENIDO A CASA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                Config.nombreIglesia,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (r) => Tema.degradadoDorado.createShader(r),
                child: const Text(
                  '“${Config.lemaIglesia}”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Config.colorAmarillo.withValues(alpha: 0.5)),
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Fundador: ',
                        style: TextStyle(
                          color: Config.colorAmarillo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: Config.fundador,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  const _AccesoRapido({
    required this.icono,
    required this.texto,
    required this.colores,
    this.onTap,
  });

  final IconData icono;
  final String texto;
  final List<Color> colores;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colores,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colores.last.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icono, color: Colors.white, size: 25),
              ),
              const SizedBox(height: 8),
              Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Config.colorOscuro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersiculoDelDia extends StatelessWidget {
  const _VersiculoDelDia({required this.texto, required this.cita});
  final String texto;
  final String cita;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: Tema.degradadoDorado,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Config.colorAcento.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            bottom: -22,
            child: Icon(
              Icons.format_quote_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Config.colorOscuro.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'VERSÍCULO DEL DÍA',
                  style: TextStyle(
                    color: Config.colorOscuro,
                    fontSize: 10.5,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                texto,
                style: const TextStyle(
                  color: Config.colorOscuro,
                  fontSize: 17,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '— $cita',
                style: TextStyle(
                  color: Config.colorOscuro.withValues(alpha: 0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.icono, required this.texto});
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: Tema.degradadoAzul,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icono, color: Config.colorAmarillo, size: 19),
        ),
        const SizedBox(width: 12),
        Text(
          texto,
          style: const TextStyle(
            color: Config.colorOscuro,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FilaHorario extends StatelessWidget {
  const _FilaHorario({
    required this.dia,
    required this.servicio,
    required this.horas,
    required this.esHoy,
  });

  final String dia;
  final String servicio;
  final List<String> horas;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    final texto = esHoy ? Colors.white : Config.colorOscuro;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: esHoy ? null : const Color(0xFFF6F7FC),
        gradient: esHoy ? Tema.degradadoAzul : null,
        borderRadius: BorderRadius.circular(16),
        border: esHoy ? Border.all(color: Config.colorAmarillo) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dia,
                style: TextStyle(
                  color: esHoy ? Config.colorAmarillo : const Color(0xFFB36F00),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                ),
              ),
              if (esHoy) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: Config.colorAmarillo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HOY',
                    style: TextStyle(
                      color: Config.colorOscuro,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            servicio,
            style: TextStyle(
              color: texto,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final h in horas)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: esHoy
                        ? Colors.white.withValues(alpha: 0.12)
                        : Config.colorPrincipal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: Config.colorAmarillo),
                      const SizedBox(width: 4),
                      Text(
                        h,
                        style: const TextStyle(
                          color: Config.colorAmarillo,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonRed extends StatelessWidget {
  const _BotonRed({
    required this.icono,
    required this.texto,
    required this.colores,
    required this.onTap,
  });

  final FaIconData icono;
  final String texto;
  final List<Color> colores;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: 'Abrir $texto',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: colores,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colores.last.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(icono, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Config.colorOscuro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

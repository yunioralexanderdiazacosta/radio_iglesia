import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../tema.dart';

class OracionScreen extends StatefulWidget {
  const OracionScreen({super.key});

  @override
  State<OracionScreen> createState() => _OracionScreenState();
}

class _OracionScreenState extends State<OracionScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _ciudad = TextEditingController();
  final _pedido = TextEditingController();

  String _motivo = 'Salud';
  bool _ocultarNombre = false;
  bool _deseaContacto = false;

  static const _motivos = [
    ('Salud', Icons.healing_rounded),
    ('Familia', Icons.family_restroom_rounded),
    ('Trabajo / finanzas', Icons.work_rounded),
    ('Salvación', Icons.favorite_rounded),
    ('Estudios', Icons.school_rounded),
    ('Gratitud', Icons.celebration_rounded),
    ('Otro', Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _nombre.dispose();
    _ciudad.dispose();
    _pedido.dispose();
    super.dispose();
  }

  String _armarMensaje() {
    final b = StringBuffer('🙏 *PEDIDO DE ORACIÓN*\n\n');
    b.writeln(
        '*Nombre:* ${_ocultarNombre || _nombre.text.trim().isEmpty ? 'Reservado' : _nombre.text.trim()}');
    if (_ciudad.text.trim().isNotEmpty) {
      b.writeln('*Ciudad:* ${_ciudad.text.trim()}');
    }
    b.writeln('*Motivo:* $_motivo');
    b.writeln('\n*Petición:*\n${_pedido.text.trim()}\n');
    b.writeln(_deseaContacto
        ? '📞 Deseo que me contacten.'
        : 'No necesito que me contacten.');
    b.write('\n_Enviado desde la app ${Config.nombreRadio}_');
    return b.toString();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final url = Uri.parse(
      'https://wa.me/${Config.whatsappPedidos}'
      '?text=${Uri.encodeComponent(_armarMensaje())}',
    );

    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo abrir WhatsApp. ¿Está instalado?')));
      return;
    }

    // Limpia el formulario para el próximo pedido.
    _pedido.clear();
    setState(() {
      _motivo = 'Salud';
      _deseaContacto = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Toca "Enviar" en WhatsApp para completar tu pedido. ¡Estaremos orando!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Encabezado(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Transform.translate(
                  // La primera tarjeta se monta sobre el encabezado.
                  offset: const Offset(0, -36),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Tarjeta(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _Paso(
                                numero: 1,
                                titulo: '¿Por qué quieres que oremos?',
                              ),
                              const SizedBox(height: 16),
                              _GrillaMotivos(
                                motivos: _motivos,
                                elegido: _motivo,
                                onElegir: (m) => setState(() => _motivo = m),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Tarjeta(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _Paso(
                                numero: 2,
                                titulo: 'Escribe tu petición',
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pedido,
                                minLines: 5,
                                maxLines: 9,
                                maxLength: 1000,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Cuéntanos por qué quieres que oremos. Dios escucha cada palabra...',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 5)
                                        ? 'Por favor escribe tu petición'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Tarjeta(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _Paso(
                                numero: 3,
                                titulo: 'Tus datos',
                                subtitulo: 'Opcional',
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nombre,
                                enabled: !_ocultarNombre,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Tu nombre',
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _ciudad,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Tu ciudad',
                                  prefixIcon:
                                      Icon(Icons.location_on_outlined),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _Opcion(
                                icono: Icons.visibility_off_rounded,
                                titulo: 'Enviar de forma anónima',
                                detalle:
                                    'Tu número de WhatsApp sí será visible para el equipo.',
                                valor: _ocultarNombre,
                                onChanged: (v) =>
                                    setState(() => _ocultarNombre = v),
                              ),
                              _Opcion(
                                icono: Icons.phone_in_talk_rounded,
                                titulo: 'Deseo que me contacten',
                                detalle: 'Un hermano del equipo te escribirá.',
                                valor: _deseaContacto,
                                onChanged: (v) =>
                                    setState(() => _deseaContacto = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _BotonWhatsApp(onTap: _enviar),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text(
                              'Tu petición se trata con amor y discreción',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ],
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
                child: const Icon(Icons.volunteer_activism_rounded,
                    color: Config.colorOscuro, size: 34),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pedido de oración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Config.colorAmarillo.withValues(alpha: 0.35)),
                ),
                child: const Text(
                  '"Orad unos por otros, para que seáis sanados."\nSantiago 5:16',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.titulo, this.subtitulo});
  final int numero;
  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: Tema.degradadoAzul,
          ),
          child: Text(
            '$numero',
            style: const TextStyle(
              color: Config.colorAmarillo,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: Config.colorOscuro,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (subtitulo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Config.colorAcento.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitulo!,
              style: const TextStyle(
                color: Color(0xFFB36F00),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _GrillaMotivos extends StatelessWidget {
  const _GrillaMotivos({
    required this.motivos,
    required this.elegido,
    required this.onElegir,
  });

  final List<(String, IconData)> motivos;
  final String elegido;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const sep = 10.0;
      final columnas = c.maxWidth > 420 ? 4 : 3;
      final ancho = (c.maxWidth - sep * (columnas - 1)) / columnas;

      return Wrap(
        spacing: sep,
        runSpacing: sep,
        children: motivos.map((m) {
          final (texto, icono) = m;
          final activo = texto == elegido;
          return Semantics(
            button: true,
            selected: activo,
            child: GestureDetector(
              onTap: () => onElegir(texto),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: ancho,
                height: 86,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: activo ? Tema.degradadoAzul : null,
                  color: activo ? null : const Color(0xFFF6F7FC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: activo
                        ? Config.colorAmarillo
                        : Colors.grey.shade200,
                    width: activo ? 1.5 : 1,
                  ),
                  boxShadow: activo
                      ? [
                          BoxShadow(
                            color:
                                Config.colorPrincipal.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icono,
                      size: 26,
                      color: activo
                          ? Config.colorAmarillo
                          : Config.colorPrincipal.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      texto,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: activo ? Colors.white : Config.colorOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.valor,
    required this.onChanged,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool valor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!valor),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Config.colorPrincipal.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, size: 20, color: Config.colorPrincipal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: Config.colorOscuro)),
                  Text(detalle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Switch(
              value: valor,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: Config.colorAcento,
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonWhatsApp extends StatelessWidget {
  const _BotonWhatsApp({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2EE07A), Color(0xFF128C7E)],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 19),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Enviar por WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

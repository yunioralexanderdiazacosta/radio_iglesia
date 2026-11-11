import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../tema.dart';

/// Pestaña "Donar": datos del Pago Móvil para ofrendas y donaciones.
class DonacionesScreen extends StatelessWidget {
  const DonacionesScreen({super.key});

  static const _todo = 'Pago Móvil\n'
      'Banco: ${Config.pagoMovilBanco} (${Config.pagoMovilNombreBanco})\n'
      'RIF: ${Config.pagoMovilRif}\n'
      'Teléfono: ${Config.pagoMovilTelefono}';

  static Future<void> _copiar(
      BuildContext context, String texto, String aviso) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Config.colorAmarillo),
              const SizedBox(width: 10),
              Expanded(child: Text(aviso)),
            ],
          ),
        ),
      );
  }

  Future<void> _enviarComprobante() {
    const mensaje = '🙏 Hola, les envío el comprobante de mi ofrenda / '
        'donación por Pago Móvil.\n\n_Enviado desde la app ${Config.nombreRadio}_';
    return launchUrl(
      Uri.parse('https://wa.me/${Config.whatsappPedidos}'
          '?text=${Uri.encodeComponent(mensaje)}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Encabezado(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TarjetaPagoMovil(
                        onCopiar: (texto, aviso) =>
                            _copiar(context, texto, aviso),
                        onCopiarTodo: () => _copiar(context, _todo,
                            'Datos del Pago Móvil copiados. ¡Dios te bendiga!'),
                      ),
                      const SizedBox(height: 16),
                      Tarjeta(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '¿Cómo donar?',
                              style: TextStyle(
                                color: Config.colorOscuro,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _Paso(1, 'Copia los datos del Pago Móvil.'),
                            const _Paso(2,
                                'Abre la app de tu banco y entra en Pago Móvil.'),
                            const _Paso(3,
                                'Pega los datos, escribe el monto y confirma.'),
                            const _Paso(
                                4, 'Si deseas, envíanos tu comprobante.'),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: _enviarComprobante,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF128C7E),
                                side: const BorderSide(
                                    color: Color(0xFF25D366), width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.chat_rounded),
                              label: const Text(
                                'Enviar comprobante',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
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
                child: const Icon(Icons.favorite_rounded,
                    color: Config.colorOscuro, size: 34),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ofrendas y donaciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
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
                  '"Cada uno dé como propuso en su corazón… porque Dios ama '
                  'al dador alegre."\n2 Corintios 9:7',
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

class _TarjetaPagoMovil extends StatelessWidget {
  const _TarjetaPagoMovil({required this.onCopiar, required this.onCopiarTodo});

  final void Function(String texto, String aviso) onCopiar;
  final VoidCallback onCopiarTodo;

  @override
  Widget build(BuildContext context) {
    final datos = [
      (
        Icons.account_balance_rounded,
        'Banco',
        Config.pagoMovilBanco,
        Config.pagoMovilNombreBanco,
      ),
      (Icons.badge_rounded, 'RIF', Config.pagoMovilRif, null),
      (
        Icons.phone_iphone_rounded,
        'Teléfono',
        Config.pagoMovilTelefono,
        null,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: Tema.degradadoAzul,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Config.colorAmarillo.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Config.colorPrincipal.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: Tema.degradadoDorado,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.phone_android_rounded,
                    color: Config.colorOscuro, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago Móvil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Siembra en esta obra',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final (icono, etiqueta, valor, detalle) in datos)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(icono, color: Config.colorAmarillo, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detalle == null ? etiqueta : '$etiqueta · $detalle',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                        Text(
                          valor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copiar $etiqueta',
                    onPressed: () => onCopiar(valor, '$etiqueta copiado'),
                    icon: const Icon(Icons.copy_rounded,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: Tema.degradadoDorado,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onCopiarTodo,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_all_rounded, color: Config.colorOscuro),
                      SizedBox(width: 8),
                      Text(
                        'Copiar todos los datos',
                        style: TextStyle(
                          color: Config.colorOscuro,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
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

class _Paso extends StatelessWidget {
  const _Paso(this.numero, this.texto);
  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: Tema.degradadoAzul,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                color: Config.colorAmarillo,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

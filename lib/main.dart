import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'config.dart';
import 'screens/radio_screen.dart';
import 'screens/oracion_screen.dart';
import 'screens/donaciones_screen.dart';
import 'screens/nosotros_screen.dart';
import 'screens/programacion_screen.dart';
import 'services/radio_service.dart';
import 'tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Permite que la radio siga sonando con la pantalla apagada
  // y muestra los controles en la notificación / pantalla de bloqueo.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.iglesia.radio.audio',
    androidNotificationChannelName: 'Radio en vivo',
    androidNotificationOngoing: true,
  );

  await RadioService.instance.inicializar();
  runApp(const RadioIglesiaApp());
}

class RadioIglesiaApp extends StatelessWidget {
  const RadioIglesiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.nombreRadio,
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // En la web se puede abrir una pestaña directo con ?tab=1 a 4.
  int _indice =
      (int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0).clamp(0, 4);

  void _ir(int i) => setState(() => _indice = i);

  StreamSubscription<void>? _avisoRadio;

  @override
  void initState() {
    super.initState();
    _avisoRadio =
        RadioService.instance.alVolverAlAire.listen((_) => _avisarEnVivo());
  }

  @override
  void dispose() {
    _avisoRadio?.cancel();
    super.dispose();
  }

  /// Aviso cuando la radio vuelve a transmitir.
  void _avisarEnVivo() {
    if (!mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    mensajero.hideCurrentSnackBar();
    mensajero.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 12),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        backgroundColor: const Color(0xFFE53935),
        content: const Row(
          children: [
            Icon(Icons.radio_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡${Config.nombreRadio} ya está en vivo!',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'ESCUCHAR',
          textColor: Config.colorAmarillo,
          onPressed: () {
            _ir(0);
            RadioService.instance.reproducir();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _indice,
        children: [
          RadioScreen(alVerProgramacion: () => _ir(1)),
          const ProgramacionScreen(),
          const OracionScreen(),
          const DonacionesScreen(),
          NosotrosScreen(alEscucharRadio: () => _ir(0)),
        ],
      ),
      bottomNavigationBar: _BarraNavegacion(indice: _indice, onTap: _ir),
    );
  }
}

/// Barra inferior flotante con la pestaña activa en dorado.
class _BarraNavegacion extends StatelessWidget {
  const _BarraNavegacion({required this.indice, required this.onTap});
  final int indice;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.graphic_eq_rounded, 'Radio'),
    (Icons.calendar_month_rounded, 'Programas'),
    (Icons.volunteer_activism_rounded, 'Oración'),
    (Icons.favorite_rounded, 'Donar'),
    (Icons.church_rounded, 'Nosotros'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Config.colorOscuro.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                final (icono, texto) = _items[i];
                final activo = i == indice;
                return Expanded(
                  flex: activo ? 6 : 3,
                  child: Semantics(
                    button: true,
                    selected: activo,
                    label: texto,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: activo ? Tema.degradadoDorado : null,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: activo
                              ? [
                                  BoxShadow(
                                    color: Config.colorAcento
                                        .withValues(alpha: 0.45),
                                    blurRadius: 16,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icono,
                              size: 24,
                              color: activo
                                  ? Config.colorOscuro
                                  : Colors.white.withValues(alpha: 0.55),
                            ),
                            if (activo) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  texto,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: const TextStyle(
                                    color: Config.colorOscuro,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

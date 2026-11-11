import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'config.dart';

/// Estilo visual de toda la app.
class Tema {
  static const fondoClaro = Color(0xFFF3F4FA);

  static const degradadoDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Config.colorAmarillo, Config.colorAcento, Color(0xFFE07B00)],
  );

  static const degradadoAzul = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF231BB0), Config.colorPrincipal, Config.colorOscuro],
    stops: [0.0, 0.45, 1.0],
  );

  static List<BoxShadow> sombraSuave = [
    BoxShadow(
      color: Config.colorPrincipal.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData claro() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Config.colorPrincipal,
        primary: Config.colorPrincipal,
        secondary: Config.colorAcento,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: fondoClaro,
    );

    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
    );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        border: borde,
        enabledBorder: borde,
        focusedBorder: borde.copyWith(
          borderSide: const BorderSide(color: Config.colorAcento, width: 2),
        ),
        errorBorder: borde.copyWith(
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIconColor: Config.colorPrincipal.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Config.colorOscuro,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle:
            const TextStyle(fontFamily: 'Poppins', color: Colors.white),
      ),
    );
  }
}

/// Fondo azul del logo con rayos de sol dorados.
class FondoAzul extends StatelessWidget {
  const FondoAzul({
    super.key,
    required this.child,
    this.giro,
    this.centroRayos = const Alignment(0, -0.45),
    this.borderRadius,
  });

  final Widget child;
  final Animation<double>? giro;
  final Alignment centroRayos;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget rayos(double t) => CustomPaint(
          painter: RayosPainter(t: t, centro: centroRayos),
        );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: Tema.degradadoAzul),
        child: Stack(
          children: [
            Positioned.fill(
              child: giro == null
                  ? rayos(0)
                  : AnimatedBuilder(
                      animation: giro!,
                      builder: (_, __) => rayos(giro!.value),
                    ),
            ),
            // Brillo dorado suave detrás del contenido.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: centroRayos,
                    radius: 0.9,
                    colors: [
                      Config.colorAcento.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class RayosPainter extends CustomPainter {
  RayosPainter({required this.t, required this.centro});
  final double t;
  final Alignment centro;

  @override
  void paint(Canvas canvas, Size size) {
    final c = centro.alongSize(size);
    final largo = size.longestSide * 1.2;
    const n = 28;
    final giro = t * 2 * math.pi / n * 3;

    final pincel = Paint()
      ..shader = RadialGradient(
        colors: [
          Config.colorAmarillo.withValues(alpha: 0.20),
          Config.colorAcento.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: largo * 0.6));

    for (var i = 0; i < n; i++) {
      final a = giro + i * 2 * math.pi / n;
      final ancho = i.isEven ? 0.045 : 0.025;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + largo * math.cos(a - ancho),
            c.dy + largo * math.sin(a - ancho))
        ..lineTo(c.dx + largo * math.cos(a + ancho),
            c.dy + largo * math.sin(a + ancho))
        ..close();
      canvas.drawPath(path, pincel);
    }
  }

  @override
  bool shouldRepaint(RayosPainter old) => old.t != t || old.centro != centro;
}

/// Tarjeta con efecto de vidrio esmerilado (para fondos oscuros).
class Vidrio extends StatelessWidget {
  const Vidrio({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radio = 28,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radio),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tarjeta blanca con sombra suave (para fondos claros).
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Tema.sombraSuave,
      ),
      child: child,
    );
  }
}

/// Logo dentro de un círculo blanco con anillo dorado.
class LogoCircular extends StatelessWidget {
  const LogoCircular({super.key, required this.tamano, this.giro});
  final double tamano;
  final double? giro;

  @override
  Widget build(BuildContext context) {
    final anillo = tamano * 0.035;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Config.colorAcento.withValues(alpha: 0.45),
            blurRadius: tamano * 0.25,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Anillo dorado (gira cuando suena la radio).
          Transform.rotate(
            angle: (giro ?? 0) * 2 * math.pi,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Config.colorAmarillo,
                    Config.colorAcento,
                    Color(0xFFFFF1B8),
                    Config.colorAcento,
                    Config.colorAmarillo,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(anillo),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(tamano * 0.055),
              child: Image.asset(Config.rutaLogo, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

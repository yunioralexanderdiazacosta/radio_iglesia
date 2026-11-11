# Excelencia 100.1 — App de la Iglesia Pentecostés Impacto de Avivamiento

Proyecto Flutter completo. Tiene tres pantallas:
- **Radio:** reproductor en vivo que sigue sonando en segundo plano, con controles en la pantalla de bloqueo, "sonando ahora" y reconexión automática.
- **Oración:** formulario que abre WhatsApp (+58 414-997-1293) con el pedido ya escrito.
- **Nosotros:** dirección (abre Google Maps), horarios, WhatsApp y redes sociales.

## Contenido

```
radio_iglesia/
├── pubspec.yaml               ← dependencias
├── lib/
│   ├── config.dart            ← ★ AQUÍ se cambian todos los datos de la iglesia
│   ├── main.dart              ← arranque y menú inferior
│   ├── services/radio_service.dart
│   └── screens/
│       ├── radio_screen.dart
│       ├── oracion_screen.dart
│       └── nosotros_screen.dart
├── android/                   ← proyecto Android completo (permisos, ícono, audio en 2º plano)
├── ios/Runner/Info.plist      ← configuración de iPhone (ver sección iPhone)
└── assets/icono_app.png       ← ícono en alta resolución (1024×1024)
```

## 1. Instalar lo necesario (una sola vez)

1. **Flutter:** https://docs.flutter.dev/get-started/install. Elige tu sistema (Windows, Mac o Linux) y luego "Android".
2. **Android Studio:** lo pide la misma guía, porque trae el SDK de Android.
3. En una terminal ejecuta `flutter doctor` y sigue lo que indique hasta que Android salga con ✓.

## 2. Abrir y ejecutar

1. Descomprime el zip.
2. Abre una terminal dentro de la carpeta `radio_iglesia`.
3. Ejecuta:

```bash
flutter pub get
flutter run
```

Ten el teléfono Android conectado por USB con la **Depuración USB** activada (Ajustes → Acerca del teléfono → toca 7 veces "Número de compilación" → Opciones de desarrollador → Depuración USB).

La primera vez tarda varios minutos, porque descarga Gradle y las librerías.

**Si aparece un error de archivos faltantes**, ejecuta esto dentro de la carpeta. Completa lo que falte sin tocar tu código:

```bash
flutter create --org com.impactodeavivamiento --project-name radio_iglesia --platforms=android .
```

## 3. Comprobar que todo funciona

- [ ] Al tocar ▶ suena la radio.
- [ ] Con la pantalla apagada sigue sonando, y hay controles en la pantalla de bloqueo.
- [ ] En **Oración**, al llenar el formulario y tocar "Enviar por WhatsApp", se abre el chat con +58 414-997-1293 y el mensaje ya escrito.
- [ ] En **Nosotros**, la dirección abre Google Maps.

## 4. Generar la app para instalar o publicar

```bash
flutter build apk --release        # APK para instalar directo o compartir por WhatsApp
flutter build appbundle --release  # .aab para subir a Google Play
```

Los archivos quedan en `build/app/outputs/flutter-apk/app-release.apk` y en `build/app/outputs/bundle/release/app-release.aab`.

### Firma para Google Play

Google Play exige firmar la app con una llave propia. Sigue la guía oficial: https://docs.flutter.dev/deployment/android#sign-the-app

**Guarda esa llave y su contraseña en un lugar seguro.** Si se pierden, no podrás actualizar la app en Google Play.

## iPhone (opcional)

Necesitas una Mac con Xcode y una cuenta de Apple Developer (99 USD al año). En la Mac, dentro de la carpeta, ejecuta:

```bash
flutter create --org com.impactodeavivamiento --project-name radio_iglesia --platforms=ios .
flutter run
```

Ese comando genera los archivos de iOS y **conserva** el `Info.plist` incluido, que ya trae el audio en segundo plano y el permiso para abrir WhatsApp. Después, en Xcode, agrega la capacidad *Background Modes → Audio*.

## Cambiar datos

Todo está en **`lib/config.dart`**: nombre, URL de la radio, número de WhatsApp, dirección, horarios, redes sociales y colores.

Si en el futuro cambias la URL de la radio o el número, solo editas ese archivo y vuelves a generar la app.

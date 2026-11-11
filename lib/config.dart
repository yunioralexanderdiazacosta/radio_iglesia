import 'package:flutter/material.dart';

/// ===============================================================
///  CONFIGURACIÓN DE LA IGLESIA
///  Cambia solo los valores de este archivo.
/// ===============================================================
class Config {
  /// Nombre que aparece en la app y en la notificación del reproductor.
  static const nombreIglesia = 'Iglesia Pentecostés Impacto de Avivamiento';
  static const nombreRadio = 'Excelencia 100.1';
  static const lema = 'Somos parte de tu vida'; // lema de la radio

  /// Lema y fundador de la iglesia (pantalla "Nosotros").
  static const lemaIglesia = 'El evangelio se expande';
  static const fundador = 'Ap. Manuel Delgado';

  /// URL DIRECTA del audio (no la página web). Ejemplos:
  ///   https://servidor.com:8000/stream
  ///   https://stream.zeno.fm/xxxxxxxx
  static const urlRadio = 'https://uk3freenew.listen2myradio.com/live.mp3?typeportmount=s1_6598_stream_256085054';

  /// Número de WhatsApp que recibe los pedidos de oración.
  /// Código de país + número, SIN "+", sin espacios y sin el 0 inicial.
  /// Venezuela: 0412-123-4567  ->  584121234567
  static const whatsappPedidos = '584149971293';

  /// Información de contacto (pantalla "Nosotros").
  static const direccion =
      'Calle La Esperanza, frente al Estacionamiento de la Torre Coffel, '
      'Maturín, Monagas, Venezuela';

  /// Texto que se busca en Google Maps al tocar "Cómo llegar".
  static const busquedaMapa = 'Impacto de Avivamiento';

  /// Horarios de servicio: (día, nombre del servicio, horas).
  static const horarios = [
    ('Lunes', 'Enseñanza Bíblica', ['9:00 am', '4:00 pm']),
    ('Martes', 'Oración', ['9:00 am']),
    ('Miércoles', 'Sanidad y Milagros', ['9:00 am', '4:00 pm', '6:00 pm']),
    ('Jueves', 'Llenura del Espíritu Santo', ['9:00 am', '4:00 pm']),
    ('Viernes', 'Liberación', ['9:00 am', '4:00 pm', '6:00 pm']),
    ('Sábado', 'Culto de Jóvenes', ['9:00 am']),
    ('Domingo', 'Milagros sin Límites', ['8:00 am', '11:00 am', '3:00 pm']),
  ];
  /// Donaciones por Pago Móvil (pantalla "Nosotros").
  static const pagoMovilBanco = '0102';
  static const pagoMovilNombreBanco = 'Banco de Venezuela';
  static const pagoMovilRif = 'J-400630142';
  static const pagoMovilTelefono = '04249261671';

  /// Redes sociales (deja el texto vacío '' para ocultar un botón).
  static const facebook = 'https://www.facebook.com/ApManuelDelgadoOficial';
  static const instagram = 'https://www.instagram.com/apmanueldelgadooficial';
  static const tiktok = 'https://www.tiktok.com/@apmanueldelgadooficial';
  static const youtube = 'https://www.youtube.com/@ap.manueldelgadooficial321';

  /// Colores de la app (tomados de los logos de la radio y la iglesia).
  static const colorPrincipal = Color(0xFF1530A8); // azul rey del logo
  static const colorOscuro = Color(0xFF060A33);    // azul noche (fondos)
  static const colorAcento = Color(0xFFF5A300);    // dorado
  static const colorAmarillo = Color(0xFFFFCB2F);  // amarillo
  static const colorCeleste = Color(0xFF4FC3F7);   // celeste
  static const colorRojo = Color(0xFFE5232C);      // rojo de la cinta
  static const colorVerde = Color(0xFF22B14C);     // verde del "100.1"

  /// Logo de la iglesia (pantalla "Nosotros").
  static const usarLogo = true;
  static const rutaLogo = 'assets/logo.jpg';

  /// Logo de la radio (pantalla principal).
  static const rutaLogoRadio = 'assets/logo_radio.png';
}

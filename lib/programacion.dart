// ===============================================================
//  PROGRAMACIÓN DE LA RADIO
//  Para agregar un programa, copia un bloque `Programa(...)` dentro
//  de la lista `programas` y cambia sus datos.
// ===============================================================

/// Días de la semana (igual que DateTime.weekday).
class Dia {
  static const lunes = 1;
  static const martes = 2;
  static const miercoles = 3;
  static const jueves = 4;
  static const viernes = 5;
  static const sabado = 6;
  static const domingo = 7;

  static const lunesASabado = [1, 2, 3, 4, 5, 6];
  static const todos = [1, 2, 3, 4, 5, 6, 7];

  static const nombres = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];
  static const cortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
}

/// Un horario en que sale al aire un programa.
/// Las horas van en formato de 24 horas: 19 = 7 pm, 24 = 12 am (medianoche).
class Horario {
  const Horario({
    required this.dias,
    required this.desde,
    required this.hasta,
    this.etiqueta = '',
    this.desdeMin = 0,
    this.hastaMin = 0,
  });

  final List<int> dias;
  final int desde; // hora de inicio (0-23)
  final int hasta; // hora de fin (1-24)
  final int desdeMin; // minutos, por si empieza ej. 7:30
  final int hastaMin;
  final String etiqueta; // ej: "Diurno", "Nocturno"

  int get inicio => desde * 60 + desdeMin; // minutos desde medianoche
  int get fin => hasta * 60 + hastaMin;
}

class Programa {
  const Programa({
    required this.nombre,
    required this.horarios,
    this.descripcion = '',
    this.conductor = '',
    this.imagen,
  });

  final String nombre;
  final String descripcion;
  final String conductor;

  /// Ruta de la imagen, ej: 'assets/programas/restaurando_vidas.jpg'.
  /// (También hay que agregarla en pubspec.yaml). null = imagen genérica.
  final String? imagen;

  final List<Horario> horarios;
}

// ---------------------------------------------------------------
//  LISTA DE PROGRAMAS
// ---------------------------------------------------------------
const programas = <Programa>[
  Programa(
    nombre: 'Restaurando Vidas',
    imagen: null, // pendiente: 'assets/programas/restaurando_vidas.jpg'
    horarios: [
      Horario(
          etiqueta: 'Diurno', dias: Dia.todos, desde: 10, hasta: 12),
      Horario(
          etiqueta: 'Nocturno',
          dias: Dia.lunesASabado,
          desde: 19,
          hasta: 24),
      Horario(
          etiqueta: 'Nocturno',
          dias: [Dia.domingo],
          desde: 19,
          hasta: 22),
    ],
  ),
];

// ---------------------------------------------------------------
//  Lógica (no hace falta tocar nada de aquí para abajo)
// ---------------------------------------------------------------

/// Una emisión concreta: un programa en un día y hora determinados.
class Emision {
  Emision(this.programa, this.horario, this.inicio, this.fin);
  final Programa programa;
  final Horario horario;
  final DateTime inicio;
  final DateTime fin;

  bool alAire(DateTime ahora) =>
      !ahora.isBefore(inicio) && ahora.isBefore(fin);

  /// Avance del programa en curso, de 0 a 1.
  double progreso(DateTime ahora) {
    final total = fin.difference(inicio).inSeconds;
    final pasado = ahora.difference(inicio).inSeconds;
    return total <= 0 ? 0 : (pasado / total).clamp(0.0, 1.0);
  }
}

class Programacion {
  /// Todas las emisiones de un día, ordenadas por hora.
  static List<Emision> delDia(DateTime dia) {
    final base = DateTime(dia.year, dia.month, dia.day);
    final lista = <Emision>[];
    for (final p in programas) {
      for (final h in p.horarios) {
        if (h.dias.contains(base.weekday)) {
          lista.add(Emision(
            p,
            h,
            base.add(Duration(minutes: h.inicio)),
            base.add(Duration(minutes: h.fin)),
          ));
        }
      }
    }
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// El programa al aire ahora, o si no hay, el próximo en comenzar.
  static Emision? actualOProxima(DateTime ahora) {
    // Se incluye ayer por si un programa cruza la medianoche.
    for (var d = -1; d <= 7; d++) {
      final dia = DateTime(ahora.year, ahora.month, ahora.day + d);
      for (final e in delDia(dia)) {
        if (ahora.isBefore(e.fin)) return e;
      }
    }
    return null;
  }

  /// "10:00 am", "7:30 pm", "12:00 am"
  static String hora(DateTime t) {
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h12:$m ${t.hour < 12 ? 'am' : 'pm'}';
  }

  static String rango(Emision e) => '${hora(e.inicio)} – ${hora(e.fin)}';

  /// "hoy", "mañana" o el nombre del día.
  static String cuando(DateTime t, DateTime ahora) {
    final a = DateTime(ahora.year, ahora.month, ahora.day);
    final b = DateTime(t.year, t.month, t.day);
    final dias = b.difference(a).inDays;
    if (dias == 0) return 'hoy';
    if (dias == 1) return 'mañana';
    return 'el ${Dia.nombres[t.weekday - 1].toLowerCase()}';
  }

  /// "2 h 15 min", "45 min"
  static String duracion(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m < 1 ? 1 : m} min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// "Lun a Sáb", "Todos los días", "Domingo", "Lun, Mié y Vie"
  static String dias(List<int> dias) {
    final d = [...dias]..sort();
    if (d.length == 7) return 'Todos los días';
    if (d.length == 1) return Dia.nombres[d.first - 1];
    final seguidos =
        List.generate(d.length - 1, (i) => d[i + 1] - d[i]).every((x) => x == 1);
    if (seguidos) {
      return '${Dia.cortos[d.first - 1]} a ${Dia.cortos[d.last - 1]}';
    }
    final n = d.map((x) => Dia.cortos[x - 1]).toList();
    return '${n.sublist(0, n.length - 1).join(', ')} y ${n.last}';
  }

  static String rangoHorario(Horario h) {
    final base = DateTime(2024);
    return '${hora(base.add(Duration(minutes: h.inicio)))} – '
        '${hora(base.add(Duration(minutes: h.fin)))}';
  }
}

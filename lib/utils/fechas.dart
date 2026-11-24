import 'package:intl/intl.dart';

String formatearFechaCompleta(DateTime fecha) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);
}

String formatearFechaCorta(String fecha) {
  DateTime fechaDateTime = DateTime.parse(fecha);
  return DateFormat('dd/MM/yyyy HH:mm').format(fechaDateTime);
}

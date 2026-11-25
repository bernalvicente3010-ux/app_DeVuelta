import 'dart:typed_data';

import 'package:image/image.dart' as img;

Uint8List? reducirFoto(Uint8List bytes, {int ladoMax = 1024}) {
  final imagen = img.decodeImage(bytes);

  if (imagen == null) {
    return null;
  }

  final ladoMayor = imagen.width > imagen.height ? imagen.width : imagen.height;

  img.Image resultado = imagen;
  if (ladoMayor > ladoMax) {
    final escala = ladoMax / ladoMayor;
    resultado = img.copyResize(
      imagen,
      width: (imagen.width * escala).round(),
      height: (imagen.height * escala).round(),
    );
  }

  Uint8List jpg = Uint8List.fromList(img.encodeJpg(resultado, quality: 85));

  if (jpg.length > 1024 * 1024) {
    jpg = Uint8List.fromList(img.encodeJpg(resultado, quality: 60));
  }

  if (jpg.length > 1024 * 1024) {
    return null;
  }
  return jpg;
}

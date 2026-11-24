import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:proy3/constants.dart';

class ObjetoCard extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String categoria;
  final String estado;
  final Uint8List? fotoData;
  final VoidCallback? onTap;

  const ObjetoCard({
    super.key,
    required this.titulo,
    required this.tipo,
    required this.categoria,
    required this.estado,
    this.fotoData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool esEncontrado = tipo == 'Encontrado';
    bool esDevuelto = estado == 'Devuelto';

    Color colorTipo = kTipoColor;
    Color fondoTipo = kTipoColorFondo;
    Color colorEstado = esDevuelto ? kSuccessColor : kWarningColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: fotoData != null
                ? Image.memory(
                    fotoData!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey.shade200,
                    child: Icon(
                      MdiIcons.imageOff,
                      size: 34,
                      color: Colors.grey,
                    ),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: fondoTipo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        esEncontrado
                            ? MdiIcons.magnify
                            : MdiIcons.mapMarkerQuestion,
                        size: 14,
                        color: colorTipo,
                      ),
                      SizedBox(width: 4),
                      Text(
                        ('OBJ. '),
                        style: TextStyle(
                          color: colorTipo,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tipo.toUpperCase(),
                        style: TextStyle(
                          color: colorTipo,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                if (categoria == 'Otros')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.tagOutline,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (categoria == 'Llaves')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.keyChainVariant,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (categoria == 'Ropa y accesorios')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.hanger,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (categoria == 'Documentos')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.cardAccountDetailsOutline,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (categoria == 'Útiles')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.pencilRulerOutline,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (categoria == 'Electrónica')
                  Row(
                    children: [
                      Icon(
                        MdiIcons.devices,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                Divider(height: 16),
                Row(
                  children: [
                    Icon(
                      esDevuelto
                          ? MdiIcons.checkboxMultipleMarkedCircle
                          : MdiIcons.alertCircle,
                      size: 16,
                      color: colorEstado,
                    ),
                    SizedBox(width: 4),
                    Text(
                      estado,
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(MdiIcons.chevronRight),
            tooltip: 'Ver detalle',
          ),
        ],
      ),
    );
  }
}

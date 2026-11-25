import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:proy3/constants.dart';
import 'package:proy3/services/auth_services.dart';
import 'package:proy3/services/objetos_services.dart';

class ObjetoDetallePage extends StatefulWidget {
  final String id;
  const ObjetoDetallePage({super.key, required this.id});

  @override
  State<ObjetoDetallePage> createState() => _ObjetoDetallePageState();
}

class _ObjetoDetallePageState extends State<ObjetoDetallePage> {
  final _service = ObjetosServices();
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.objeto(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Objeto')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final datos = snapshot.data?.data();
          if (!snapshot.hasData || datos == null) {
            return Center(child: Text('Publicación no encontrada'));
          }

          final objeto = datos;
          final foto = objeto['foto'];
          final Uint8List? bytes = foto is Blob ? foto.bytes : null;

          final tipo = objeto['tipo'] as String;
          final estado = objeto['estado'] as String;
          final esEncontrado = tipo == 'Encontrado';
          final colorEstado = estado == 'Devuelto'
              ? kSuccessColor
              : kWarningColor;

          final uid = AuthService.instance.currentUser?.uid;
          final autorId = objeto['autorId'] as String;
          final esMio = uid != null && autorId == uid;
          final vigente = estado == 'Vigente';

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Foto
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: bytes != null
                    ? Image.memory(
                        bytes,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 180,
                        child: Center(
                          child: Icon(
                            MdiIcons.imageOff,
                            size: 48,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 16),

              //titulo y autor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objeto['titulo'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kSecondaryColor,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          objeto['autorNombre'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Tipo y estado
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kTipoColorFondo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          esEncontrado
                              ? MdiIcons.magnify
                              : MdiIcons.mapMarkerQuestion,
                          size: 16,
                          color: kTipoColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          tipo.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: kTipoColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorEstado.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          estado == 'Devuelto'
                              ? MdiIcons.checkboxMultipleMarkedCircle
                              : MdiIcons.alertCircle,
                          size: 16,
                          color: colorEstado,
                        ),
                        SizedBox(width: 6),
                        Text(
                          estado,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorEstado,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Descripción
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      objeto['descripcion'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // Info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LUGAR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                objeto['lugar'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 10, color: Colors.grey.shade200),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FECHA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                objeto['fechaHora'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 10, color: Colors.grey.shade200),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CATEGORÍA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                objeto['categoria'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // borrar marcar devuelto
              if (esMio)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),

                  child: Row(
                    children: [
                      if (vigente)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _service.marcarDevuelto(widget.id);
                              if (!mounted) return;
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.check_circle_outline, size: 18),
                            label: Text(
                              'Marcar devuelto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSuccessColor,
                              foregroundColor: Colors.white,
                              minimumSize: Size(0, 48),
                            ),
                          ),
                        ),
                      if (vigente) SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: Text('Eliminar publicación'),
                                content: Text(
                                  '¿Estás seguro? Esta acción no se puede deshacer.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: Text('Eliminar'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: kErrorColor,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (!mounted || confirmar != true) return;

                            await _service.borrarObjeto(widget.id);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.delete_outline, size: 18),
                          label: Text(
                            'Eliminar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: kErrorColor,
                            minimumSize: Size(0, 48),
                            side: BorderSide(
                              color: kErrorColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

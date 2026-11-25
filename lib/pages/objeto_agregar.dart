import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proy3/services/auth_services.dart';
import 'package:proy3/services/objetos_services.dart';
import 'package:proy3/utils/imagen.dart';

class ObjetoAgregar extends StatefulWidget {
  const ObjetoAgregar({super.key});

  @override
  State<ObjetoAgregar> createState() => _ObjetoAgregarState();
}

class _ObjetoAgregarState extends State<ObjetoAgregar> {
  final formAgregar = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();

  String? tipoSeleccionado;
  String? categoriaSeleccionada;
  Uint8List? fotoBytes;

  bool guardando = false;
  bool seleccionandoFoto = false;
  Map<String, dynamic> errores = {};

  @override
  void dispose() {
    tituloCtrl.dispose();
    descCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(ImageSource source) async {
    if (seleccionandoFoto) return;

    seleccionandoFoto = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imagen == null) return;

      final bytesOriginales = await imagen.readAsBytes();
      final bytesComprimidos = reducirFoto(bytesOriginales);

      if (bytesComprimidos == null) {
        setState(() {
          errores['foto'] = [
            'No se pudo comprimir la imagen (supera 1 MB). Prueba con otra foto.',
          ];
        });
        return;
      }

      setState(() {
        fotoBytes = bytesComprimidos;
        errores.remove('foto');
      });
    } catch (e) {
      setState(() {
        errores['foto'] = ['No se pudo abrir el selector de imagen'];
      });
    } finally {
      seleccionandoFoto = false;
    }
  }

  Future<void> _publicar() async {
    if (guardando) return;

    if (!formAgregar.currentState!.validate()) {
      return;
    }

    if (fotoBytes == null) {
      setState(() {
        errores['foto'] = ['Debe incluir una foto del objeto'];
      });
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      var currentUser = AuthService.instance.currentUser;

      await ObjetosServices().agregarObjeto(
        titulo: tituloCtrl.text.trim(),
        descripcion: descCtrl.text.trim(),
        tipo: tipoSeleccionado!,
        categoria: categoriaSeleccionada!,
        lugar: lugarCtrl.text.trim(),
        fechaHora: DateTime.now(),
        foto: fotoBytes!,
        autorId: currentUser?.uid ?? '',
        autorNombre: currentUser?.displayName ?? 'Usuario',
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errores['foto'] = ['Error al guardar: $e'];
      });
    } finally {
      guardando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text('Publicar Objeto ')]),
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          key: formAgregar,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // aca el titulo
                      TextFormField(
                        controller: tituloCtrl,
                        decoration: InputDecoration(
                          labelText: 'Título del objeto',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indique el título del objeto';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),

                      // aca descripción
                      TextFormField(
                        controller: descCtrl,
                        decoration: InputDecoration(labelText: 'Descripción'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indique la descripción del objeto';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),

                      // aca tipo
                      DropdownButtonFormField<String>(
                        initialValue: tipoSeleccionado,
                        decoration: InputDecoration(labelText: 'Tipo'),
                        items: [
                          DropdownMenuItem(
                            value: 'Perdido',
                            child: Text('Perdido'),
                          ),
                          DropdownMenuItem(
                            value: 'Encontrado',
                            child: Text('Encontrado'),
                          ),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            tipoSeleccionado = valor;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione un tipo';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),

                      // sacamos categoria desde firestore
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: ObjetosServices().categorias(),
                        builder: (context, snapshot) {
                          var items = <DropdownMenuItem<String>>[];

                          if (snapshot.hasData) {
                            items = snapshot.data!.docs.map((doc) {
                              var nombre =
                                  doc.data()['nombre'] as String? ?? doc.id;
                              return DropdownMenuItem(
                                value: nombre,
                                child: Text(nombre),
                              );
                            }).toList();
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: categoriaSeleccionada,
                            decoration: InputDecoration(labelText: 'Categoría'),
                            isExpanded: true,
                            menuMaxHeight: 250,
                            items: items,
                            onChanged: (valor) {
                              setState(() {
                                categoriaSeleccionada = valor;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Seleccione una categoría';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 10),

                      // aca el lugar
                      TextFormField(
                        controller: lugarCtrl,
                        decoration: InputDecoration(
                          labelText: 'Lugar del campus',
                          hintText: 'Ej: Laboratorio U100',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indique el lugar del campus';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // aca la foto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto del objeto (Obligatoria):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _seleccionarFoto(ImageSource.gallery),
                                  icon: Icon(MdiIcons.image),
                                  label: Text('Galería'),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _seleccionarFoto(ImageSource.camera),
                                  icon: Icon(MdiIcons.camera),
                                  label: Text('Foto'),
                                ),
                              ),
                            ],
                          ),
                          if (fotoBytes != null)
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.memory(
                                fotoBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (errores['foto'] != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                errores['foto'][0],
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30, top: 10),
                width: double.infinity,
                child: FilledButton(
                  onPressed: guardando ? null : _publicar,
                  child: guardando
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

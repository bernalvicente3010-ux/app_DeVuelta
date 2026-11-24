import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proy3/constants.dart';
import 'package:proy3/pages/tabs/tab_misobjetos.dart';
import 'package:proy3/pages/tabs/tab_objetos.dart';
import 'package:proy3/services/auth_services.dart';
import 'package:proy3/services/objetos_services.dart';
import 'package:proy3/utils/imagen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaSeleccionada = 0;
  final List<Widget> paginas = [TabObjetos(), TabMisobjetos()];

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

  void _limpiarForm() {
    tituloCtrl.clear();
    descCtrl.clear();
    lugarCtrl.clear();
    tipoSeleccionado = null;
    categoriaSeleccionada = null;
    fotoBytes = null;
    errores = {};
    guardando = false;
    seleccionandoFoto = false;
  }

  Future<void> _signOut() async {
    bool? confirmado = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await AuthService.instance.signOut();
  }

  Future<void> _seleccionarFoto(
    StateSetter setDialogState,
    ImageSource source,
  ) async {
    if (seleccionandoFoto) return;

    seleccionandoFoto = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(source: source);

      if (imagen == null) return;

      final bytesOriginales = await imagen.readAsBytes();
      final bytesComprimidos = reducirFoto(bytesOriginales);

      if (bytesComprimidos == null) {
        setDialogState(() {
          errores['foto'] = [
            'No se pudo comprimir la imagen (supera 1 MB). Prueba con otra foto.',
          ];
        });
        return;
      }

      setDialogState(() {
        fotoBytes = bytesComprimidos;
        errores.remove('foto');
      });
    } catch (e) {
      setDialogState(() {
        errores['foto'] = ['No se pudo abrir el selector de imagen'];
      });
    } finally {
      seleccionandoFoto = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Bienvenido '),
            Text(
              user?.displayName ?? 'Usuario',
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: Icon(MdiIcons.powerStandby),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: paginas[paginaSeleccionada],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextColor,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) => StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  backgroundColor: Colors.white,
                  title: Text(
                    'Publicar Objeto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  content: Form(
                    key: formAgregar,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 1),

                          // aca descripción
                          TextFormField(
                            controller: descCtrl,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Indique la descripción del objeto';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 1),

                          // aca tipo
                          DropdownButtonFormField<String>(
                            value: tipoSeleccionado,
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
                              setDialogState(() {
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
                          SizedBox(height: 1),

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
                                value: categoriaSeleccionada,
                                decoration: InputDecoration(
                                  labelText: 'Categoría',
                                ),
                                isExpanded: true,
                                menuMaxHeight: 250,
                                items: items,
                                onChanged: (valor) {
                                  setDialogState(() {
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
                          SizedBox(height: 1),

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
                          SizedBox(height: 1),

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
                                      onPressed: () => _seleccionarFoto(
                                        setDialogState,
                                        ImageSource.gallery,
                                      ),
                                      icon: Icon(MdiIcons.image),
                                      label: Text('Galería'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _seleccionarFoto(
                                        setDialogState,
                                        ImageSource.camera,
                                      ),
                                      icon: Icon(MdiIcons.camera),
                                      label: Text('Foto'),
                                    ),
                                  ),
                                ],
                              ),
                              if (fotoBytes != null)
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  height: 100,
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
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (guardando) return;

                        if (!formAgregar.currentState!.validate()) {
                          return;
                        }

                        if (fotoBytes == null) {
                          setDialogState(() {
                            errores['foto'] = [
                              'Debe incluir una foto del objeto',
                            ];
                          });
                          return;
                        }

                        setDialogState(() {
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

                          if (!mounted || !dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        } catch (e) {
                          if (!mounted || !dialogContext.mounted) return;
                          setDialogState(() {
                            errores['foto'] = ['Error al guardar: $e'];
                          });
                        } finally {
                          guardando = false;
                        }
                      },
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
                  ],
                );
              },
            ),
          ).then((_) {
            if (!mounted) return;
            _limpiarForm();
          });
        },
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: kPrimaryColor,
          indicatorColor: Colors.white,
        ),
        child: NavigationBar(
          selectedIndex: paginaSeleccionada,
          onDestinationSelected: (index) {
            setState(() {
              paginaSeleccionada = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Objetos perdidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Mis objetos',
              selectedIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}

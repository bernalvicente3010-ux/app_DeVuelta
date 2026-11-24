import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proy3/utils/fechas.dart';

class ObjetosServices {
  final FirebaseFirestore _api = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _objetos =>
      _api.collection('objetos');

  //OBJETOS PERDIDOS
  Stream<QuerySnapshot<Map<String, dynamic>>> objetos() {
    return _objetos.orderBy('creadoEn', descending: true).snapshots();
  }

  //MIS OBJETOS
  Stream<QuerySnapshot<Map<String, dynamic>>> misObjetos(String uid) {
    return _objetos
        .where('autorId', isEqualTo: uid)
        .orderBy('creadoEn', descending: true)
        .snapshots();
  }

  //OBTENERCATEGORIAS
  Stream<QuerySnapshot<Map<String, dynamic>>> categorias() {
    return _api.collection('categorias').snapshots();
  }

  //OBJETOS POR ID
  Future<DocumentSnapshot<Map<String, dynamic>>> objeto(String id) {
    return _objetos.doc(id).get();
  }

  //AGREGAR OBJETO
  Future<DocumentReference<Map<String, dynamic>>> agregarObjeto({
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fechaHora, // ← DateTime, no String
    required Uint8List foto,
    required String autorId,
    required String autorNombre,
  }) {
    return _objetos.add({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fechaHora': formatearFechaCompleta(fechaHora), // ← se formatea aquí
      'creadoEn': FieldValue.serverTimestamp(),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorId': autorId,
      'autorNombre': autorNombre,
    });
  }

  //DEVOLVER OBJETO
  Future<void> marcarDevuelto(String id) {
    return _objetos.doc(id).update({'estado': 'Devuelto'});
  }

  //BORRAR OBJETO
  Future<void> borrarObjeto(String id) {
    return _objetos.doc(id).delete();
  }
}

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proy3/pages/objeto_detalle_page.dart';
import 'package:proy3/services/auth_services.dart';
import 'package:proy3/services/objetos_services.dart';
import 'package:proy3/widgets/objeto_card.dart';

class TabMisobjetos extends StatefulWidget {
  const TabMisobjetos({super.key});

  @override
  State<TabMisobjetos> createState() => _TabMisobjetosState();
}

class _TabMisobjetosState extends State<TabMisobjetos> {
  final _service = ObjetosServices();

  @override
  Widget build(BuildContext context) {
    var uid = AuthService.instance.currentUser?.uid;

    if (uid == null) {
      return Center(child: Text('Iniciá sesión para ver tus publicaciones'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.misObjetos(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var publicaciones = snapshot.data?.docs ?? [];
        if (publicaciones.isEmpty) {
          return Center(child: Text('Todavía no publicaste objetos'));
        }

        return ListView.separated(
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) => Divider(),
          itemCount: publicaciones.length,
          itemBuilder: (context, index) {
            final publicacion = publicaciones[index];
            final objeto = publicacion.data();
            final foto = objeto['foto'];

            final Uint8List? bytes = foto is Blob ? foto.bytes : null;

            return ObjetoCard(
              titulo: objeto['titulo'],
              tipo: objeto['tipo'],
              categoria: objeto['categoria'],
              estado: objeto['estado'],
              fotoData: bytes,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ObjetoDetallePage(id: publicacion.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

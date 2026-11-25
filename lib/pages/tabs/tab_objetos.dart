import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proy3/pages/objeto_detalle_page.dart';
import 'package:proy3/services/objetos_services.dart';
import 'package:proy3/widgets/objeto_card.dart';

class TabObjetos extends StatefulWidget {
  const TabObjetos({super.key});

  @override
  State<TabObjetos> createState() => _TabObjetosState();
}

class _TabObjetosState extends State<TabObjetos> {
  final _service = ObjetosServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.objetos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var publicaciones = snapshot.data?.docs ?? [];
        if (publicaciones.isEmpty) {
          return Center(child: Text('No hay publicaciones todavía'));
        }

        return ListView.separated(
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) => Divider(),
          itemCount: publicaciones.length,
          itemBuilder: (context, index) {
            //**
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

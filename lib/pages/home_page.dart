import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:proy3/constants.dart';
import 'package:proy3/pages/objeto_agregar.dart';
import 'package:proy3/pages/tabs/tab_misobjetos.dart';
import 'package:proy3/pages/tabs/tab_objetos.dart';
import 'package:proy3/services/auth_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaSeleccionada = 0;
  final List<Widget> paginas = [TabObjetos(), TabMisobjetos()];

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
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ObjetoAgregar()),
          );
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

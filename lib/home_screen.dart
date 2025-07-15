import 'dart:convert'; // Para base64Decode
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Visitantes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('visitas')
            .orderBy('hora', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final visitas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: visitas.length,
            itemBuilder: (context, index) {
              final visita = visitas[index];
              final data = visita.data() as Map<String, dynamic>;

              Widget avatar;

              if (data['foto_base64'] != null && data['foto_base64'].toString().isNotEmpty) {
                try {
                  final decodedBytes = base64Decode(data['foto_base64']);
                  avatar = CircleAvatar(
                    backgroundImage: MemoryImage(decodedBytes),
                  );
                } catch (e) {
                  avatar = CircleAvatar(child: Icon(Icons.person));
                }
              } else {
                avatar = CircleAvatar(child: Icon(Icons.person));
              }

              return ListTile(
                leading: avatar,
                title: Text(data['nombre'] ?? ''),
                subtitle: Text(
                  '${data['motivo'] ?? ''}\n${data['hora'] != null ? (data['hora'] as Timestamp).toDate() : ''}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'dart:io' show File;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AddVisitaScreen extends StatefulWidget {
  const AddVisitaScreen({super.key});

  @override
  State<AddVisitaScreen> createState() => AddVisitaScreenState();
}

class AddVisitaScreenState extends State<AddVisitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _motivoController = TextEditingController();
  DateTime _hora = DateTime.now();

  File? _imageFile;         // Solo móvil
  Uint8List? _webImage;     // Solo web
  String? _imageBase64;

  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);

      if (base64String.length > 900000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen demasiado grande, intenta otra.')),
        );
        return;
      }

      setState(() {
        _webImage = bytes;
        _imageFile = null;
        _imageBase64 = base64String;
      });
    } else {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      if (base64String.length > 900000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen demasiado grande, intenta otra.')),
        );
        return;
      }

      setState(() {
        _imageFile = file;
        _webImage = null;
        _imageBase64 = base64String;
      });
    }
  }

  Future<void> _guardarVisita() async {
    if (!_formKey.currentState!.validate()) {
      logger.i('Formulario inválido');
      return;
    }

    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('visitas').add({
        'nombre': _nombreController.text.trim(),
        'motivo': _motivoController.text.trim(),
        'hora': Timestamp.fromDate(_hora),
        'foto_base64': _imageBase64!,
      });
      logger.i('Visita guardada correctamente');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      logger.e('Error al guardar visita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar visita: $e')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _hora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_hora),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _hora = newDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Visitante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              Text('Fecha y hora seleccionadas: ${_hora.toLocal()}'),
              ElevatedButton(
                onPressed: _selectDateTime,
                child: const Text('Seleccionar Fecha y Hora'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _getImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
              ),
              const SizedBox(height: 10),

              // Mostrar imagen seleccionada
              if (kIsWeb && _webImage != null)
                Image.memory(_webImage!, height: 200, fit: BoxFit.cover),
              if (!kIsWeb && _imageFile != null)
                Image.file(_imageFile!, height: 200, fit: BoxFit.cover),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarVisita,
                child: const Text('Guardar Visita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

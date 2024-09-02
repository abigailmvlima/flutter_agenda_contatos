import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key, required this.contact});

  final Contact? contact;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

typedef PopInvokedWithResultCallback<T> = void Function(bool, T);

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();


  late bool _userEdited = false;

  late Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact.empty();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name.isNotEmpty ? _editedContact.name : "Novo Contato"),
            centerTitle: true,
            leading: IconButton( // Botão de voltar personalizado
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _requestPop(true, null);
              },
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if(_editedContact.name != null && _editedContact.name.isNotEmpty){
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
              //Ação do botão salvar aqui
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.save),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: (_editedContact.img.isNotEmpty)
                            ? FileImage(File(_editedContact.img))
                            : const AssetImage("images/person.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Ação ao tocar na imagem
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: "Nome"),
                  onChanged: (text){
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                ),

                // Outros widgets da página aqui
              ],
            ),
          ),
        ),
    );
  }


  void _requestPop(bool didPop, dynamic result) async {
    if (_userEdited) {
      bool? shouldPop = await _showDiscardChangesDialog();

      if (shouldPop == true) {
       Navigator.of(context).pop(true); // Sair e descartar alterações
      }
    } else {
      Navigator.of(context).pop(true);  // Apenas sair
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Descartar Alterações"),
          content: const Text("Se sair, as alterações serão perdidas."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Não sair
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Sair e descartar alterações
              },
              child: const Text("Sim"),
            ),
          ],
        );
      },
    );
  }
}

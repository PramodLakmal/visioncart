import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';  // Add this import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemFormPage extends StatefulWidget {
  final ItemModel? item;

  const ItemFormPage({super.key, this.item});

  @override
  _ItemFormPageState createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  Uint8List? _imageBytes;
  final picker = ImagePicker();

  final Color lightBlue = const Color.fromRGBO(33, 150, 243, 1);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(text: widget.item?.description);
    _priceController = TextEditingController(text: widget.item?.price?.toString());
    _quantityController = TextEditingController(text: widget.item?.quantity?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return null;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('item_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await snapshot.ref.getDownloadURL();

      print('Firebase image URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? imageUrl;

      if (_imageBytes != null) {
        imageUrl = await _uploadImage(_imageBytes!);
      }

      try {
        if (widget.item == null) {
          await FirebaseFirestore.instance.collection('items').add({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'price': double.parse(_priceController.text),
            'quantity': double.parse(_quantityController.text),
            'imageUrl': imageUrl,
          });
        } else {
          await FirebaseFirestore.instance.collection('items').doc(widget.item!.id).update({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'price': double.parse(_priceController.text),
            'quantity': double.parse(_quantityController.text),
            if (imageUrl != null) 'imageUrl': imageUrl,
          });
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? "Add Item" : "Edit Item"),
        backgroundColor: lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, 'Item Name', Icons.shopping_bag),
                _buildTextField(_descriptionController, 'Description', Icons.description),
                _buildTextField(_priceController, 'Price', Icons.attach_money, isNumber: true),
                _buildTextField(_quantityController, 'Quantity', Icons.inventory, isNumber: true),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.item == null ? "Add Item" : "Update Item",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: lightBlue),
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isNumber && double.tryParse(value) == null) return 'Please enter a valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(_imageBytes!, height: 200, width: 200, fit: BoxFit.cover),
          )
        else
          const Text('No image selected'),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(_imageBytes == null ? Icons.add_photo_alternate : Icons.edit, color: Colors.white),
          label: Text(_imageBytes == null ? 'Add Image' : 'Change Image', style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

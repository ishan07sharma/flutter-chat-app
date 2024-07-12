import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key,required this.onpickimage});
  final void Function(File?) onpickimage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedimage;
  void _pickimage()async{
    final result=await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 50,maxWidth: 150);
    if(result!=null){
      setState(() {
        _pickedimage=File(result.path);
      });
      widget.onpickimage(_pickedimage);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:_pickedimage!=null?FileImage(_pickedimage!):null,
        ),
        TextButton.icon(
            onPressed: _pickimage,
            icon: const Icon(Icons.image),
            label: Text(
              'Add image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}

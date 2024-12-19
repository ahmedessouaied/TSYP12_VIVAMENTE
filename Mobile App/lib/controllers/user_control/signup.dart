import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:http/http.dart' as http;
import '../../structures/structs.dart' as structs;

import '../../bottom_navbar.dart';
import '../../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  String? _selectedGender;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode('216');

  Future<void> _pickImage() async {
    await _checkPermission();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<String?> _uploadImage() async {
    await _checkPermission();
    if (_selectedImage != null) {
      try {
        final imageBytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(imageBytes);

        // Upload image to Imgur
        final imageUploadResponse = await http.post(
          Uri.parse('https://api.imgur.com/3/image'),
          headers: {
            'Authorization': 'Client-ID 9f9ec81a2a40523',
          },
          body: {
            'image': base64Image,
            'type': 'base64',
          },
        );

        if (imageUploadResponse.statusCode != 200) {
          throw Exception('Failed to upload image');
        }

        final imageUploadJson = jsonDecode(imageUploadResponse.body);
        final imageUrl = imageUploadJson['data']['link'];

        return imageUrl;
      } catch (e) {
        if(mounted) showSnackBar(context, 'Error occurred while uploading the image: $e');
      }
    }
    return null;
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        showSnackBar(context, "Passwords do not match!");
        return;
      }
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          String? profileImageUrl = await _uploadImage();

          String phoneNumber = '+${_selectedDialogCountry.phoneCode}${_phoneNumberController.text}';

          structs.User newUser = structs.User(
            uid: user.uid,
            displayName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            firstName: _firstNameController.text.trim().capitalize(),
            middleName: _middleNameController.text.trim().capitalize(),
            lastName: _lastNameController.text.trim().capitalize(),
            email: _emailController.text.trim(),
            phoneNumber: phoneNumber,
            birthdate: _selectedDate ?? DateTime(2000, 1, 1),
            gender: _selectedGender ?? 'Other',
            createdAt: DateTime.now(), // or use FieldValue.serverTimestamp() in toFirestore
            profileImage: profileImageUrl ?? "",
          );

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toFirestore());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavbar()),
          );
        }
      } on FirebaseAuthException catch (e) {
        showSnackBar(context, e.message ?? "Error occurred during signup.");
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _openCountryPickerDialog() => showDialog(
    context: context,
    builder: (dialogContext) => Theme(
      data: Theme.of(context),
      child: CountryPickerDialog(
        titlePadding: const EdgeInsets.all(8.0),
        searchInputDecoration: const InputDecoration(hintText: 'Search...'),
        isSearchable: true,
        title: const Text('Select your phone code', style: TextStyle(fontSize: 18)),
        onValuePicked: (Country country) => setState(() => _selectedDialogCountry = country),
        itemFilter: (c) => 'IL' != c.isoCode,
        itemBuilder: buildCupertinoSelectedItem,
        priorityList: [
          CountryPickerUtils.getCountryByIsoCode('TN'),
          CountryPickerUtils.getCountryByIsoCode('DZ'),
          CountryPickerUtils.getCountryByIsoCode('MA'),
          CountryPickerUtils.getCountryByIsoCode('LY'),
          CountryPickerUtils.getCountryByIsoCode('PS'),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sign Up", style: theme.textTheme.titleMedium),
          foregroundColor: theme.textTheme.titleMedium?.color,
          backgroundColor: const Color.fromARGB(49, 68, 138, 255),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Create an Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _middleNameController,
                  decoration: InputDecoration(
                    labelText: 'Middle Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please confirm your password' : null,
                ),
                const SizedBox(height: 20),
                buildPhoneNumberField(_phoneNumberController, _selectedDialogCountry, _openCountryPickerDialog),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Birthdate',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Select your birthdate'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _signup,
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text('Sign Up',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${substring(0, 1).toUpperCase()}${substring(1).toLowerCase()}';
  }
}
import 'dart:io';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../structures/structs.dart' as structs;
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('216');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  //final TextEditingController _smsCodeController = TextEditingController();

  User? user;
  structs.User? samsarUser;
  File? _imageFile;
  AuthCredential? credential;
 // String? _verificationId;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user?.displayName ?? "";
      _emailController.text = user?.email ?? "";
      credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _passwordController.text,
      );
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final DocumentSnapshot snapshot =
          await db.collection('users').doc(user!.uid).get();
      if (mounted) {
        setState(() {
          samsarUser = structs.User.fromFirestore(snapshot);
          _middleNameController.text = samsarUser?.middleName ?? "";
          _lastNameController.text = samsarUser?.lastName ?? "";
          _phoneNumberController.text = samsarUser?.phoneNumber ?? "";
        });
      }
    }
  }

  Future<void> _updatePhoneNumber() async {
    if (!await _reauthenticateUser()) {
      if (mounted) showSnackBar(context, "Failed to reauthenticate user");
      return;
    }

    final phoneNumber = '+${_selectedDialogCountry.phoneCode}${_phoneNumberController.text}';

    try {
      await simpleUpdatePhoneNumber(phoneNumber);
    } catch (e) {
      if (mounted) showSnackBar(context, '${"Error"}: $e');
    }
  }

  Future<void> simpleUpdatePhoneNumber(String phoneNumber) async {
    try {
      await db.collection('users').doc(user!.uid).update({
        'phoneNumber': phoneNumber,
      });
      if (mounted) showSnackBar(context, "Phone number updated successfully");
    } catch (e) {
      if (mounted) showSnackBar(context, 'Error updating number: $e');
    }
  }

  /*
  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        await _updatePhoneNumberWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) showSnackBar(context, "Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        _showSmsCodeDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _showSmsCodeDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter SMS Code'),
          content: TextField(
            controller: _smsCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter the 6-digit code"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Verify'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _verifySmsCode();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePhoneNumberWithCredential(PhoneAuthCredential credential) async {
    try {
      await user!.updatePhoneNumber(credential);

      // Update phone number in Firestore
      await db.collection('users').doc(user!.uid).update({
        'phoneNumber': user!.phoneNumber,
      });

      if (mounted) showSnackBar(context, "Phone number updated successfully");
    } catch (e) {
      if (mounted) showSnackBar(context, "Error updating phone number: $e");
    }
  }


  Future<void> _verifySmsCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text,
      );
      await _updatePhoneNumberWithCredential(credential);
    } catch (e) {
      if (mounted) showSnackBar(context, "Error verifying SMS code: $e");
    }
  }
  */


  Future<void> _updateProfile() async {

    bool reauthenticated = await _reauthenticateUser();
    if (!reauthenticated) {
      if (mounted) showSnackBar(context, "Wrong password");
      return;
    }

    try {

      if (_nameController.text != user!.displayName) {
        await user!.updateDisplayName(_nameController.text);
      }
      if (_emailController.text != user!.email) {
        await user!.verifyBeforeUpdateEmail(_emailController.text);
      }
      if (user != null && user!.phoneNumber != _phoneNumberController.text) {
        _updatePhoneNumber();
      }

      await db.collection('users').doc(user!.uid).set({
        'displayName': _nameController.text + _lastNameController.text,
        'firstName': _nameController.text,
        'middleName': _middleNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
      }, SetOptions(merge: true));

      // Optionally reload user data
      await user!.reload();
      setState(() {
        user = _auth.currentUser;
      });

      if (mounted) showSnackBar(context, "Profile updated successfully");

    } catch (e) {
      if (mounted) showSnackBar(context, "Error updating profile: $e");
    }
  }

  Future<void> _updatePassword() async {
    bool reauthenticated = await _reauthenticateUser();

    if (!reauthenticated) {
      if (mounted) showSnackBar(context, "Wrong password");
      return;
    }

    try {
      await user!.updatePassword(_newPasswordController.text);
      if (mounted) showSnackBar(context, "Password updated successfully");
    } catch (e) {
      if (mounted) showSnackBar(context, "Error updating password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (samsarUser == null) {
      return const Scaffold(
        body: Center(child: CustomLoadingScreen(
          message: "Loading",
        )),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: const Color(0x00087a22),
                      backgroundImage: _getProfileImage(),
                    ),
                  ),
                  const SizedBox(height: 20),
                buildTextField(context, _nameController, "First Name"),
                const SizedBox(height: 16),
                buildTextField(context, _middleNameController, "Middle Name", validator: (value) => null),
                const SizedBox(height: 16),
                buildTextField(context, _lastNameController, "Last Name", validator: (value) => null),
                const SizedBox(height: 16),
                buildTextField(context, _emailController, "Email",
                    validator: _emailValidator),
                  const SizedBox(height: 16),
                  buildPhoneNumberField(_phoneNumberController,
                      _selectedDialogCountry, _openCountryPickerDialog),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showUpdatePasswordDialog,
                          child: Text(
                            "Change Password",
                            style: TextStyle(fontSize: 13, color: theme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else {
                              _showUpdateProfileDialog();
                            }
                          },
                          child: Text("Apply Changes",
                              style: TextStyle(
                                  fontSize: 13, color: theme.primaryColor)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showUpdateProfileDialog() => showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context),
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text("Type your password to apply changes"),
                const SizedBox(height: 16),
                buildTextField(context, _passwordController, "Password",
                    obscureText: true),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _updateProfile();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Apply Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

      Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose an image source"),
        content: const Text("Would you like to take a picture or choose from gallery?"),
        actions: [
          TextButton(
            child: const Text("Camera"),
            onPressed: () {
              Navigator.of(context).pop(ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text("Gallery"),
            onPressed: () {
              Navigator.of(context).pop(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _reauthenticateUser() async {
    String currentPassword = _passwordController.text;

    AuthCredential credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    try {
      await user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      if (mounted) showSnackBar(context, "Error reauthenticating user: $e");
      return false;
    }
  }

  void _showUpdatePasswordDialog() => showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text("Type your old password and the new one to apply changes"),
              const SizedBox(height: 16),
              buildTextField(context, _passwordController, "Old Password",
                  obscureText: true),
              const SizedBox(height: 16),
              buildTextField(
                  context, _newPasswordController, "New Password",
                  obscureText: true),
              const SizedBox(height: 16),
              buildTextField(context, _confirmPasswordController,
                  "Confirm Password",
                  obscureText: true),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _showRecoverPasswordDialog();
                    },
                    child: const Text("Forgot Password?"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate the passwords
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        showSnackBar(context, "Passwords do not match");
                        return;
                      }
                      try {
                        _updatePassword();
                        Navigator.of(context).pop();
                        showSnackBar(
                            context, "Password updated successfully");
                      } catch (e) {
                        showSnackBar(
                            context, "Error updating password: $e");
                      }
                    },
                    child: const Text("Apply Changes"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _showRecoverPasswordDialog() => showDialog(
    context: context,
    builder: (dialogContext) => Theme(
      data: Theme.of(context),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text("Enter your email to recover your password"),
              const SizedBox(height: 16),
              buildTextField(dialogContext, _emailController, "Email",
                  obscureText: false),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text);

                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                      showSnackBar(context,
                          'Password recovery email sent to ${_emailController.text}');
                    }
                  } catch (e) {
                    if (mounted) {
                      showSnackBar(context,
                          'Error sending password recovery email: $e');
                    }
                  }
                },
                child: const Text("Recover Password"),
              ),
            ],
          ),
        ),
      ),
    ),
  );


  String? _emailValidator(String? value) {
    if (value == null || !value.contains('@')) {
      return "Please enter a valid email address";
    }
    return null;
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (samsarUser?.profileImage != null &&
        samsarUser!.profileImage.isNotEmpty) {
      return NetworkImage(samsarUser!.profileImage);
    } else {
      return const AssetImage('assets/icons/default_profile_pic_man.png');
    }
  }

  void _openCountryPickerDialog() => showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context),
            child: CountryPickerDialog(
              titlePadding: const EdgeInsets.all(8.0),
              searchInputDecoration: const InputDecoration(hintText: "Search..."), // Localized hint text
              isSearchable: true,
              title: const Text(
                "Select your phone code",
                style: TextStyle(fontSize: 18),
              ),

              onValuePicked: (Country country) =>
                  setState(() => _selectedDialogCountry = country),
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
          ));
}

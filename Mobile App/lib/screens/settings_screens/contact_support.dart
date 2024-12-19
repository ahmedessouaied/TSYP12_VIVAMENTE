import 'package:b_bot/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/widgets.dart';
import '../../structures/structs.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userManager = UserController();
  final db = FirebaseFirestore.instance;
  User? samsarUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await db.collection('supportRequests').doc(samsarUser!.uid).set({
        'name': _nameController.text,
        'email': samsarUser!.email,
        'userId': samsarUser!.uid,
        'messages': FieldValue.arrayUnion([
          {
            'timestamp': Timestamp.now(),
            'subject': _subjectController.text,
            'message': _messageController.text,
            'answered': false,
          }
        ])
      }, SetOptions(merge: true));

      if (mounted) {
        showSnackBar(context, "Support request submitted successfully");
      }

      _subjectController.clear();
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Error submitting support request");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        samsarUser = _userManager.currentUser!;
        _nameController.text = samsarUser!.displayName;
        _emailController.text = samsarUser!.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Support"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField(
                      _nameController,
                      "Name",
                      "Enter your name",
                    ),
                    buildTextField(
                      _emailController,
                      "Email",
                      "Enter your email",
                      email: true,
                    ),
                    buildTextField(
                      _subjectController,
                      "Subject",
                      "Enter the subject of your message",
                    ),
                    buildTextField(
                      _messageController,
                      "Message",
                      "Enter your message",
                      maxLines: 10,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          style: theme.elevatedButtonTheme.style,
                          onPressed: _submitSupportRequest,
                          child: const Text("Submit Request"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              buildInfoCard(
                context,
                Icons.support_agent_sharp,
                "Contact Information",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailRow(context, Icons.location_on_outlined,
                        "Location",
                        "Sup'Com Raoued Km 3,5 - 2083, Ariana Tunisie",
                        wrapText: true),
                    buildDetailRow(context, Icons.phone, "Phone",
                        "+216 28356927"),
                    buildDetailRow(context, Icons.email, "Email",
                        "EMBS.tsyp12@supcom.tn",
                        wrapText: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, String hint,
      {bool email = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          if (email && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Please enter a valid email address";
          }
          return null;
        },
      ),
    );
  }
}


Widget buildInfoCard(
    BuildContext context, IconData icon, String title, Widget content) {
  final theme = Theme.of(context);
  return Card(
    elevation: 4,
    color: theme.cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    ),
  );
}


Widget buildDetailRow(
    BuildContext context, IconData icon, String label, String value,
    {bool wrapText = false}) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: wrapText
        ? Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.iconTheme.color),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: theme.textTheme.titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    )
        : Row(
      children: [
        Icon(icon, size: 20, color: theme.iconTheme.color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value, style: theme.textTheme.titleSmall),
        ),
      ],
    ),
  );
}



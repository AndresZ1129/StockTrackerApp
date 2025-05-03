import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': '',
          'lastName': '',
          'role': '',
        });
      }

      final data = doc.data();
      if (data != null) {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _roleController.text = data['role'] ?? '';
      }
    }
  }

  Future<void> _updateUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'role': _roleController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user != null && _currentPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      try {
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both password fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.greenAccent),),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                style: TextStyle(color: Colors.greenAccent), // Set the text color here
                decoration: const InputDecoration(labelText: 'First Name',
                labelStyle: TextStyle(color: Colors.white), // Set the label color here
                ),
              ),
              TextFormField(
                controller: _lastNameController,
                style: TextStyle(color: Colors.greenAccent), // Set the text color here
                decoration: const InputDecoration(labelText: 'Last Name',
                labelStyle: TextStyle(color: Colors.white), // Set the label color here
                ),
              ),
              TextFormField(
                controller: _roleController,
                style: TextStyle(color: Colors.greenAccent), // Set the text color here
                decoration: const InputDecoration(labelText: 'Role', 
                labelStyle: TextStyle(color: Colors.white), // Set the label color here
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Save Changes'),
              ),
              const Divider(height: 40),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                style: TextStyle(color: Colors.greenAccent), // Set the text color here
                decoration: const InputDecoration(labelText: 'Current Password', 
                labelStyle: TextStyle(color: Colors.white), // Set the label color here
                ),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: TextStyle(color: Colors.greenAccent), // Set the text color here
                decoration: const InputDecoration(labelText: 'New Password', 
                labelStyle: TextStyle(color: Colors.white), // Set the label color here
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

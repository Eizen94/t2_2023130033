import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _username;
  late String _name;
  late String _phoneNumber;
  late String _emailAddress;
  late String _address;
  late String _about;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'johndoe';
      _name = prefs.getString('name') ?? 'John Doe';
      _phoneNumber = prefs.getString('phoneNumber') ?? '+1234567890';
      _emailAddress = prefs.getString('emailAddress') ?? 'john.doe@example.com';
      _address = prefs.getString('address') ?? '123 Main St, City, Country';
      _about = prefs.getString('about') ?? 'UI/UX Designer passionate about creating intuitive user experiences.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile_image.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement image picker functionality
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _buildTextField('Username', _username, (value) => _username = value!),
                _buildTextField('Name', _name, (value) => _name = value!),
                _buildTextField('Phone Number', _phoneNumber, (value) => _phoneNumber = value!),
                _buildTextField('Email Address', _emailAddress, (value) => _emailAddress = value!),
                _buildTextField('Address', _address, (value) => _address = value!),
                _buildTextField('About', _about, (value) => _about = value!, maxLines: 3),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Save Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildTextField(String label, String initialValue, Function(String?) onSaved, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: TextStyle(color: Colors.white),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username);
      await prefs.setString('name', _name);
      await prefs.setString('phoneNumber', _phoneNumber);
      await prefs.setString('emailAddress', _emailAddress);
      await prefs.setString('address', _address);
      await prefs.setString('about', _about);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    }
  }
}
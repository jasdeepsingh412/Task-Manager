import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create user in Firebase Auth
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;

      if (user == null) {
        throw Exception("User creation failed.");
      }

      // 2️⃣ Force refresh ID token (prevents permission race condition)
      await user.getIdToken(true);

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // 3️⃣ Save profile to Firestore (doc id MUST equal uid)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4️⃣ Optional: Update display name
      await user.updateDisplayName("$firstName $lastName");

      // 5️⃣ Sign out so user must log in manually
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created! Please login to continue."),
          backgroundColor: Colors.green,
        ),
      );


    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registration failed.");
    } on FirebaseException catch (e) {
      _showError(e.message ?? "Database error occurred.");
    } catch (e) {
      _showError("Unexpected error occurred.");
      debugPrint("Register error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Centers content even on larger screens
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Title Section
                Text(
                  "Manage Your Tasks Efficiently",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  "Create an account to start managing tasks.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Name Row (Modern side-by-side layout)
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: "First Name",
                        icon: Icons.person_outline,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: "Last Name",
                        icon: Icons.person_outline,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  theme: theme,
                  validator: (val) => val!.contains('@') ? null : "Invalid email",
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  theme: theme,
                  isPassword: true,
                  validator: (val) => val!.length < 6 ? "Minimum 6 chars" : null,
                ),
                const SizedBox(height: 32),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Create Account", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 16),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Already have an account? Login", style: GoogleFonts.poppins(color: theme.colorScheme.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable TextField for clean code logic
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: validator ?? (value) => value!.isEmpty ? "Required" : null,
    );
  }
}
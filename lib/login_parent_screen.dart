import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mut6/PasswordRecoveryScreen.dart';
import 'package:mut6/parent_screen.dart';
import 'children_screen.dart'; // استيراد شاشة التابعين

class LoginParentScreen extends StatefulWidget {
  const LoginParentScreen({Key? key}) : super(key: key);

  @override
  _LoginParentScreenState createState() => _LoginParentScreenState();
}

class _LoginParentScreenState extends State<LoginParentScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      String id = _idController.text.trim();
      String password = _passwordController.text.trim();

      if (id.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الرجاء إدخال جميع الحقول"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // البحث في مجموعة أولياء الأمور (parents)
      var parentQuery =
          await FirebaseFirestore.instance
              .collection('parents')
              .where('id', isEqualTo: id)
              .limit(1)
              .get();

      // البحث في مجموعة التفويضات (Authorizations)
      var authorizationQuery =
          await FirebaseFirestore.instance
              .collection('Authorizations')
              .where('id', isEqualTo: id)
              .limit(1)
              .get();

      // التحقق من وجود الحساب في أي من المجموعتين
      if (parentQuery.docs.isNotEmpty) {
        _validateAndNavigate(parentQuery.docs.first, password);
      } else if (authorizationQuery.docs.isNotEmpty) {
        _validateAndNavigate(authorizationQuery.docs.first, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الحساب غير موجود"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء تسجيل الدخول: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _validateAndNavigate(DocumentSnapshot userDoc, String password) {
    var userData = userDoc.data() as Map<String, dynamic>;
    String storedPassword = userData['password'];

    if (storedPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمة المرور غير صحيحة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // نجاح تسجيل الدخول وتحديد الصفحة المناسبة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تسجيل الدخول بنجاح!"),
        backgroundColor: Colors.green,
      ),
    );

    // الحصول على معرف ولي الأمر أو الموكل
    String guardianId = userData['id'];

    // تحويل إلى صفحة التابعين مع تمرير guardianId
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GuardianScreen(guardianId: guardianId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "تسجيل دخول ولي الأمر",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://i.postimg.cc/DwnKf079/321e9c9d-4d67-4112-a513-d368fc26b0c0.jpg',
              height: 180,
            ),
            const SizedBox(height: 30),
            _buildInputField(_idController, 'رقم ولي الأمر', Icons.person),
            const SizedBox(height: 10),
            _buildInputField(
              _passwordController,
              'كلمة المرور',
              Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _buildActionButton('تسجيل دخول', _login),
            const SizedBox(height: 10),
            _buildPasswordRecoveryButton(), // زر استعادة كلمة المرور
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 1, 113, 189)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordRecoveryButton() {
    return TextButton(
      onPressed: () {
        // الانتقال إلى شاشة استعادة كلمة المرور
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
        );
      },
      child: const Text(
        'استعادة كلمة المرور',
        style: TextStyle(color: Color.fromARGB(255, 1, 113, 189), fontSize: 16),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 1, 113, 189),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

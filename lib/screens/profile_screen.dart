import 'package:flutter/material.dart';

const mainColor = Color(0xFFD39595);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 КОРИСТУВАЧ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: mainColor,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Maria',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'maria@email.com',
                    style: TextStyle(color: Colors.grey[400]),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Редагувати профіль'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ⚙️ НАЛАШТУВАННЯ
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Мої кімнати'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Редагувати кімнати'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 🚪 ВИЙТИ (1/3 ширини)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  child: const Text('Вийти'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

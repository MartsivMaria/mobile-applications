import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/profile/profile_cubit.dart';
import '../logic/profile/profile_state.dart';
import '../models/user_model.dart';
import '../widgets/profile_dialogs.dart';

const mainColor = Color(0xFFD39595);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading)
            return const Center(
              child: CircularProgressIndicator(color: mainColor),
            );
          if (state is UserLoaded) {
            final user = state.user;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 20),
                  _buildMenuCard(context, user),
                  const Spacer(),
                  _buildLogoutButton(context),
                ],
              ),
            );
          }
          return const Center(child: Text("Помилка даних"));
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
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
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              onPressed: () => ProfileDialogs.showEditName(context, user),
              child: const Text(
                'Редагувати імʼя',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _menuTile(
            Icons.list,
            'Мої кімнати',
            () => ProfileDialogs.showRoomsList(context, user),
          ),
          const Divider(height: 1, color: Colors.white10),
          _menuTile(
            Icons.edit_note,
            'Редагувати кімнати',
            () => ProfileDialogs.showManageRooms(context, user),
          ),
        ],
      ),
    );
  }

  ListTile _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white70,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _confirmLogout(context),
        child: const Text(
          'Вийти',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Вихід',
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ви впевнені?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Ні'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (r) => false,
              );
            },
            child: const Text('Так'),
          ),
        ],
      ),
    );
  }
}

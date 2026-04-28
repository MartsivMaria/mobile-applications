import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/profile/profile_cubit.dart';
import '../models/user_model.dart';

const mainColor = Color(0xFFD39595);

class ProfileDialogs {
  static void showRoomsList(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Мої кімнати', style: TextStyle(color: mainColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: user.rooms.isEmpty
              ? const Text(
                  'Список порожній',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: user.rooms.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.meeting_room, color: mainColor),
                    title: Text(
                      user.rooms[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Закрити',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  static void showManageRooms(BuildContext context, UserModel user) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Керування кімнатами',
          style: TextStyle(color: mainColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Назва нової кімнати',
                hintStyle: const TextStyle(color: Colors.white30),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: mainColor),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final name = controller.text.trim();
                      context.read<UserCubit>().addRoom(name);
                      controller.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: user.rooms.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      user.rooms[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          context.read<UserCubit>().deleteRoom(index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditName(BuildContext context, UserModel user) {
    final controller = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Редагувати профіль',
          style: TextStyle(color: mainColor),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Повне імʼя',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () {
              context.read<UserCubit>().updateName(controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }
}

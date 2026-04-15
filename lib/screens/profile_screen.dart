import 'package:flutter/material.dart';
import '../services/local_user_repository.dart';
import '../models/user_model.dart';

const mainColor = Color(0xFFD39595);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repo = LocalUserRepository();

  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final UserModel? user = await repo.getUser();
    if (!mounted) return;
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  void _showRoomsList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Мої кімнати', style: TextStyle(color: mainColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: currentUser!.rooms.isEmpty
              ? const Text(
                  'Список порожній',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentUser!.rooms.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.meeting_room, color: mainColor),
                    title: Text(
                      currentUser!.rooms[index],
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

  void _showManageRoomsDialog() {
    final newRoomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Керування кімнатами',
            style: TextStyle(color: mainColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newRoomController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Назва нової кімнати',
                  hintStyle: const TextStyle(color: Colors.white30),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: mainColor),
                    onPressed: () {
                      if (newRoomController.text.isNotEmpty) {
                        final updatedRooms = List<String>.from(
                          currentUser!.rooms,
                        )..add(newRoomController.text.trim());
                        _updateRooms(updatedRooms);
                        newRoomController.clear();
                        setDialogState(() {});
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
                    itemCount: currentUser!.rooms.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        currentUser!.rooms[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          final updatedRooms = List<String>.from(
                            currentUser!.rooms,
                          )..removeAt(index);
                          _updateRooms(updatedRooms);
                          setDialogState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateRooms(List<String> newRooms) async {
    final updatedUser = currentUser!.copyWith(rooms: newRooms);
    await repo.register(updatedUser);

    if (!context.mounted) return;

    setState(() {
      currentUser = updatedUser;
    });
  }

  void _showEditProfileDialog() {
    if (currentUser == null) return;
    final nameController = TextEditingController(text: currentUser!.fullName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Редагувати профіль',
          style: TextStyle(color: mainColor),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Повне імʼя',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: mainColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Скасувати',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              final updatedUser = currentUser!.copyWith(
                fullName: nameController.text.trim(),
              );
              await repo.register(updatedUser);

              if (!context.mounted) return;

              setState(() => currentUser = updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Вихід',
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ви впевнені, що хочете вийти з додатка?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Скасувати',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await repo.logout();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: mainColor))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
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
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentUser?.fullName ?? 'Невідомо',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.email ?? 'Немає email',
                            style: TextStyle(color: Colors.grey[400]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                            onPressed: _showEditProfileDialog,
                            child: const Text(
                              'Редагувати імʼя',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.list,
                            color: Colors.white70,
                          ),
                          title: const Text(
                            'Мої кімнати',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white70,
                          ),
                          onTap: _showRoomsList,
                        ),
                        const Divider(height: 1, color: Colors.white10),
                        ListTile(
                          leading: const Icon(
                            Icons.edit_note,
                            color: Colors.white70,
                          ),
                          title: const Text(
                            'Редагувати кімнати',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white70,
                          ),
                          onTap: _showManageRoomsDialog,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: logout,
                        child: const Text(
                          'Вийти',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
}

import 'package:flutter/material.dart';
import 'package:ymix_messenger/models/user.dart';

class PetScreen extends StatefulWidget {
  final User user;

  const PetScreen({Key? key, required this.user}) : super(key: key);

  @override
  _PetScreenState createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final purchasedPets = _currentUser.inventory.where((id) => id.startsWith('1')).toList();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Мои питомцы',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: purchasedPets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'У вас пока нет питомцев',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Купите питомцев в магазине',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: purchasedPets.length,
              itemBuilder: (context, index) {
                final petId = purchasedPets[index];
                return Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: const Icon(Icons.pets, color: Colors.orange, size: 40),
                    title: Text('Питомец $petId', style: const TextStyle(color: Colors.white)),
                    subtitle: const Text('Ваш верный друг', style: TextStyle(color: Colors.grey)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Питомец выбран!')),
                        );
                      },
                      child: const Text('Выбрать'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
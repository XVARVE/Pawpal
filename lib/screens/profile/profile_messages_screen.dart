import 'package:flutter/material.dart';

class ProfileMessagesScreen extends StatelessWidget {
  final chats = [
    {
      'name': 'Dr Jaxson Calzoni',
      'img': 'assets/doctor2.jpg',
      'msg': 'Yes, I am now available, just bring your dog here',
      'time': '11:00',
      'count': 1,
    },
    {
      'name': 'Tatiana Vetrovs',
      'img': 'assets/user2.jpg',
      'msg': 'Is the animal in good health?',
      'time': '10:47',
      'count': 10,
    },
    {
      'name': 'Dr Maria Botosh',
      'img': 'assets/doctor3.jpg',
      'msg': 'Don\'t forget to give food with high nutrition',
      'time': '09:05',
      'count': 1,
    },
    {
      'name': 'Miracle Geidt',
      'img': 'assets/user3.jpg',
      'msg': 'What if we met today?',
      'time': '07:00',
      'count': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: chats.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, i) {
                final chat = chats[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(chat['img']!),
                      radius: 24,
                    ),
                    title: Text(chat['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(chat['msg']!),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(chat['time']!, style: TextStyle(color: Colors.black54, fontSize: 13)),
                        if ((chat['count'] as int) > 0)
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF4B8BFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${chat['count']}',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

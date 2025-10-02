import 'package:flutter/material.dart';

class ChatSellerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(66),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFF5E9FF),
                  backgroundImage: AssetImage('assets/images/seller_avatar.jpg'),
                ),
                SizedBox(width: 14),
                Text(
                  'Paityn Westervelt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Divider(height: 1, thickness: 0.7),
            SizedBox(height: 14),
            Text(
              "Aug 11, 2022",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ChatBubble(
                    message: "Hi Fresty! is it still available?",
                    time: "2:07 PM",
                    isMe: true,
                  ),
                  SizedBox(height: 16),
                  ChatBubble(
                    message: "Hi, it's still available. Can I help you?",
                    time: "2:07 PM",
                    isMe: false,
                  ),
                ],
              ),
            ),
            // Border above text field
            // ...inside your Scaffold/Column
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F7FA),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.camera_alt, color: Colors.black87, size: 26),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        style: TextStyle(fontSize: 16),
                        textAlignVertical: TextAlignVertical.center, // Center vertically
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'What about the current condition...',
                          hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 0), // <--- tweak this if needed
                          suffixIcon: Icon(Icons.send, color: Color(0xFF4B8BFF), size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;
  const ChatBubble({required this.isMe, required this.message, required this.time});
  @override
  Widget build(BuildContext context) {
    // Limit bubble width for vertical look
    double maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth, // Make bubble more vertical
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 10, top: 2),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14), // More vertical padding
          decoration: BoxDecoration(
            color: isMe ? Color(0xFF4B8BFF) : Color(0xFFF4F7FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: isMe ? Radius.circular(18) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(18),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 22, right: isMe ? 0 : 12),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white.withOpacity(0.8) : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


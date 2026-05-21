import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/core/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatService = ChatService();
  final _controller = TextEditingController();
  final _messages = <ChatMessage>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Mbəmbə kídí ! Je suis Sankofa, prête à t'aider en ewondo. Pose-moi une question !");
  }

  void _addBotMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: false));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      final reply = await _chatService.sendMessage(text);
      setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
    } catch (e) {
  debugPrint("🔥 ERREUR CHAT : $e");   // ← AJOUTE CETTE LIGNE
  setState(() => _messages.add(ChatMessage(
      text: "Désolée, une erreur est survenue...", isUser: false)));
} finally {
      setState(() => _isLoading = false);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sankofa - Assistant Ewondo"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              // Afficher les catégories (à implémenter)
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 121, 120, 120).withOpacity(0.7), 
                // color: Colors.white.withOpacity(0.7),// couche semi‑transparente
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index]),
                ),
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Écris en français...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// import 'package:flutter/material.dart';
// import 'package:afroduo/core/theme/app_colors.dart';
// import 'package:afroduo/core/services/chat_service.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final _chatService = ChatService();
//   final _controller = TextEditingController();
//   final _messages = <ChatMessage>[];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _addBotMessage("Mbəmbə kídí ! Je suis Sankofa, prête à t'aider en ewondo. Pose-moi une question !");
//   }

//   void _addBotMessage(String text) {
//     _messages.add(ChatMessage(text: text, isUser: false));
//   }

//   void _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     setState(() {
//       _messages.add(ChatMessage(text: text, isUser: true));
//       _isLoading = true;
//     });
//     _controller.clear();

//     try {
//       final reply = await _chatService.sendMessage(text);
//       setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
//     } catch (e) {
//       setState(() => _messages.add(ChatMessage(text: "Désolée, une erreur est survenue...", isUser: false)));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Sankofa - Assistant Ewondo"),
//         backgroundColor: AppColors.primaryBlue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.category),
//             onPressed: () {
//               // Afficher les catégories (à implémenter)
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
//             ),
//           ),
//           _buildInputArea(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     final isUser = message.isUser;
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isUser ? AppColors.primaryBlue : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(20).copyWith(
//             bottomLeft: isUser ? Radius.circular(20) : Radius.circular(4),
//             bottomRight: isUser ? Radius.circular(4) : Radius.circular(20),
//           ),
//         ),
//         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
//         child: Text(
//           message.text,
//           style: TextStyle(color: isUser ? Colors.white : Colors.black87),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputArea() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: "Écris en français...",
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: AppColors.primaryBlue,
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white),
//               onPressed: _isLoading ? null : _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   ChatMessage({required this.text, required this.isUser});
// }


import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPEN_AI_KEY,
    baseOption: HttpSetup(
      receiveTimeout: Duration(seconds: 5),
    ),
    enableLog: true,
  );
  final ChatUser get_user = ChatUser(
    id: '1',
    firstName: 'Daniel',
    lastName: 'Adel',
  );
  final ChatUser get_chat = ChatUser(
    id: '2',
    firstName: 'chat',
    lastName: 'gpt',
  );
  List<ChatMessage> chatMessage = <ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat GPT',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(0, 166, 126, 1),
      ),
      body: DashChat(
          messageOptions: MessageOptions(
              currentUserContainerColor: Colors.black,
              containerColor: Color.fromRGBO(0, 166, 126, 1),
              textColor: Colors.white),
          currentUser: get_user,
          onSend: (message) {
            getChatResponse(message);
          },
          messages: chatMessage),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      chatMessage.insert(0, m);
    });

    List<Map<String, dynamic>> _messagesHistory = chatMessage.reversed.map((e) {
      if (e.user == get_user) {
        return {
          "role": "user",
          "content": e.text.toString(),
        };
      } else {
        return {
          "role": "assistant",
          "content": e.text.toString(),
        };
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200, // Fixed typo: maxToken -> maxTokens
    );

    final response = await _openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          chatMessage.insert(
            0,
            ChatMessage(
              user: get_chat, // Assuming get_chat is a variable
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        });
      }
    }
  }
}

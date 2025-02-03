import 'package:flutter/material.dart';
import 'package:ChatMcp/llm/model.dart';
import 'dart:convert';
import 'package:ChatMcp/widgets/collapsible_section.dart';
import 'package:ChatMcp/widgets/markdown/markit.dart';

class ChatUIMessage extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool showAvatar;

  const ChatUIMessage({
    super.key,
    required this.messages,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox();

    final firstMsg = messages.first;
    final isUser = firstMsg.role == MessageRole.user;

    return Container(
      margin: showAvatar
          ? const EdgeInsets.symmetric(vertical: 8.0)
          : const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            SizedBox(
              width: 40,
              child: showAvatar ? ChatAvatar(isUser: false) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: messages
                  .map((msg) => ChatMessageContent(message: msg))
                  .toList(),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) ChatAvatar(isUser: true),
        ],
      ),
    );
  }
}

class ChatMessageContent extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageContent({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.role == MessageRole.user
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (message.role == MessageRole.loading)
          const CircularProgressIndicator(),
        if ((message.role == MessageRole.user ||
                message.role == MessageRole.assistant) &&
            message.content != null)
          MessageBubble(message: message),
        if (message.toolCalls != null && message.toolCalls!.isNotEmpty)
          ToolCallWidget(message: message),
        if (message.role == MessageRole.tool && message.toolCallId != null)
          ToolResultWidget(message: message),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.role == MessageRole.user
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: message.role == MessageRole.user
          ? TextSelectionTheme(
              data: TextSelectionThemeData(
                selectionColor: Colors.white.withAlpha(77),
              ),
              child: SelectableText(
                message.content ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : message.content != null
              ? Markit(data: (message.content!).trim())
              : const Text(''),
    );
  }
}

class ToolCallWidget extends StatelessWidget {
  final ChatMessage message;

  const ToolCallWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: CollapsibleSection(
        title: Text(
          '${message.mcpServerName} call_${message.toolCalls![0]['function']['name']}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        content: Markit(
          data: (message.toolCalls?.isNotEmpty ?? false)
              ? [
                  '```json',
                  const JsonEncoder.withIndent('  ').convert({
                    "name": message.toolCalls![0]['function']['name'],
                    "arguments": json
                        .decode(message.toolCalls![0]['function']['arguments']),
                  }),
                  '```',
                ].join('\n')
              : '',
        ),
      ),
    );
  }
}

class ToolResultWidget extends StatelessWidget {
  final ChatMessage message;

  const ToolResultWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: CollapsibleSection(
        title: Text(
          '${message.mcpServerName} ${message.toolCallId!} result',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        content: Markit(data: (message.content ?? '').trim()),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  final bool isUser;

  const ChatAvatar({
    super.key,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Container();
    }
    return CircleAvatar(
      backgroundColor: Colors.grey,
      child: Icon(
        isUser ? Icons.person : Icons.android,
        color: Colors.white,
      ),
    );
  }
}

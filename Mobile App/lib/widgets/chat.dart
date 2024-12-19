part of 'widgets.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSenderInfo;

  const MessageBubble({
    required this.message,
    this.showSenderInfo = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic colors based on theme and user/receiver
    final userBubbleColor = theme.colorScheme.primary.withOpacity(0.3);
    final receiverBubbleColor = Colors.blue[400]?.withAlpha(128);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment:
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderInfo && !message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName ?? 'User',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser)
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("assets/images/logo.png")
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? userBubbleColor : receiverBubbleColor,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: message.isUser ? null : const Radius.circular(4),
                      bottomRight: message.isUser ? const Radius.circular(4) : null,
                    ),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.imageUrl != null)
                          Stack(
                            children: [
                              Image.file(
                                File(message.imageUrl!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Add image preview functionality
                                      _showImagePreview(context, message.imageUrl!);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: message.imageUrl != null ? 8 : 12,
                            bottom: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const MessageList({
    required this.messages,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print(messages);
    print(messages.length);
    return Theme(
      data: Theme.of(context),
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final showSenderInfo = _shouldShowSenderInfo(index);
          return MessageBubble(
            message: message,
            showSenderInfo: showSenderInfo,
          );
        },
      ),
    );
  }

  bool _shouldShowSenderInfo(int index) {
    if (index == 0) return true;
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return currentMessage.senderName != previousMessage.senderName ||
        currentMessage.timestamp.difference(previousMessage.timestamp).inMinutes > 5;
  }
}

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleCamera;
  final bool isRecording;
  final bool isCameraActive;

  const ChatInput({
    required this.onSendMessage,
    required this.onToggleAudio,
    required this.onToggleCamera,
    required this.isRecording,
    required this.isCameraActive,
    super.key,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(widget.isCameraActive ? Icons.stop : Icons.camera),
            onPressed: widget.onToggleCamera,
            color: widget.isCameraActive ? Colors.red : Colors.purple,
          ),
          IconButton(
            icon: Icon(widget.isRecording ? Icons.stop : Icons.mic),
            onPressed: widget.onToggleAudio,
            color: widget.isRecording ? Colors.red : Colors.purple,
          ),
          Expanded(
            flex: 2,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              onTapOutside: (_) => _focusNode.unfocus(),
              decoration: InputDecoration(

                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              widget.onSendMessage(_controller.text);
              _controller.clear();
            },
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
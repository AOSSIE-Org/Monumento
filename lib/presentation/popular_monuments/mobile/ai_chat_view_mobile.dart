// presentation/popular_monuments/mobile/ai_chat_view_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/popular_monuments/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:monumento/data/models/chat_message_model.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class AiChatViewMobile extends StatefulWidget {
  final MonumentEntity monument;
  final String monumentDescription;

  const AiChatViewMobile({
    super.key,
    required this.monument,
    required this.monumentDescription,
  });

  @override
  State<AiChatViewMobile> createState() => _AiChatViewMobileState();
}

class _AiChatViewMobileState extends State<AiChatViewMobile>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _addWelcomeMessage() {
    final welcomeMessage = _generateWelcomeMessage();
    _messages.add(ChatMessage(
      text: welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  String _generateWelcomeMessage() {
    return "Hello! I'm your AI guide for ${widget.monument.name}. "
        "I can help you with information about visiting hours, historical facts, "
        "nearby attractions, and travel tips. What would you like to know?";
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Send to AI
    BlocProvider.of<AiChatBloc>(context).add(SendMessageToAi(
      message: message,
      monumentName: widget.monument.name,
      monumentDescription: widget.monumentDescription,
      monumentLocation: "${widget.monument.city}, ${widget.monument.country}",
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottomDelayed() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _buildChatList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appWhite,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColor.appBlack,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Assistant",
                  style: AppTextStyles.s16(
                    color: AppColor.appBlack,
                    fontType: FontType.MEDIUM,
                  ),
                ),
                Text(
                  widget.monument.name,
                  style: AppTextStyles.s12(
                    color: AppColor.appBlack.withOpacity(0.6),
                    fontType: FontType.REGULAR,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showInfoDialog,
          icon: const Icon(
            Icons.info_outline,
            color: AppColor.appBlack,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.appPrimary,
            AppColor.appPrimary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.appPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology,
        color: AppColor.appWhite,
        size: 18,
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.appPrimary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColor.appBlack.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColor.appPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Ask about visiting tips, history, or nearby places",
              style: AppTextStyles.s12(
                color: AppColor.appPrimary,
                fontType: FontType.MEDIUM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) {
        if (state is AiChatResponse) {
          setState(() {
            _messages.add(ChatMessage(
              text: state.response,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottomDelayed();
          HapticFeedback.selectionClick();
        } else if (state is AiChatError) {
          setState(() {
            _messages.add(ChatMessage(
              text: "I apologize, but I'm having trouble responding right now. "
                  "Please try asking your question again.",
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ));
          });
          _scrollToBottomDelayed();
          HapticFeedback.heavyImpact();
        }
      },
      builder: (context, state) {
        print('Building chat list with state: $state'); // Debug log
        return Container(
          decoration: BoxDecoration(
            color: AppColor.appWhite,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: _isKeyboardVisible ? 16 : 80,
            ),
            itemCount: _messages.length + (state is AiChatLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (state is AiChatLoading && index == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(_messages[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isLastMessage = index == _messages.length - 1;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastMessage ? 8 : 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            _buildMessageAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(message),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColor.appPrimary
                      : message.isError
                          ? Colors.red.withOpacity(0.1)
                          : AppColor.appWhite,
                  borderRadius: _getBubbleBorderRadius(message),
                  border: message.isUser
                      ? null
                      : Border.all(
                          color: message.isError
                              ? Colors.red.withOpacity(0.3)
                              : AppColor.appBlack.withOpacity(0.1),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.appBlack.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: AppTextStyles.s14(
                    color: message.isUser
                        ? AppColor.appWhite
                        : message.isError
                            ? Colors.red.shade700
                            : AppColor.appBlack,
                    fontType: FontType.REGULAR,
                  ),
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildMessageAvatar(message),
          ],
        ],
      ),
    );
  }

  BorderRadius _getBubbleBorderRadius(ChatMessage message) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (message.isUser) {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: smallRadius,
      );
    } else {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: smallRadius,
        bottomRight: radius,
      );
    }
  }

  Widget _buildMessageAvatar(ChatMessage message) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: message.isUser
            ? AppColor.appSecondary.withOpacity(0.1)
            : message.isError
                ? Colors.red.withOpacity(0.1)
                : AppColor.appPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        message.isUser
            ? Icons.person_outline
            : message.isError
                ? Icons.error_outline
                : Icons.psychology,
        color: message.isUser
            ? AppColor.appSecondary
            : message.isError
                ? Colors.red.shade600
                : AppColor.appPrimary,
        size: 16,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMessageAvatar(ChatMessage(
            text: "",
            isUser: false,
            timestamp: DateTime.now(),
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.appWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: AppColor.appBlack.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.appBlack.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (_typingAnimation.value - delay).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      child: Transform.translate(
                        offset: Offset(
                            0, -4 * (1 - (animationValue * 2 - 1).abs())),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColor.appPrimary.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColor.appWhite,
        border: Border(
          top: BorderSide(
            color: AppColor.appBlack.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.appBlack.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: "Ask about visiting hours, history, tips...",
                  hintStyle: AppTextStyles.s14(
                    color: AppColor.appBlack.withOpacity(0.5),
                    fontType: FontType.REGULAR,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppColor.appBlack.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppColor.appBlack.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColor.appPrimary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: AppColor.appWhite,
                ),
                style: AppTextStyles.s14(
                  color: AppColor.appBlack,
                  fontType: FontType.REGULAR,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (text) {
                  // Optional: Add typing indicator logic here
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.appPrimary,
                  AppColor.appPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.appPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _sendMessage,
                child: const Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: AppColor.appWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    if (message.isUser) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Assistant Info'),
        content: Text(
          'This AI assistant can help you with information about ${widget.monument.name}. '
          'Ask about visiting hours, historical facts, nearby attractions, or travel tips.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

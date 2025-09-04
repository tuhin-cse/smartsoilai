import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import 'main_navigation_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final authController = Get.find<AuthController>();
    final userService = UserService.to;
    final textController = TextEditingController();

    // Listen to inputText changes and clear controller when needed
    ever(controller.inputText, (text) {
      if (text.isEmpty && textController.text.isNotEmpty) {
        textController.clear();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary50, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, controller),
              Expanded(
                child: Obx(() {
                  if (controller.isRecording.value) {
                    return _buildRecordingState(controller);
                  } else if (controller.messages.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return _buildMessagesList(
                      controller,
                      authController,
                      userService,
                    );
                  }
                }),
              ),
              Obx(() {
                if (!controller.isRecording.value) {
                  return _buildInputSection(controller, textController);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary400,
            AppColors.primary500,
            AppColors.primary600,
            AppColors.primary700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.find<MainNavigationController>().changeIndex(0);
              Get.back();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.05),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Image.asset(
              'assets/icons/ai_avatar.png',
              width: 42,
              height: 42,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Soil AI Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.white70,
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        color: Color(0x80FF6B35),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: 1.2),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.8),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'clear_chat',
                    child: Row(
                      children: [
                        Icon(Icons.clear, color: AppColors.primary500),
                        const SizedBox(width: 8),
                        const Text('Clear Chat'),
                      ],
                    ),
                  ),
                ],
              ).then((value) {
                if (value == 'clear_chat') {
                  controller.messages.clear();
                  Get.snackbar(
                    'Chat Cleared',
                    'All messages have been cleared',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.shade100,
                    colorText: Colors.blue.shade800,
                    duration: const Duration(seconds: 2),
                  );
                } else if (value == 'settings') {
                  Get.toNamed('/settings');
                }
              });
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              child: Lottie.network(
                'https://assets3.lottiefiles.com/packages/lf20_x62chJ.json',
                fit: BoxFit.contain,
                animate: true,
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.grass,
                      color: AppColors.primary500,
                      size: 80,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'How Can I Help You?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tell me what you need: crop advice, soil test help, or pest diagnosis. I\'ve got you covered!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    ChatController controller,
    AuthController authController,
    UserService userService,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return _buildMessageItem(message, authController, userService);
            },
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary500,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildMessageItem(
    ChatMessage message,
    AuthController authController,
    UserService userService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary100,
                child: Image.asset(
                  'assets/icons/ai_avatar.png',
                  width: 26,
                  height: 26,
                ),
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? 'Me' : 'Soilsense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        message.isUser
                            ? AppColors.primary500
                            : AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          message.isUser
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                      bottomRight:
                          message.isUser
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        message.isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (message.imageUri != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message.imageUri!),
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (message.isUser)
                        Text(
                          message.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      else
                        MarkdownBody(
                          data: message.message,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                            h1: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            h2: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            h3: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            em: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                            code: TextStyle(
                              backgroundColor: Colors.grey.shade200,
                              color: AppColors.primary500,
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            blockquoteDecoration: const BoxDecoration(
                              color: Color(0xFFF9F9F9),
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primary500,
                                  width: 4,
                                ),
                              ),
                            ),
                            a: const TextStyle(
                              color: AppColors.primary500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 12, bottom: 4),
              child: Obx(
                () => CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary100,
                  backgroundImage:
                      userService.profileImage.isNotEmpty
                          ? NetworkImage(userService.profileImage)
                          : (authController.profileImage != null
                              ? NetworkImage(authController.profileImage!)
                              : null),
                  child:
                      (userService.profileImage.isEmpty &&
                              authController.profileImage == null)
                          ? Image.asset(
                            'assets/icons/user.png',
                            width: 26,
                            height: 26,
                          )
                          : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingState(ChatController controller) {
    return GestureDetector(
      onTap: () => controller.stopRecording(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                children: [
                  // Animated ellipses
                  AnimatedBuilder(
                    animation: controller.ellipse1Animation,
                    builder: (context, child) {
                      return Positioned(
                        top: 17,
                        left: 22,
                        child: Transform.rotate(
                          angle:
                              controller.ellipse1Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 97,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: controller.ellipse2Animation,
                    builder: (context, child) {
                      return Positioned(
                        top: 0,
                        left: 92,
                        child: Transform.rotate(
                          angle:
                              -controller.ellipse2Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 98,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: controller.ellipse3Animation,
                    builder: (context, child) {
                      return Positioned(
                        top: 17,
                        left: 24,
                        child: Transform.rotate(
                          angle:
                              controller.ellipse3Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 98,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Microphone icon
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recording... Tap to stop',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    ChatController controller,
    TextEditingController textController,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE5E5E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Camera and Gallery icons
          GestureDetector(
            onTap: () => controller.captureImage(),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.selectImage(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          // Text input
          Expanded(
            child: Obx(
              () => TextField(
                controller: textController,
                onChanged: (value) => controller.inputText.value = value,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.sendMessage();
                    textController.clear();
                    controller.inputText.value = '';
                  }
                },
                enabled: !controller.isLoading.value,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppColors.primary500,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send/Voice button
          Obx(
            () => GestureDetector(
              onTap:
                  controller.isLoading.value
                      ? null
                      : () {
                        if (controller.inputText.value.trim().isNotEmpty) {
                          controller.sendMessage();
                          textController.clear();
                          controller.inputText.value = '';
                        } else {
                          controller.handleVoicePress();
                        }
                      },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary500, AppColors.primary600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          controller.inputText.value.trim().isNotEmpty
                              ? Icons.send
                              : Icons.mic,
                          color: Colors.white,
                          size: 22,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

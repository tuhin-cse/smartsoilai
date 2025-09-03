import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isRecording.value) {
                  return _buildRecordingState(controller);
                } else if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return _buildMessagesList(controller, authController);
                }
              }),
            ),
            Obx(() {
              if (!controller.isRecording.value) {
                return _buildInputSection(controller);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Soil AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 38),
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
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'How Can I help You?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tell me what you need crop advice, soil test help, or pest diagnosis. I\'ve got you covered!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatController controller, AuthController authController) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return _buildMessageItem(message, authController);
            },
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

  Widget _buildMessageItem(ChatMessage message, AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary100,
                child: Image.asset(
                  'assets/icons/ai_avatar.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? 'Me' : 'Soilsense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: message.isUser 
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
                            color: AppColors.textPrimary,
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
              margin: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary100,
                backgroundImage: authController.profileImage != null
                    ? NetworkImage(authController.profileImage!)
                    : null,
                child: authController.profileImage == null
                    ? Image.asset(
                        'assets/icons/user.png',
                        width: 24,
                        height: 24,
                      )
                    : null,
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
                          angle: controller.ellipse1Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 97,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(alpha: 0.6),
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
                          angle: -controller.ellipse2Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 98,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(alpha: 0.4),
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
                          angle: controller.ellipse3Animation.value * 2 * 3.14159,
                          child: Container(
                            width: 98,
                            height: 105,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(alpha: 0.3),
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
            const Text(
              'Recording... Tap to stop',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.captureImage(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xFF435862),
                size: 24,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.selectImage(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.image,
                color: Color(0xFF435862),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Obx(() => TextField(
              onChanged: (value) => controller.inputText.value = value,
              onSubmitted: (_) => controller.sendMessage(),
              enabled: !controller.isLoading.value,
              decoration: InputDecoration(
                hintText: 'Write Here',
                hintStyle: const TextStyle(color: Color(0xFF999999)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primary500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            )),
          ),
          const SizedBox(width: 12),
          Obx(() => GestureDetector(
            onTap: controller.isLoading.value ? null : () => controller.handleVoicePress(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary500,
                shape: BoxShape.circle,
              ),
              child: controller.isLoading.value
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
                      size: 20,
                    ),
            ),
          )),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../repositories/exceptions/api_exception.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String messageType;
  final String? imageUri;
  final String? conversationId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.messageType = 'text',
    this.imageUri,
    this.conversationId,
  });
}

class ChatController extends GetxController with GetTickerProviderStateMixin {
  final ChatRepository _chatRepository = ChatRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  // Observable variables
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxString inputText = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;
  final RxString currentConversationId = ''.obs;

  // Animation controllers
  late AnimationController ellipse1Controller;
  late AnimationController ellipse2Controller;
  late AnimationController ellipse3Controller;
  late Animation<double> ellipse1Animation;
  late Animation<double> ellipse2Animation;
  late Animation<double> ellipse3Animation;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeAudioRecorder();
  }

  void _initializeAnimations() {
    ellipse1Controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    ellipse2Controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    ellipse3Controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    ellipse1Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: ellipse1Controller, curve: Curves.linear),
    );
    ellipse2Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: ellipse2Controller, curve: Curves.linear),
    );
    ellipse3Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: ellipse3Controller, curve: Curves.linear),
    );
  }

  Future<void> _initializeAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      // Handle error silently in production
      if (kDebugMode) {
        print('Error initializing audio recorder: $e');
      }
    }
  }

  void _startRecordingAnimations() {
    ellipse1Controller.repeat();
    ellipse2Controller.repeat(reverse: true);
    ellipse3Controller.repeat();
  }

  void _stopRecordingAnimations() {
    ellipse1Controller.stop();
    ellipse2Controller.stop();
    ellipse3Controller.stop();
  }

  /// Get conversation history for API calls
  List<ConversationHistoryDto> getConversationHistory() {
    return messages
        .map(
          (msg) => ConversationHistoryDto(
            role: msg.isUser ? 'user' : 'assistant',
            content: msg.message,
          ),
        )
        .toList();
  }

  /// Send text message to AI
  Future<void> sendMessage() async {
    final text = inputText.value.trim();
    if (text.isEmpty || isLoading.value) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: 'text',
      conversationId: currentConversationId.value,
    );

    messages.add(userMessage);
    inputText.value = '';
    isLoading.value = true;

    try {
      // Show processing feedback
      Get.snackbar(
        'Sending Message',
        'Getting AI response...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 1),
      );

      final chatMessageDto = ChatMessageDto(
        conversationId:
            currentConversationId.value.isEmpty
                ? null
                : currentConversationId.value,
        message: text,
        messageType: ChatMessageType.text,
        conversationHistory: getConversationHistory(),
      );

      final response = await _chatRepository.sendMessage(chatMessageDto);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        message: response.message,
        isUser: false,
        timestamp: DateTime.parse(response.timestamp),
        messageType: response.messageType,
        conversationId: response.conversationId,
      );

      messages.add(aiMessage);
      currentConversationId.value = response.conversationId;
    } on ApiException catch (e) {
      _handleError('Failed to send message: ${e.message}');
    } catch (e) {
      _handleError('Failed to send message. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle image capture from camera
  Future<void> captureImage() async {
    try {
      // Directly try to open camera - system will handle permissions automatically
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      // If camera access fails, check if it's a permission issue
      final status = await Permission.camera.status;
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          'Camera Permission Required',
          'Camera access is needed to take photos for soil analysis. Please enable camera permission in app settings.',
          Permission.camera,
        );
      } else {
        _handleError(
          'Failed to access camera. Please check your camera settings and try again.',
        );
      }
    }
  }

  /// Handle image selection from gallery
  Future<void> selectImage() async {
    try {
      // Directly try to open gallery - system will handle permissions automatically
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      // If gallery access fails, check if it's a permission issue
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photos.status;
      } else {
        status = await Permission.storage.status;
      }

      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          'Gallery Permission Required',
          'Photo library access is needed to select images for soil analysis. Please enable gallery permission in app settings.',
          Platform.isIOS ? Permission.photos : Permission.storage,
        );
      } else {
        _handleError(
          'Failed to access photo library. Please check your gallery settings and try again.',
        );
      }
    }
  }

  /// Show permission dialog with option to open app settings
  Future<void> _showPermissionDialog(
    String title,
    String message,
    Permission permission,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (result == true) {
      await openAppSettings();
    }
  }

  /// Process and send image to AI
  Future<void> _processImage(XFile image) async {
    try {
      // Show processing feedback
      Get.snackbar(
        'Processing Image',
        'Analyzing your soil sample...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 2),
      );

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: '📷 Image uploaded for soil analysis',
        isUser: true,
        timestamp: DateTime.now(),
        messageType: 'image_analysis',
        imageUri: image.path,
        conversationId: currentConversationId.value,
      );

      messages.add(userMessage);
      isLoading.value = true;

      final chatMessageDto = ChatMessageDto(
        conversationId:
            currentConversationId.value.isEmpty
                ? null
                : currentConversationId.value,
        imageBase64: base64Image,
        messageType: ChatMessageType.image,
        conversationHistory: getConversationHistory(),
      );

      final response = await _chatRepository.sendMessage(chatMessageDto);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        message: response.message,
        isUser: false,
        timestamp: DateTime.parse(response.timestamp),
        messageType: response.messageType,
        conversationId: response.conversationId,
      );

      messages.add(aiMessage);
      currentConversationId.value = response.conversationId;

      // Show success feedback
      Get.snackbar(
        'Analysis Complete',
        'Soil analysis completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );
    } on ApiException catch (e) {
      _handleError('Failed to analyze image: ${e.message}');
    } catch (e) {
      _handleError(
        'Failed to analyze image. Please check your internet connection and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start voice recording
  Future<void> startRecording() async {
    try {
      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final audioPath = '${tempDir.path}/audio_message.aac';

      await _audioRecorder.startRecorder(
        toFile: audioPath,
        codec: Codec.aacADTS,
      );

      isRecording.value = true;
      _startRecordingAnimations();

      // Show recording feedback
      Get.snackbar(
        'Recording Started',
        'Tap the microphone button again to stop recording',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // If recording fails, check if it's a permission issue
      final status = await Permission.microphone.status;
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          'Microphone Permission Required',
          'Microphone access is needed to record voice messages. Please enable microphone permission in app settings.',
          Permission.microphone,
        );
      } else {
        _handleError(
          'Failed to start recording. Please check your microphone settings and try again.',
        );
      }
    }
  }

  /// Stop voice recording and send to AI
  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stopRecorder();
      isRecording.value = false;
      _stopRecordingAnimations();

      if (path != null) {
        final audioFile = File(path);
        if (await audioFile.exists()) {
          final bytes = await audioFile.readAsBytes();
          final base64Audio = base64Encode(bytes);

          final userMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message: '🎤 Voice message recorded',
            isUser: true,
            timestamp: DateTime.now(),
            messageType: 'voice_response',
            conversationId: currentConversationId.value,
          );

          messages.add(userMessage);
          isLoading.value = true;

          // Show processing feedback
          Get.snackbar(
            'Processing Voice',
            'Transcribing and analyzing your voice message...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.shade100,
            colorText: Colors.blue.shade800,
            duration: const Duration(seconds: 2),
          );

          final chatMessageDto = ChatMessageDto(
            conversationId:
                currentConversationId.value.isEmpty
                    ? null
                    : currentConversationId.value,
            audioBase64: base64Audio,
            messageType: ChatMessageType.voice,
            conversationHistory: getConversationHistory(),
          );

          final response = await _chatRepository.sendMessage(chatMessageDto);

          final aiMessage = ChatMessage(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            message: response.message,
            isUser: false,
            timestamp: DateTime.parse(response.timestamp),
            messageType: response.messageType,
            conversationId: response.conversationId,
          );

          messages.add(aiMessage);
          currentConversationId.value = response.conversationId;

          // Show success feedback
          Get.snackbar(
            'Voice Processed',
            'Voice message processed successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          );

          // Clean up audio file
          await audioFile.delete();
        }
      }
    } on ApiException catch (e) {
      _handleError('Failed to process voice message: ${e.message}');
    } catch (e) {
      _handleError('Failed to process voice message. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle voice button press (send text or start recording)
  void handleVoicePress() {
    if (inputText.value.trim().isNotEmpty) {
      sendMessage();
    } else {
      startRecording();
    }
  }

  /// Handle error messages
  void _handleError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  @override
  void onClose() {
    ellipse1Controller.dispose();
    ellipse2Controller.dispose();
    ellipse3Controller.dispose();
    _audioRecorder.closeRecorder();
    super.onClose();
  }
}

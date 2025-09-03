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
    return messages.map((msg) => ConversationHistoryDto(
      role: msg.isUser ? 'user' : 'assistant',
      content: msg.message,
    )).toList();
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
      final chatMessageDto = ChatMessageDto(
        conversationId: currentConversationId.value.isEmpty ? null : currentConversationId.value,
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
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Required', 'Please grant camera permissions to use this feature.');
        return;
      }

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
      _handleError('Failed to capture image. Please try again.');
    }
  }

  /// Handle image selection from gallery
  Future<void> selectImage() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Required', 'Please grant photo library permissions to use this feature.');
        return;
      }

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
      _handleError('Failed to select image. Please try again.');
    }
  }

  /// Process and send image to AI
  Future<void> _processImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Image uploaded for analysis',
        isUser: true,
        timestamp: DateTime.now(),
        messageType: 'image_analysis',
        imageUri: image.path,
        conversationId: currentConversationId.value,
      );

      messages.add(userMessage);
      isLoading.value = true;

      final chatMessageDto = ChatMessageDto(
        conversationId: currentConversationId.value.isEmpty ? null : currentConversationId.value,
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
    } on ApiException catch (e) {
      _handleError('Failed to analyze image: ${e.message}');
    } catch (e) {
      _handleError('Failed to analyze image. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Start voice recording
  Future<void> startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Required', 'Please grant microphone permissions to use this feature.');
        return;
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final audioPath = '${tempDir.path}/audio_message.aac';

      await _audioRecorder.startRecorder(
        toFile: audioPath,
        codec: Codec.aacADTS,
      );
      
      isRecording.value = true;
      _startRecordingAnimations();
    } catch (e) {
      _handleError('Failed to start recording. Please try again.');
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
            message: 'Voice message recorded',
            isUser: true,
            timestamp: DateTime.now(),
            messageType: 'voice_response',
            conversationId: currentConversationId.value,
          );

          messages.add(userMessage);
          isLoading.value = true;

          final chatMessageDto = ChatMessageDto(
            conversationId: currentConversationId.value.isEmpty ? null : currentConversationId.value,
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
      backgroundColor: Colors.red,
      colorText: Colors.white,
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

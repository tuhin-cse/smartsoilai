import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/profile_shimmer.dart';
import 'package:smartsoilai/widgets/simple_image_picker_bottom_sheet.dart';
import '../controllers/profile_controller.dart';
import '../services/user_service.dart';
import '../widgets/input.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets safeAreaInsets = mediaQuery.padding;
    final EdgeInsets viewInsets = mediaQuery.viewInsets;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetX<ProfileController>(
        init: ProfileController(),
        builder:
            (controller) =>
                controller.isLoading.value
                    ? const ProfileShimmer()
                    : Column(
                      children: [
                        // Header with back button
                        Container(
                          padding: EdgeInsets.only(
                            top: safeAreaInsets.top + 16,
                            left: 20,
                            right: 20,
                            bottom: 16,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Row(
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE3F8CF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: Color(0xFF435C5C),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Your Profile',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F1F1F),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 38), // For symmetry
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: viewInsets.bottom + 20,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    // Profile Image Section
                                    Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFE8EBF0),
                                              width: 4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              60,
                                            ),
                                            child: Obx(() {
                                              // Show selected local image if available
                                              if (controller
                                                      .profileImagePath
                                                      .value !=
                                                  null) {
                                                return Image.file(
                                                  File(
                                                    controller
                                                        .profileImagePath
                                                        .value!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                );
                                              }

                                              // Show network image from user service
                                              final userService =
                                                  UserService.to;
                                              if (userService
                                                  .profileImage
                                                  .isNotEmpty) {
                                                return Image.network(
                                                  userService.profileImage,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Image.asset(
                                                      'assets/images/icon.png',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                );
                                              }

                                              // Default image
                                              return Image.asset(
                                                'assets/images/icon.png',
                                                fit: BoxFit.cover,
                                              );
                                            }),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 8,
                                          child: Obx(
                                            () => GestureDetector(
                                              onTap:
                                                  controller
                                                          .isImageUploading
                                                          .value
                                                      ? null
                                                      : () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          isScrollControlled:
                                                              true,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => SimpleImagePickerBottomSheet(
                                                                onImageSelected:
                                                                    controller
                                                                        .onImageSelected,
                                                              ),
                                                        );
                                                      },
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color:
                                                      controller
                                                              .isImageUploading
                                                              .value
                                                          ? Colors.grey
                                                          : const Color(
                                                            0xFF62BE24,
                                                          ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 3,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.15),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child:
                                                    controller
                                                            .isImageUploading
                                                            .value
                                                        ? const SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                        : const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 40),

                                    // Form Fields
                                    Form(
                                      child: Column(
                                        children: [
                                          // Name Field
                                          CustomFormField(
                                            label: 'Full Name',
                                            hintText: 'Enter your full name',
                                            leftIcon: Icons.person_outline,
                                            controller:
                                                controller.nameController,
                                            keyboardType: TextInputType.name,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your full name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          // Email Field
                                          CustomFormField(
                                            label: 'Email Address',
                                            hintText: 'example@email.com',
                                            leftIcon: Icons.email_outlined,
                                            controller:
                                                controller.emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!GetUtils.isEmail(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          /* const SizedBox(height: 20),

                                          // Phone Field
                                          CustomFormField(
                                            label: 'Phone Number',
                                            hintText: '+880 1234 567890',
                                            leftIcon: Icons.phone_outlined,
                                            controller:
                                                controller.phoneController,
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your phone number';
                                              }
                                              return null;
                                            },
                                          ), */
                                          const SizedBox(height: 20),

                                          // Gender Dropdown
                                          CustomFormPickerField<String>(
                                            label: 'Gender',
                                            hintText: 'Select your gender',
                                            options: const [
                                              PickerOption(
                                                value: 'Male',
                                                label: 'Male',
                                                icon: Icon(
                                                  Icons.male,
                                                  size: 20,
                                                ),
                                              ),
                                              PickerOption(
                                                value: 'Female',
                                                label: 'Female',
                                                icon: Icon(
                                                  Icons.female,
                                                  size: 20,
                                                ),
                                              ),
                                              PickerOption(
                                                value: 'Other',
                                                label: 'Other',
                                                icon: Icon(
                                                  Icons.person,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                            initialValue:
                                                controller
                                                        .genderController
                                                        .value
                                                        .isEmpty
                                                    ? null
                                                    : controller
                                                        .genderController
                                                        .value,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select your gender';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              controller.updateGender(
                                                value ?? '',
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 40),

                                    // Update Button
                                    Obx(
                                      () => SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed:
                                              !controller
                                                          .isButtonEnabled
                                                          .value ||
                                                      controller.isLoading.value
                                                  ? null
                                                  : controller.updateProfile,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                !controller
                                                        .isButtonEnabled
                                                        .value
                                                    ? Colors.grey.shade300
                                                    : const Color(0xFF62BE24),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            shadowColor: const Color(
                                              0xFF62BE24,
                                            ).withOpacity(0.3),
                                          ),
                                          child:
                                              controller.isUpdateLoading.value
                                                  ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : const Text(
                                                    'Update Profile',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Last Updated
                    _buildLastUpdated(),
                    
                    // Introduction
                    _buildSection(
                      title: null,
                      content: 'Smart Soil AI ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by Smart Soil AI.',
                    ),
                    
                    // Information We Collect
                    _buildInformationWeCollectSection(),
                    
                    // How We Use Your Information
                    _buildSection(
                      title: 'How We Use Your Information',
                      content: 'We use the information we collect to:\n\n• Provide and improve our soil analysis services\n• Personalize your experience with relevant recommendations\n• Send you important updates about our services\n• Respond to your questions and provide customer support\n• Ensure the security and integrity of our platform\n• Comply with legal obligations',
                    ),
                    
                    // Information Sharing
                    _buildSection(
                      title: 'Information Sharing and Disclosure',
                      content: 'We do not sell, trade, or otherwise transfer your personal information to third parties except in the following circumstances:\n\n• With your explicit consent\n• To comply with legal requirements or court orders\n• To protect our rights, property, or safety\n• With trusted service providers who assist us in operating our app (under strict confidentiality agreements)',
                    ),
                    
                    // Data Security
                    _buildSection(
                      title: 'Data Security',
                      content: 'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n• Encryption of data in transit and at rest\n• Regular security assessments\n• Access controls and authentication\n• Secure data storage practices',
                    ),
                    
                    // Data Retention
                    _buildSection(
                      title: 'Data Retention',
                      content: 'We retain your personal information only for as long as necessary to provide our services and fulfill the purposes outlined in this policy. You can request deletion of your account and associated data at any time through the app settings.',
                    ),
                    
                    // Your Rights
                    _buildSection(
                      title: 'Your Rights',
                      content: 'You have the right to:\n\n• Access and update your personal information\n• Request deletion of your account and data\n• Opt-out of non-essential communications\n• Request a copy of your data\n• Withdraw consent for data processing',
                    ),
                    
                    // Third-Party Services
                    _buildSection(
                      title: 'Third-Party Services',
                      content: 'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies before providing any personal information.',
                    ),
                    
                    // Children's Privacy
                    _buildSection(
                      title: 'Children\'s Privacy',
                      content: 'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
                    ),
                    
                    // Changes to Privacy Policy
                    _buildSection(
                      title: 'Changes to This Privacy Policy',
                      content: 'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy periodically for any changes.',
                    ),
                    
                    // Contact Information
                    _buildSection(
                      title: 'Contact Us',
                      content: 'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: info.us@softxmind.com\nAddress: Beijing, China\nPhone: +86 186 01 21 40 93',
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF435862),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Privacy Policy',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40), // For symmetry
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.month}/${currentDate.day}/${currentDate.year}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Last updated: $formattedDate',
        style: const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection({String? title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationWeCollectSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information We Collect',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Personal Information subsection
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Email address and password for account creation\n• Full name and gender (optional)\n• Profile picture (optional)\n• Location data for soil analysis (with your permission)',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Usage Information subsection
          const Text(
            'Usage Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Soil analysis requests and results\n• Chat conversations with our AI assistant\n• App usage patterns and preferences\n• Device information and operating system',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
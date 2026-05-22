import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_picker_widget.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  List<File> _selectedFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isLoading = true);
      
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      
      final newComplaint = ComplaintModel(
        id: const Uuid().v4(),
        refId: Helpers.generateRefId(),
        userId: auth.user?.uid ?? 'unknown',
        userName: auth.user?.name ?? 'Anonymous',
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        statusHistory: [
          StatusHistoryEntry(
            status: 'pending',
            timestamp: DateTime.now(),
            note: 'Complaint received and awaiting initial review.',
          ),
        ],
      );

      await complaintProvider.submitComplaint(newComplaint, images: _selectedFiles);
      
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, AppStrings.complaintSubmitted);
        Navigator.pop(context);
      }
    } else if (_selectedCategory == null) {
      Helpers.showSnackBar(context, 'Please select a category', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceLight,
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.submitComplaint, style: AppStyles.heading2),
              const SizedBox(height: 8),
              Text(AppStrings.submitComplaintSubtitle, style: AppStyles.subtitle),
              const SizedBox(height: 32),

              // Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(AppStrings.category, style: AppStyles.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text(AppStrings.selectCategory),
                      decoration: AppStyles.inputDecoration(label: ''),
                      items: AppStrings.categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(AppStrings.complaintTitle, style: AppStyles.labelLarge),
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: '',
                      hint: AppStrings.titlePlaceholder,
                      controller: _titleController,
                      validator: (val) => Validators.validateRequired(val, 'Title'),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(AppStrings.description, style: AppStyles.labelLarge),
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: '',
                      hint: AppStrings.descriptionPlaceholder,
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: Validators.validateDescription,
                    ),
                    const SizedBox(height: 24),

                    // File Picker
                    Text(AppStrings.supportingDocuments, style: AppStyles.labelLarge),
                    const SizedBox(height: 12),
                    ImagePickerWidget(onImagesSelected: (images) {
                      setState(() => _selectedFiles = images);
                    }),
                    const SizedBox(height: 8),
                    Text(AppStrings.maxFiles, style: AppStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: AppStrings.submitButton,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 24),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppStyles.bodySmall,
                    children: [
                      const TextSpan(text: 'By submitting, you agree to our '),
                      TextSpan(
                        text: 'Terms of Resolution',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  
  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<ComplaintModel> get filteredComplaints {
    return _complaints.where((c) {
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            c.refId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Summary Stats
  int get totalCount => _complaints.length;
  int get pendingCount => _complaints.where((c) => c.status == 'pending').length;
  int get inProgressCount => _complaints.where((c) => c.status == 'in_progress').length;
  int get resolvedCount => _complaints.where((c) => c.status == 'resolved').length;

  void fetchComplaints({String? userId}) {
    _isLoading = true;
    _complaintService.getComplaints(userId: userId).listen((data) {
      _complaints = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> submitComplaint(ComplaintModel complaint, {List<File>? images}) async {
    await _complaintService.submitComplaint(complaint, images: images);
    // Stream will auto-update if real Firestore is used
  }

  Future<void> updateStatus(String id, String status, String note) async {
    await _complaintService.updateComplaintStatus(id, status, note);
  }

  Future<void> addResponse(String id, AdminResponse response) async {
    await _complaintService.addAdminResponse(id, response);
  }
}

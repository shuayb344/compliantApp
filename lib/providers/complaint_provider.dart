import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  StreamSubscription? _subscription;

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;

  List<ComplaintModel> get filteredComplaints {
    return _complaints.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesStatus =
          _selectedStatus == 'All' || c.status == _selectedStatus.toLowerCase().replaceAll(' ', '_');
      final matchesSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.refId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  // Summary Stats
  int get totalCount => _complaints.length;
  int get pendingCount => _complaints.where((c) => c.status == 'pending').length;
  int get inProgressCount =>
      _complaints.where((c) => c.status == 'in_progress').length;
  int get resolvedCount =>
      _complaints.where((c) => c.status == 'resolved').length;

  void fetchComplaints({String? userId}) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription =
        _complaintService.getComplaints(userId: userId).listen((data) {
      _complaints = data;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _error = 'Failed to load complaints. Please try again.';
      notifyListeners();
      debugPrint('Error fetching complaints: $error');
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> submitComplaint(ComplaintModel complaint,
      {List<File>? images}) async {
    try {
      await _complaintService.submitComplaint(complaint, images: images);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status, String note) async {
    try {
      await _complaintService.updateComplaintStatus(id, status, note);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addResponse(String id, AdminResponse response) async {
    try {
      await _complaintService.addAdminResponse(id, response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _complaintService.deleteComplaint(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Feedback Portal';
  static const String appTagline = 'Sign in to manage your submissions';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot?';
  static const String continueWithSSO = 'Continue with SSO';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String emailPlaceholder = 'name@company.com';
  static const String passwordPlaceholder = '••••••••';
  static const String orDivider = 'OR';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String support = 'Support';
  static const String user = 'User';
  static const String admin = 'Admin';

  // User Home
  static const String welcomeBack = 'Welcome back,';
  static const String hello = 'Hello, ';
  static const String totalReports = 'TOTAL REPORTS';
  static const String pendingLabel = 'PENDING';
  static const String resolvedLabel = 'RESOLVED';
  static const String inProgressLabel = 'IN PROGRESS';
  static const String tasks = 'tasks';
  static const String closed = 'closed';
  static const String recentComplaints = 'Recent Complaints';
  static const String seeAll = 'See all';

  // Admin Dashboard
  static const String executiveOverview = 'Executive Overview';
  static const String executiveOverviewSubtitle =
      'Review and manage organizational feedback requests.';
  static const String total = 'TOTAL';
  static const String searchComplaints = 'Search complaints...';
  static const String all = 'All';
  static const String billing = 'Billing';
  static const String technical = 'Technical';
  static const String service = 'Service';
  static const String infrastructure = 'Infrastructure';

  // Submit Complaint
  static const String submitComplaint = 'Submit Complaint';
  static const String submitComplaintSubtitle =
      'Please provide as much detail as possible so we can resolve your issue quickly.';
  static const String category = 'Category';
  static const String selectCategory = 'Select a category';
  static const String complaintTitle = 'Complaint Title';
  static const String titlePlaceholder = 'Briefly describe the issue';
  static const String description = 'Description';
  static const String descriptionPlaceholder =
      'Tell us what happened in detail...';
  static const String descriptionHint = descriptionPlaceholder;
  static const String attachImages = 'Attach Images';
  static const String tellUsWhatHappened = 'Tell us what happened';
  static const String submitDetailSubtitle = submitComplaintSubtitle;
  static const String submitNewComplaint = 'Submit New Complaint';
  static const String supportingDocuments = 'Supporting Documents (Optional)';
  static const String maxFiles = 'Maximum 3 files. JPG or PNG only.';
  static const String add = 'Add';
  static const String submitButton = 'Submit Complaint';
  static const String termsAgreement =
      'By submitting, you agree to our Terms of Resolution.';

  // Complaint Detail
  static const String fullDescription = 'FULL DESCRIPTION';
  static const String statusHistory = 'STATUS HISTORY';
  static const String officialAdminResponse = 'OFFICIAL ADMIN RESPONSE';
  static const String verified = 'Verified';
  static const String submittedOn = 'Submitted on ';

  // Notifications
  static const String recentAlerts = 'Recent Alerts';
  static const String alertsSubtitle =
      'Stay updated with your complaint status';
  static const String markAllAsRead = 'Mark all as read';
  static const String allCaughtUp = 'All caught up!';
  static const String noUnreadNotifications =
      'You have no unread notifications left for today.';
  static const String yesterday = 'YESTERDAY';

  // Status
  static const String pending = 'PENDING';
  static const String inProgress = 'IN PROGRESS';
  static const String resolved = 'RESOLVED';

  // Categories list
  static const List<String> categories = [
    billing,
    technical,
    service,
    infrastructure,
  ];

  // Bottom Nav
  static const String home = 'Home';
  static const String complaints = 'Complaints';
  static const String alerts = 'Alerts';
  static const String profile = 'Profile';

  // Admin Actions
  static const String updateStatus = 'Update Status';
  static const String respondToComplaint = 'Respond to Complaint';
  static const String writeResponse = 'Write your official response...';
  static const String submitResponse = 'Submit Response';

  // Profile
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String signOut = 'Sign Out';
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String helpCenter = 'Help Center';
  static const String aboutApp = 'About App';
  static const String version = 'Version 1.0.0';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordShort =
      'Password must be at least 6 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorFieldRequired = 'This field is required.';
  static const String errorLoginFailed = 'Invalid email or password.';

  // Success
  static const String complaintSubmitted =
      'Your complaint has been submitted successfully!';
  static const String responseSubmitted = 'Your response has been submitted.';
  static const String statusUpdated = 'Status has been updated.';
}

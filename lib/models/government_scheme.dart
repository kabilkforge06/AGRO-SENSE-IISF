/// Represents a government scheme for farmers
class GovernmentScheme {
  final String id;
  final String name;
  final String description;
  final String category; // Financial Aid, Machinery Subsidy, Irrigation, etc.
  final String type; // Central, State, District
  final List<String> states;
  final List<String> districts;
  final Map<String, dynamic> eligibilityCriteria;
  final double? subsidyPercentage;
  final double? maxSubsidyAmount;
  final double? minSubsidyAmount;
  final List<String> requiredDocuments;
  final List<ApplicationStep> applicationSteps;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final String? applicationUrl;
  final String? helplineNumber;
  final String? officialWebsite;
  final bool isActive;
  final DateTime lastUpdated;
  final Map<String, dynamic>? subsidyCalculatorParams;
  final List<String> benefitDetails;
  final String? departmentName;
  final Map<String, String>? additionalInfo;

  GovernmentScheme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.states,
    this.districts = const [],
    required this.eligibilityCriteria,
    this.subsidyPercentage,
    this.maxSubsidyAmount,
    this.minSubsidyAmount,
    this.requiredDocuments = const [],
    this.applicationSteps = const [],
    this.startDate,
    this.expiryDate,
    this.applicationUrl,
    this.helplineNumber,
    this.officialWebsite,
    this.isActive = true,
    required this.lastUpdated,
    this.subsidyCalculatorParams,
    this.benefitDetails = const [],
    this.departmentName,
    this.additionalInfo,
  });

  /// Check if scheme is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Check if scheme has expired
  bool get hasExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Get days remaining until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Check if scheme is available in a specific state
  bool isAvailableInState(String state) {
    return states.isEmpty || states.contains(state) || states.contains('All');
  }

  /// Check if scheme is available in a specific district
  bool isAvailableInDistrict(String state, String district) {
    if (!isAvailableInState(state)) return false;
    return districts.isEmpty || districts.contains(district);
  }

  /// Convert to MongoDB document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'type': type,
      'states': states,
      'districts': districts,
      'eligibilityCriteria': eligibilityCriteria,
      'subsidyPercentage': subsidyPercentage,
      'maxSubsidyAmount': maxSubsidyAmount,
      'minSubsidyAmount': minSubsidyAmount,
      'requiredDocuments': requiredDocuments,
      'applicationSteps': applicationSteps.map((step) => step.toMap()).toList(),
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'applicationUrl': applicationUrl,
      'helplineNumber': helplineNumber,
      'officialWebsite': officialWebsite,
      'isActive': isActive,
      'lastUpdated': lastUpdated.toIso8601String(),
      'subsidyCalculatorParams': subsidyCalculatorParams,
      'benefitDetails': benefitDetails,
      'departmentName': departmentName,
      'additionalInfo': additionalInfo,
    };
  }

  /// Create from MongoDB document
  factory GovernmentScheme.fromMap(Map<String, dynamic> data) {
    return GovernmentScheme(
      id: data['_id']?.toString() ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      states: List<String>.from(data['states'] ?? []),
      districts: List<String>.from(data['districts'] ?? []),
      eligibilityCriteria: Map<String, dynamic>.from(
        data['eligibilityCriteria'] ?? {},
      ),
      subsidyPercentage: data['subsidyPercentage']?.toDouble(),
      maxSubsidyAmount: data['maxSubsidyAmount']?.toDouble(),
      minSubsidyAmount: data['minSubsidyAmount']?.toDouble(),
      requiredDocuments: List<String>.from(data['requiredDocuments'] ?? []),
      applicationSteps:
          (data['applicationSteps'] as List<dynamic>?)
              ?.map((step) => ApplicationStep.fromMap(step))
              .toList() ??
          [],
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : null,
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'])
          : null,
      applicationUrl: data['applicationUrl'],
      helplineNumber: data['helplineNumber'],
      officialWebsite: data['officialWebsite'],
      isActive: data['isActive'] ?? true,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
      subsidyCalculatorParams: data['subsidyCalculatorParams'] != null
          ? Map<String, dynamic>.from(data['subsidyCalculatorParams'])
          : null,
      benefitDetails: List<String>.from(data['benefitDetails'] ?? []),
      departmentName: data['departmentName'],
      additionalInfo: data['additionalInfo'] != null
          ? Map<String, String>.from(data['additionalInfo'])
          : null,
    );
  }

  GovernmentScheme copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? type,
    List<String>? states,
    List<String>? districts,
    Map<String, dynamic>? eligibilityCriteria,
    double? subsidyPercentage,
    double? maxSubsidyAmount,
    double? minSubsidyAmount,
    List<String>? requiredDocuments,
    List<ApplicationStep>? applicationSteps,
    DateTime? startDate,
    DateTime? expiryDate,
    String? applicationUrl,
    String? helplineNumber,
    String? officialWebsite,
    bool? isActive,
    DateTime? lastUpdated,
    Map<String, dynamic>? subsidyCalculatorParams,
    List<String>? benefitDetails,
    String? departmentName,
    Map<String, String>? additionalInfo,
  }) {
    return GovernmentScheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      states: states ?? this.states,
      districts: districts ?? this.districts,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      subsidyPercentage: subsidyPercentage ?? this.subsidyPercentage,
      maxSubsidyAmount: maxSubsidyAmount ?? this.maxSubsidyAmount,
      minSubsidyAmount: minSubsidyAmount ?? this.minSubsidyAmount,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      applicationSteps: applicationSteps ?? this.applicationSteps,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      helplineNumber: helplineNumber ?? this.helplineNumber,
      officialWebsite: officialWebsite ?? this.officialWebsite,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      subsidyCalculatorParams:
          subsidyCalculatorParams ?? this.subsidyCalculatorParams,
      benefitDetails: benefitDetails ?? this.benefitDetails,
      departmentName: departmentName ?? this.departmentName,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

/// Represents a step in the application process
class ApplicationStep {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> requiredActions;
  final String? url;

  ApplicationStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.requiredActions = const [],
    this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'requiredActions': requiredActions,
      'url': url,
    };
  }

  factory ApplicationStep.fromMap(Map<String, dynamic> map) {
    return ApplicationStep(
      stepNumber: map['stepNumber'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      requiredActions: List<String>.from(map['requiredActions'] ?? []),
      url: map['url'],
    );
  }
}

/// Eligibility check result
class EligibilityResult {
  final bool isEligible;
  final List<String> matchedCriteria;
  final List<String> unmatchedCriteria;
  final double matchPercentage;
  final String message;

  EligibilityResult({
    required this.isEligible,
    required this.matchedCriteria,
    required this.unmatchedCriteria,
    required this.matchPercentage,
    required this.message,
  });
}

/// User profile for eligibility checking
class FarmerProfile {
  final String state;
  final String district;
  final double landHolding; // in acres
  final String farmerCategory; // Small, Marginal, Large
  final double annualIncome;
  final List<String> crops;
  final bool hasAadhar;
  final bool hasBankAccount;
  final String? age;
  final String? gender;
  final bool isBPLCardHolder;
  final bool belongsToSCSTCategory;

  FarmerProfile({
    required this.state,
    required this.district,
    required this.landHolding,
    required this.farmerCategory,
    required this.annualIncome,
    required this.crops,
    this.hasAadhar = true,
    this.hasBankAccount = true,
    this.age,
    this.gender,
    this.isBPLCardHolder = false,
    this.belongsToSCSTCategory = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'district': district,
      'landHolding': landHolding,
      'farmerCategory': farmerCategory,
      'annualIncome': annualIncome,
      'crops': crops,
      'hasAadhar': hasAadhar,
      'hasBankAccount': hasBankAccount,
      'age': age,
      'gender': gender,
      'isBPLCardHolder': isBPLCardHolder,
      'belongsToSCSTCategory': belongsToSCSTCategory,
    };
  }
}

/// Subsidy calculation result
class SubsidyCalculation {
  final double totalCost;
  final double subsidyAmount;
  final double farmerContribution;
  final double subsidyPercentage;
  final Map<String, dynamic> breakdown;

  SubsidyCalculation({
    required this.totalCost,
    required this.subsidyAmount,
    required this.farmerContribution,
    required this.subsidyPercentage,
    required this.breakdown,
  });
}

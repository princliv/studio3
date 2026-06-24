class AuthUser {
  const AuthUser({
    required this.username,
    required this.name,
    required this.email,
    this.emailVerified = false,
    this.onboardingComplete = false,
    this.role,
    this.sellerEnabled = false,
  });

  final String username;
  final String name;
  final String email;
  final bool emailVerified;
  final bool onboardingComplete;
  final String? role;
  final bool sellerEnabled;

  AuthUser copyWith({
    String? username,
    String? name,
    String? email,
    bool? emailVerified,
    bool? onboardingComplete,
    String? role,
    bool? sellerEnabled,
  }) {
    return AuthUser(
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      role: role ?? this.role,
      sellerEnabled: sellerEnabled ?? this.sellerEnabled,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerified: json['emailVerified'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      role: json['role'] as String?,
      sellerEnabled: json['sellerEnabled'] as bool? ??
          json['isSeller'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'email': email,
        'emailVerified': emailVerified,
        'onboardingComplete': onboardingComplete,
        'role': role,
        'sellerEnabled': sellerEnabled,
      };
}

class UsernameCheckResult {
  const UsernameCheckResult({
    required this.available,
    this.normalized,
    this.message,
    this.suggestions = const [],
  });

  final bool available;
  final String? normalized;
  final String? message;
  final List<String> suggestions;

  factory UsernameCheckResult.fromJson(Map<String, dynamic> json) {
    return UsernameCheckResult(
      available: json['available'] as bool? ?? false,
      normalized: json['normalized'] as String?,
      message: json['message'] as String?,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

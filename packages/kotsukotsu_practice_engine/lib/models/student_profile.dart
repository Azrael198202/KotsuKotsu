class StudentProfile {
  const StudentProfile({
    required this.displayName,
    required this.schoolName,
    required this.className,
    required this.memo,
  });

  final String displayName;
  final String schoolName;
  final String className;
  final String memo;

  factory StudentProfile.empty() {
    return const StudentProfile(
      displayName: '',
      schoolName: '',
      className: '',
      memo: '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'displayName': displayName,
      'schoolName': schoolName,
      'className': className,
      'memo': memo,
    };
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      displayName: json['displayName'] as String? ?? '',
      schoolName: json['schoolName'] as String? ?? '',
      className: json['className'] as String? ?? '',
      memo: json['memo'] as String? ?? '',
    );
  }

  StudentProfile copyWith({
    String? displayName,
    String? schoolName,
    String? className,
    String? memo,
  }) {
    return StudentProfile(
      displayName: displayName ?? this.displayName,
      schoolName: schoolName ?? this.schoolName,
      className: className ?? this.className,
      memo: memo ?? this.memo,
    );
  }
}

class AttendanceReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final String? status;

  const AttendanceReportFilter({
    this.startDate,
    this.endDate,
    this.userId,
    this.status,
  });

  AttendanceReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? status,
  }) {
    return AttendanceReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

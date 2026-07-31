enum BusinessStatus {
  notContacted('Not Contacted'),
  called('Called'),
  interested('Interested'),
  booked('Booked'),
  rejected('Rejected');

  const BusinessStatus(this.label);

  final String label;

  static BusinessStatus fromString(String value) {
    return BusinessStatus.values.firstWhere(
      (s) => s.name == value || s.label == value,
      orElse: () => BusinessStatus.notContacted,
    );
  }

  BusinessStatus get next {
    final index = BusinessStatus.values.indexOf(this);
    return BusinessStatus.values[(index + 1) % BusinessStatus.values.length];
  }
}

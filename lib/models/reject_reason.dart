enum RejectReason {
  notInterested('Not Interested'),
  wrongNumber('Wrong Number'),
  alreadyHasDeveloper('Already Has a Developer'),
  noAnswer('No Answer'),
  other('Other');

  const RejectReason(this.label);

  final String label;

  static RejectReason? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final reason in RejectReason.values) {
      if (reason.name == value || reason.label == value) return reason;
    }
    return null;
  }
}

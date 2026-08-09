/// Notification channel and payload constants.
abstract final class NotificationConfig {
  static const followUpChannelId = 'outreach_follow_up';
  static const followUpChannelName = 'Follow-up Reminders';
  static const followUpChannelDescription =
      'Reminders to call back businesses you are outreach-ing';

  static const followUpPayloadPrefix = 'follow_up:';

  static String followUpPayload(int businessId) =>
      '$followUpPayloadPrefix$businessId';

  static int? businessIdFromPayload(String? payload) {
    if (payload == null || !payload.startsWith(followUpPayloadPrefix)) {
      return null;
    }
    return int.tryParse(payload.substring(followUpPayloadPrefix.length));
  }
}

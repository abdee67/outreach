# Outreach

A modern, feature-rich Customer Relationship Management (CRM) application built with Flutter, designed for managing business outreach with CSV import/export capabilities, dynamic categorization, and an intuitive mobile interface.

## Features

### CSV Management
- **Import CSV files** with dynamic column mapping
- **Smart field assignment** – map CSV headers to fixed CRM fields
- **Merge strategy** – preserves existing statuses and notes on re-import
- **Replace strategy** – overwrites existing data when needed

### Dynamic Categories
- **Auto-generated categories** with real-time business counts
- **"All Businesses"** default view at the top
- **Visual feedback** – burgundy active state for selected category
- **Header summary** displaying total businesses and booked count

### Business Management
- **Card-based layout** with clean, scannable design
- **Inline status cycling** with smooth `AnimatedSwitcher` transitions
- **Stats bar** showing key metrics at a glance
- **Full-text search** for quick business lookup
- **Status filter chips** for focused viewing
- **Swipe-to-delete** with `flutter_slidable` for quick actions

### Detail Bottom Sheet
- **One-tap calling** via `url_launcher`
- **Open in Maps** for location-based outreach
- **Auto-saving notes** – never lose important information
- **Status chip selector** for quick status updates

### Export Functionality
- **Export filtered lists** preserving statuses and notes
- **Share integration** via `share_plus` for seamless file sharing

### Design System
- **Material 3** design language
- **Custom typography** – Inter + Plus Jakarta Sans fonts
- **Warm paper background** for reduced eye strain
- **Curated color palette** via `AppColors` with consistent theming

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── business.dart                  # Business data model
│   ├── business_status.dart           # Status enumeration
│   └── csv_field.dart                 # CSV field mapping model
├── services/
│   ├── database_service.dart          # Local data persistence
│   ├── csv_service.dart              # CSV parsing logic
│   └── export_service.dart           # Data export functionality
├── screens/
│   ├── home_screen.dart              # Main business list & categories
│   └── column_mapping_screen.dart    # CSV import column mapper
├── widgets/
│   ├── app_drawer.dart               # Navigation drawer
│   ├── business_card.dart            # Business list item card
│   ├── business_detail_sheet.dart    # Bottom sheet with actions
│   └── ...                           # Additional widgets
└── theme/
    ├── app_colors.dart               # Color palette definition
    └── app_theme.dart               # Theme configuration
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.x or higher)
- Android Studio / VS Code with Flutter extensions
- iOS: Xcode (for iOS development)
- Android: Android Studio with SDK tools

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/outreach.git
   cd outreach
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
No additional configuration required.

#### iOS
Add required permissions to `ios/Runner/Info.plist`:
```xml
<key>NSContactsUsageDescription</key>
<string>This app requires contacts access for calling businesses</string>
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `file_picker` | CSV file selection |
| `csv` | CSV parsing and generation |
| `share_plus` | Export and share functionality |
| `url_launcher` | Phone calls and maps integration |
| `flutter_slidable` | Swipe actions on list items |
| `sqflite` | Local database storage |

## Usage

### Importing CSV Data
1. Tap the import button in the app bar
2. Select a CSV file from your device
3. Map CSV columns to CRM fields in the mapping screen
4. Choose merge (preserve existing) or replace strategy
5. Confirm import

### Managing Businesses
- **Search**: Use the search bar to find specific businesses
- **Filter**: Tap status chips to filter by status
- **Update Status**: Tap the status indicator on any business card to cycle through statuses
- **View Details**: Tap a business card to open the detail sheet
- **Delete**: Swipe left on any business card

### Exporting Data
1. Apply desired filters (category, status)
2. Tap the export button
3. Choose sharing method
4. CSV file includes all visible fields plus status and notes

## Customization

### Colors
Modify `lib/theme/app_colors.dart` to update the color scheme:
```dart
class AppColors {
  static const Color primary = Color(0xFF...);
  // Customize other colors here
}
```

### Typography
Font files are located in `assets/fonts/`. To change fonts:
1. Add new font files to the assets directory
2. Update `pubspec.yaml` font configuration
3. Modify `lib/theme/app_theme.dart` text themes

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter) - email@example.com

Project Link: [https://github.com/yourusername/outreach-crm](https://github.com/yourusername/outreach-crm)

---

**Built with ❤️ using Flutter**
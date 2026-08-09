# Outreach

A feature-rich Customer Relationship Management (CRM) application built with Flutter, designed for managing business outreach with CSV import/export capabilities, dynamic categorization, and an intuitive mobile interface.

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

**Built with ❤️ using Flutter**

enum CsvField {
  businessName('Business Name', required: true),
  address('Address'),
  category('Category'),
  phone('Phone'),
  latitude('Latitude'),
  longitude('Longitude'),
  googleMapsUrl('Google Maps URL'),
  skip('— Skip —');

  const CsvField(this.label, {this.required = false});

  final String label;
  final bool required;

  static const mappableFields = [
    CsvField.businessName,
    CsvField.address,
    CsvField.category,
    CsvField.phone,
    CsvField.latitude,
    CsvField.longitude,
    CsvField.googleMapsUrl,
    CsvField.skip,
  ];
}

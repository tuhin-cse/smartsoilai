class Language {
  final String id;
  final String name;
  final String nativeName;
  final String flag;
  final String languageCode;
  final String countryCode;

  const Language({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.languageCode,
    required this.countryCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

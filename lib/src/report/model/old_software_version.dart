class SoftwareVersion {
  final String key;
  final String version;

  factory SoftwareVersion.fromExcel(String key, String version) {
    return SoftwareVersion(key, version);
  }

  SoftwareVersion(this.key, this.version);
}

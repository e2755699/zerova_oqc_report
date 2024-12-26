class OldSoftwareVersion {
  final String key;
  final String version;

  factory OldSoftwareVersion.fromExcel(String key, String version) {
    return OldSoftwareVersion(key, version);
  }

  OldSoftwareVersion(this.key, this.version);
}

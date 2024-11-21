class ChargeModule {
  final String snId;

  factory ChargeModule.fromExcel(String moduleId) {
    return ChargeModule(moduleId);
  }

  ChargeModule(this.snId);
}



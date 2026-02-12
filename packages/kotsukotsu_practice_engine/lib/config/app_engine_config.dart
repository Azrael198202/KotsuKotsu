class AppEngineConfig {
  const AppEngineConfig({
    required this.questionBankBasePath,
    required this.useGradeSubdirectory,
    required this.assignmentRulesAssetPath,
  });

  final String questionBankBasePath;
  final bool useGradeSubdirectory;
  final String assignmentRulesAssetPath;
}

const appEngineConfig = AppEngineConfig(
  questionBankBasePath: 'assets/question_bank',
  useGradeSubdirectory: true,
  assignmentRulesAssetPath: 'assets/assignments/rules.json',
);

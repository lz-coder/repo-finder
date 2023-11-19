class Repo {
  const Repo({
    required this.name,
    required this.dir,
    required this.commits,
    required this.branches,
    this.currentBranch,
    required this.contributors,
  });
  final String name;
  final String dir;
  final int? commits;
  final List<String>? branches;
  final String? currentBranch;
  final List<String>? contributors;
}

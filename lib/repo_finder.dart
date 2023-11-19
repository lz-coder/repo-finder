import 'dart:io';

import 'package:git/git.dart';
import 'package:repo_finder/models/repo.dart';

Future<Repo> getRepo(String path) async {
  final String repoName = path.split('/').last;
  List<String>? contributors = [];

  late List<BranchReference>? branches;
  late BranchReference? currentBranchReference;
  late final GitDir gitDir;
  late final Map<String, Commit> commits;
  late final int commitCount;

  Repo repository;

  try {
    gitDir = await GitDir.fromExisting(path);
  } on Exception catch (err) {
    print('[ERROR]: $err');
  }

  try {
    branches = await gitDir.branches();
    currentBranchReference = await gitDir.currentBranch();
  } on Exception {
    branches = null;
    currentBranchReference = null;
  }

  try {
    commitCount = await gitDir.commitCount();
  } on Exception {
    commitCount = 0;
  }

  try {
    commits = await gitDir.commits();

    for (final Commit commit in commits.values) {
      final List<String> author = commit.author.split(' ');
      if (!contributors.contains(author[0])) {
        contributors.add(author[0]);
      }
    }
  } on ProcessException {
    contributors = null;
  }

  repository = Repo(
    name: repoName,
    dir: path,
    commits: commitCount,
    branches: branches != null
        ? List.generate(branches.length, (index) {
            return branches![index].branchName;
          })
        : null,
    currentBranch: branches != null &&
            branches.length > 1 &&
            currentBranchReference != null
        ? currentBranchReference.branchName
        : null,
    contributors: contributors,
  );

  return repository;
}

void showRepo(Repo repo) {
  print('Repo: ${repo.name}');
  print(' > commits: ${repo.commits}');
  if (repo.branches != null) {
    print(' > branches: ${repo.branches}');
  }
  if (repo.currentBranch != null) {
    print(' > currentBranch: ${repo.currentBranch}');
  }
  if (repo.contributors != null) {
    print(' > contributors: ${repo.contributors}');
  }
  print('');
}

import 'dart:io';

import 'package:chalkdart/chalk.dart';
import 'package:chalkdart/chalk_x11.dart';
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
    gitDir = await GitDir.fromExisting(path, allowSubdirectory: false);
  } on ArgumentError {
    throw ArgumentError();
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
  print(chalk.black.onSkyBlue.bold(' Repo: ${repo.name} '));
  print(' ${chalk.black.onLimeGreen.bold(' commits: ${repo.commits} ')}');
  if (repo.branches != null) {
    print(' ${chalk.black.onLimeGreen.bold(' branches: ${repo.branches} ')}');
  }
  if (repo.currentBranch != null) {
    print(
        ' ${chalk.black.onLimeGreen.bold(' currentBranch: ${repo.currentBranch} ')}');
  }
  if (repo.contributors != null) {
    print(
        ' ${chalk.black.onLimeGreen.bold(' contributors: ${repo.contributors} \n')}');
  }
}

Future<void> fetchRepos(Set<Repo> repos, List<FileSystemEntity> dirs) async {
  for (final FileSystemEntity dirInList in dirs) {
    if (dirInList is Directory) {
      if (await GitDir.isGitDir(dirInList.path)) {
        try {
          Repo repository = await getRepo(dirInList.path);
          repos.add(repository);
        } on ArgumentError {
          continue;
        }
      }
    }
  }
}

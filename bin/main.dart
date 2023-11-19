import 'dart:io';

import 'package:git/git.dart';
import 'package:repo_finder/models/repo.dart';
import 'package:repo_finder/repo_finder.dart' as repo_finder;

void main(List<String?> arguments) async {
  final dir = Directory('/home/lzcoder/Projects');
  final List<FileSystemEntity> dirList =
      await dir.list(recursive: false, followLinks: false).toList();

  final repos = <Repo>{};

  for (final FileSystemEntity dir in dirList) {
    if (dir is Directory && await GitDir.isGitDir(dir.path)) {
      Repo repository = await repo_finder.getRepo(dir.path);
      repos.add(repository);
    }
  }

  if (repos.isNotEmpty) {
    print(
        'Founded ${repos.length} ${repos.length > 1 ? 'repositories' : 'repository'} in ${dir.path}\n');
    for (final Repo repo in repos) {
      repo_finder.showRepo(repo);
    }
  }
}

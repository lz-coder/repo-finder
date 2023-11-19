import 'dart:io';

import 'package:git/git.dart';
import 'package:repo_finder/models/repo.dart';
import 'package:repo_finder/repo_finder.dart' as repo_finder;
import 'package:path/path.dart' as path;

void main(List<String?> arguments) async {
  late final Directory dir;
  List<FileSystemEntity> dirList = [];
  if (arguments.isNotEmpty) {
    dir = Directory(arguments[0]!);
  } else {
    dir = Directory.current;
  }

  try {
    dirList = await dir.list(recursive: false, followLinks: false).toList();
  } on Exception catch (err) {
    print('[ERROR]: $err');
  }

  final repos = <Repo>{};

  for (final FileSystemEntity dir in dirList) {
    try {
      if (dir is Directory && await GitDir.isGitDir(dir.path)) {
        Repo repository = await repo_finder.getRepo(dir.path);
        repos.add(repository);
      }
    } on Exception {
      print('Error');
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

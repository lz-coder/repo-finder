import 'dart:io';

import 'package:chalkdart/chalk.dart';
import 'package:repo_finder/models/repo.dart';
import 'package:repo_finder/repo_finder.dart' as repo_finder;

void main(List<String?> arguments) async {
  late final Directory dir;
  late final List<FileSystemEntity> dirList;
  final repos = <Repo>{};

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

  await repo_finder.fetchRepos(repos, dirList);

  if (repos.isNotEmpty) {
    print(chalk.black.onWhite.bold(
        ' Founded ${repos.length} ${repos.length > 1 ? 'repositories' : 'repository'} in ${dir.path} \n'));
    for (final Repo repo in repos) {
      repo_finder.showRepo(repo);
    }
  }
}

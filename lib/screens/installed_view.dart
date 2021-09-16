import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appimagepool/utils/utils.dart';
import 'package:appimagepool/providers/providers.dart';

class InstalledView extends ConsumerStatefulWidget {
  final ValueNotifier<String> searchedTerm;

  const InstalledView({Key? key, required this.searchedTerm}) : super(key: key);

  @override
  ConsumerState<InstalledView> createState() => _InstalledViewState();
}

class _InstalledViewState extends ConsumerState<InstalledView> {
  @override
  Widget build(context) {
    final downloadPath = ref.watch(downloadPathProvider);
    final listInstalled = Directory(downloadPath)
        .listSync()
        .where((element) => element.path.endsWith('.AppImage'))
        .where((element) => path.basename(element.path).toLowerCase().contains(widget.searchedTerm.value))
        .toList();
    return listInstalled.isNotEmpty
        ? ListView.builder(
            itemBuilder: (ctx, index) {
              final i = listInstalled[index];

              void removeItem() async {
                File(i.path).deleteSync();
                listInstalled.removeAt(index);
                setState(() {});
              }

              return ListTile(
                title: Text(
                  path.basenameWithoutExtension(i.path),
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyText1,
                ),
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                subtitle: Text(i.statSync().size.getFileSize()),
                trailing: IconButton(
                  onPressed: removeItem,
                  icon: const AdwaitaIcon(AdwaitaIcons.user_trash),
                ),
                onTap: () {
                  var shell = Shell().cd(path.dirname(i.path));
                  shell.run('./' + path.basename(i.path));
                },
              );
            },
            itemCount: listInstalled.length,
          )
        : Center(child: Text('No AppImage found in ' + downloadPath));
  }
}
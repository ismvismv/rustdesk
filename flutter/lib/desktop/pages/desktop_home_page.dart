import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/custom_password.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({Key? key}) : super(key: key);

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  var systemError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildIDBoard(context),
            const SizedBox(height: 20),
            buildPasswordBoard(context),
          ],
        ),
      ),
    );
  }

  Widget buildIDBoard(BuildContext context) {
    final model = gFFI.serverModel;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate("ID"),
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color
                    ?.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onDoubleTap: () {
              Clipboard.setData(ClipboardData(text: model.serverId.text));
              showToast(translate("Copied"));
            },
            child: TextFormField(
              controller: model.serverId,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
              ),
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordBoard(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          return buildPasswordBoard2(context, model);
        },
      ),
    );
  }

  Widget buildPasswordBoard2(BuildContext context, ServerModel model) {
    RxBool refreshHover = false.obs;
    final textColor = Theme.of(context).textTheme.titleLarge?.color;
    final showOneTime = model.approveMode != 'click' &&
        model.verificationMethod != kUsePermanentPassword;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate("One-time Password"),
            style: TextStyle(
                fontSize: 14, color: textColor?.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () {
                    if (showOneTime) {
                      Clipboard.setData(
                          ClipboardData(text: model.serverPasswd.text));
                      showToast(translate("Copied"));
                    }
                  },
                  child: TextFormField(
                    controller: model.serverPasswd,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              if (showOneTime)
                IconButton(
                  icon: Obx(() => Icon(
                    Icons.refresh,
                    color: refreshHover.value
                        ? textColor
                        : Color(0xFFDDDDDD),
                    size: 22,
                  )),
                  onPressed: () => bind.mainUpdateTemporaryPassword(),
                  onHover: (value) => refreshHover.value = value,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    periodic_immediate(const Duration(seconds: 1), () async {
      await gFFI.serverModel.fetchID();
      final error = await bind.mainGetError();
      if (systemError != error) {
        systemError = error;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
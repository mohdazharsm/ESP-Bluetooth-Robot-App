import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stacked/stacked.dart';

import 'serial_viewmodel.dart';

class SerialView extends StatelessWidget {
  const SerialView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SerialViewModel>.reactive(
      onModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Serial communication'),
              actions: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        model.device != null &&
                                model.connected &&
                                model.connection != null &&
                                model.connection!.isConnected
                            ? model.device!.name!
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.lightGreen),
                      ),
                    ),
                    Container(
                      child: model.connection == null ||
                              !model.connected ||
                              !model.connection!.isConnected
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.stop_screen_share,
                                color: Colors.red,
                              ),
                            )
                          : null,
                    )
                  ],
                )
              ],
            ),
            body: const _HomeBody());
      },
      viewModelBuilder: () => SerialViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<SerialViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, SerialViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const Padding(
                //   padding: EdgeInsets.only(left: 8.0, top: 8.0),
                //   child: Text(
                //     'Output:',
                //     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.35,
                        maxHeight: MediaQuery.of(context).size.height * 0.35),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: SelectableText(model.data == ""
                                ? "No incoming data"
                                : model.data),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                      child: ElevatedButton(
                        onPressed: model.clear,
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: model.onMessage,
                    decoration: const InputDecoration(
                      hintText: 'Enter message to send',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(100)),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 5.0, top: 2, bottom: 2),
                      child: IconButton(
                          onPressed: model.send,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

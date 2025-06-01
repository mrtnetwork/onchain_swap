import 'package:onchain_swap_example/app/types/types.dart';
import 'package:onchain_swap_example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/material.dart';

class BarcodeScannerIconView extends StatelessWidget {
  const BarcodeScannerIconView(this.onBarcodeScanned,
      {this.isSensitive = false, super.key});
  final StringVoid onBarcodeScanned;
  final bool isSensitive;
  @override
  Widget build(BuildContext context) {
    return WidgetConstant.sizedBox;
    // return IconButton(
    //   onPressed: () {
    //     context
    //         .to<String>(PageRouter.barcodeScanner, argruments: isSensitive)
    //         .then((s) {
    //       if (s != null) {
    //         onBarcodeScanned(s);
    //       }
    //     });
    //   },
    //   icon: const Icon(Icons.qr_code),
    // );
  }
}

part of 'package:onchain_swap_example/future/state_managment/state_managment.dart';

class LiveWidget extends LiveStatelessWidget {
  final Widget Function() builder;

  const LiveWidget(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

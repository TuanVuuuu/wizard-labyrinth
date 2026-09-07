import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:wizard/core/wl_colors.dart';
import 'package:wizard/core/wl_deploy_config.dart';
import 'package:wizard/routes/navigate.dart';

class WLWebGamePage extends StatefulWidget {
  const WLWebGamePage({super.key});

  @override
  State<WLWebGamePage> createState() => _WLWebGamePageState();
}

class _WLWebGamePageState extends State<WLWebGamePage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  WebViewController _createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(WLColors.cavernDeep)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
        ),
      )
      ..loadRequest(Uri.parse(WLDeployConfig.webGameUrl));
  }

  void _setLoading(bool isLoading) {
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WLColors.cavernDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) _buildLoading(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const ColoredBox(
      color: WLColors.cavernDeep,
      child: Center(
        child: CircularProgressIndicator(color: WLColors.mist),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: WLColors.overlayScrim,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Đóng',
              onPressed: () => WLNavigate.back(context),
              icon: const Icon(Icons.close, color: WLColors.mist),
            ),
          ),
        ),
      ),
    );
  }
}

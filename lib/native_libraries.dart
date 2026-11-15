import 'dart:io';

import 'package:bitbox_transport/bitbox_transport.dart';
import 'package:bull_sdk/bull_sdk.dart';

/// The BitBox transport initializes the shared bull_sdk bridge itself, and the
/// bridge refuses a second initialization.
Future<void> initFlutterRustBridgeDependencies() =>
    Platform.isAndroid ? BitBoxApi.initialize() : BullSdk.init();

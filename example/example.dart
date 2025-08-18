import 'dart:developer';

import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:logging/logging.dart';

/// Example usage of the Meshtastic Flutter client
void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create the client
  final client = MeshtasticClient();

  try {
    // Initialize the client (handles permissions)
    await client.initialize();
    log('Meshtastic client initialized');

    // Listen for connection state changes
    client.connectionStream.listen((status) {
      log(
        'Connection status: ${status.state} - ${status.deviceName ?? status.deviceAddress}',
      );
      if (status.errorMessage != null) {
        log('Error: ${status.errorMessage}');
      }
    });

    // Listen for incoming packets
    client.packetStream.listen((packet) {
      log(
        'Received packet from ${packet.from.toRadixString(16)}: ${packet.packetTypeDescription}',
      );

      if (packet.isTextMessage) {
        log('Text message: ${packet.textMessage}');
      }
    });

    // Listen for node updates
    client.nodeStream.listen((node) {
      log('Node update: ${node.displayName} (${node.num.toRadixString(16)})');
      log('  Status: ${node.statusDescription}');
      if (node.latitude != null && node.longitude != null) {
        log('  Position: ${node.latitude}, ${node.longitude}');
      }
    });

    // Scan for devices
    log('Scanning for Meshtastic devices...');
    bool deviceFound = false;

    await for (final device in client.scanForDevices(
      timeout: Duration(seconds: 30),
    )) {
      log('Found device: ${device.platformName} (${device.remoteId})');

      if (!deviceFound) {
        deviceFound = true;

        try {
          // Connect to the first device found
          await client.connectToDevice(device);
          log('Connected to device successfully');

          // Wait for configuration to complete
          await Future.delayed(Duration(seconds: 5));

          if (client.isConfigured) {
            log('Configuration complete');
            log('My node info: ${client.myNodeInfo}');
            log('Local user: ${client.localUser}');
            log('Number of nodes: ${client.nodes.length}');

            // Send a test message
            await client.sendTextMessage('Hello from Flutter!');
            log('Test message sent');

            // Send position (example coordinates)
            await client.sendPosition(37.7749, -122.4194, altitude: 100);
            log('Position sent');

            // Keep running for a while to receive messages
            await Future.delayed(Duration(seconds: 30));
          } else {
            log('Configuration did not complete');
          }
        } catch (e) {
          log('Error connecting to device: $e');
        }
        break;
      }
    }

    if (!deviceFound) {
      log('No Meshtastic devices found');
    }
  } catch (e) {
    log('Error: $e');
  } finally {
    // Clean up
    client.dispose();
    log('Client disposed');
  }
}

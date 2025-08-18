import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:logging/logging.dart';

/// Example usage of the Meshtastic Flutter client
void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create the client
  final client = MeshtasticClient();

  try {
    // Initialize the client (handles permissions)
    await client.initialize();
    print('Meshtastic client initialized');

    // Listen for connection state changes
    client.connectionStream.listen((status) {
      print(
        'Connection status: ${status.state} - ${status.deviceName ?? status.deviceAddress}',
      );
      if (status.errorMessage != null) {
        print('Error: ${status.errorMessage}');
      }
    });

    // Listen for incoming packets
    client.packetStream.listen((packet) {
      print(
        'Received packet from ${packet.from.toRadixString(16)}: ${packet.packetTypeDescription}',
      );

      if (packet.isTextMessage) {
        print('Text message: ${packet.textMessage}');
      }
    });

    // Listen for node updates
    client.nodeStream.listen((node) {
      print('Node update: ${node.displayName} (${node.num.toRadixString(16)})');
      print('  Status: ${node.statusDescription}');
      if (node.latitude != null && node.longitude != null) {
        print('  Position: ${node.latitude}, ${node.longitude}');
      }
    });

    // Scan for devices
    print('Scanning for Meshtastic devices...');
    bool deviceFound = false;

    await for (final device in client.scanForDevices(
      timeout: Duration(seconds: 30),
    )) {
      print('Found device: ${device.platformName} (${device.remoteId})');

      if (!deviceFound) {
        deviceFound = true;

        try {
          // Connect to the first device found
          await client.connectToDevice(device);
          print('Connected to device successfully');

          // Wait for configuration to complete
          await Future.delayed(Duration(seconds: 5));

          if (client.isConfigured) {
            print('Configuration complete');
            print('My node info: ${client.myNodeInfo}');
            print('Local user: ${client.localUser}');
            print('Number of nodes: ${client.nodes.length}');

            // Send a test message
            await client.sendTextMessage('Hello from Flutter!');
            print('Test message sent');

            // Send position (example coordinates)
            await client.sendPosition(37.7749, -122.4194, altitude: 100);
            print('Position sent');

            // Keep running for a while to receive messages
            await Future.delayed(Duration(seconds: 30));
          } else {
            print('Configuration did not complete');
          }
        } catch (e) {
          print('Error connecting to device: $e');
        }
        break;
      }
    }

    if (!deviceFound) {
      print('No Meshtastic devices found');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    // Clean up
    client.dispose();
    print('Client disposed');
  }
}

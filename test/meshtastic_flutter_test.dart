import 'package:flutter_test/flutter_test.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:meshtastic_flutter/generated/portnums.pb.dart';

void main() {
  group('MeshtasticClient', () {
    test('creates client instance', () {
      final client = MeshtasticClient();
      expect(client, isNotNull);
      expect(client.isConnected, isFalse);
      expect(client.isConfigured, isFalse);
      expect(client.nodes, isEmpty);
    });

    test('connection state changes', () {
      final client = MeshtasticClient();

      expect(client.connectionStream, isA<Stream<ConnectionStatus>>());
      expect(client.packetStream, isA<Stream<MeshPacketWrapper>>());
      expect(client.nodeStream, isA<Stream<NodeInfoWrapper>>());
    });
  });

  group('ConnectionStatus', () {
    test('creates connection status', () {
      final status = ConnectionStatus(
        state: MeshtasticConnectionState.connected,
        deviceAddress: '00:11:22:33:44:55',
        deviceName: 'Test Device',
        timestamp: DateTime.now(),
      );

      expect(status.state, MeshtasticConnectionState.connected);
      expect(status.deviceAddress, '00:11:22:33:44:55');
      expect(status.deviceName, 'Test Device');
      expect(status.errorMessage, isNull);
    });

    test('equality comparison', () {
      final now = DateTime.now();
      final status1 = ConnectionStatus(
        state: MeshtasticConnectionState.connected,
        deviceAddress: 'test',
        timestamp: now,
      );
      final status2 = ConnectionStatus(
        state: MeshtasticConnectionState.connected,
        deviceAddress: 'test',
        timestamp: now,
      );

      expect(status1, equals(status2));
    });
  });

  group('MeshPacketWrapper', () {
    test('creates packet wrapper', () {
      final packet = MeshPacket(
        from: 0x12345678,
        to: 0x87654321,
        channel: 0,
        id: 12345,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: [72, 101, 108, 108, 111], // "Hello"
        ),
      );

      final wrapper = MeshPacketWrapper(packet);
      expect(wrapper.from, 0x12345678);
      expect(wrapper.to, 0x87654321);
      expect(wrapper.channel, 0);
      expect(wrapper.id, 12345);
      expect(wrapper.isTextMessage, isTrue);
      expect(wrapper.textMessage, 'Hello');
      expect(wrapper.isDirectMessage, isTrue);
      expect(wrapper.isBroadcast, isFalse);
    });
  });

  group('Exceptions', () {
    test('creates custom exceptions', () {
      expect(
        () => throw const BluetoothException('Test'),
        throwsA(isA<BluetoothException>()),
      );
      expect(
        () => throw const ConnectionException('Test'),
        throwsA(isA<ConnectionException>()),
      );
      expect(
        () => throw const ProtocolException('Test'),
        throwsA(isA<ProtocolException>()),
      );
      expect(
        () => throw const PermissionException('Test'),
        throwsA(isA<PermissionException>()),
      );
    });
  });
}

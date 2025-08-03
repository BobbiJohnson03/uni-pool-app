import 'dart:io';

Future<String> getLocalIpAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  for (var interface in interfaces) {
    for (var addr in interface.addresses) {
      if (!addr.isLoopback && addr.address.startsWith('192.168')) {
        return addr.address;
      }
    }
  }
  return '127.0.0.1'; // fallback
}

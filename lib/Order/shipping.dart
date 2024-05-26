class Shipping {
  final String address;
  final String recipientName;
  final String contactNumber;

  Shipping({
    required this.address,
    required this.recipientName,
    required this.contactNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'recipientName': recipientName,
      'contactNumber': contactNumber,
    };
  }

  static Shipping fromMap(Map<String, dynamic> map) {
    return Shipping(
      address: map['address'],
      recipientName: map['recipientName'],
      contactNumber: map['contactNumber'],
    );
  }
}


import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final bool isVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    this.isVerified = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl, phone, isVerified, createdAt];
}

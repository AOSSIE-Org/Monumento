import 'package:equatable/equatable.dart';

class LocalExpertEntity extends Equatable {
  final String expertId;
  final String name;
  final String imageUrl;
  final String designation;
  final String phoneNumber;

  const LocalExpertEntity({
    required this.expertId,
    required this.name,
    required this.imageUrl,
    required this.designation,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        expertId,
        name,
        imageUrl,
        designation,
        phoneNumber,
      ];
}

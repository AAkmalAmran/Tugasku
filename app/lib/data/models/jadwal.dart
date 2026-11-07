class Jadwal {
  final int id;
  final String hari;
  final String mataKuliah;
  final String jamMulai; // "HH:mm"
  final String jamSelesai; // "HH:mm"
  final String ruangan;

  const Jadwal({
    required this.id,
    required this.hari,
    required this.mataKuliah,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
  });

  static const List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] as int,
      hari: json['hari'] as String,
      mataKuliah: json['mataKuliah'] as String,
      jamMulai: json['jamMulai'] as String,
      jamSelesai: json['jamSelesai'] as String,
      ruangan: json['ruangan'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hari': hari,
      'mataKuliah': mataKuliah,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'ruangan': ruangan,
    };
  }
}
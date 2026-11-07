class Tugas {
  final int id;
  final String judul;
  final String mataKuliah;
  final String prioritas;
  final DateTime tenggat;
  final bool selesai;
  final String catatan;

  const Tugas({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.prioritas,
    required this.tenggat,
    required this.selesai,
    required this.catatan,
  });

  static const List<String> priorities = ['Rendah', 'Sedang', 'Tinggi'];

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'] as int,
      judul: json['judul'] as String,
      mataKuliah: json['mataKuliah'] as String,
      prioritas: json['prioritas'] as String,
      tenggat: DateTime.parse(json['tenggat'] as String).toLocal(),
      selesai: json['selesai'] as bool,
      catatan: (json['catatan'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'mataKuliah': mataKuliah,
      'prioritas': prioritas,
      'tenggat': tenggat.toUtc().toIso8601String(),
      'selesai': selesai,
      'catatan': catatan,
    };
  }

  Tugas copyWith({
    int? id,
    String? judul,
    String? mataKuliah,
    String? prioritas,
    DateTime? tenggat,
    bool? selesai,
    String? catatan,
  }) {
    return Tugas(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      prioritas: prioritas ?? this.prioritas,
      tenggat: tenggat ?? this.tenggat,
      selesai: selesai ?? this.selesai,
      catatan: catatan ?? this.catatan,
    );
  }
}
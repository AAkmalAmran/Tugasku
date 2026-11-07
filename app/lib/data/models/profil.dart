class Profil {
  final String nama;
  final String nim;
  final String programStudi;
  final int semester;
  final String dosenWali;
  final int sksSemesterIni;

  const Profil({
    required this.nama,
    required this.nim,
    required this.programStudi,
    required this.semester,
    required this.dosenWali,
    required this.sksSemesterIni,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      nama: json['nama'] as String,
      nim: json['nim'] as String,
      programStudi: json['programStudi'] as String,
      semester: json['semester'] as int,
      dosenWali: json['dosenWali'] as String,
      sksSemesterIni: json['sksSemesterIni'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nim': nim,
      'programStudi': programStudi,
      'semester': semester,
      'dosenWali': dosenWali,
      'sksSemesterIni': sksSemesterIni,
    };
  }
}
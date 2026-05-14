import 'package:flutter/material.dart';

class Preset {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  // Colors
  static final primaryColor = Color.fromRGBO(30, 54, 138, 100);
  static final secondaryColor = Color.fromRGBO(204, 224, 251, 100);
  static final foregroundColor = Color.fromRGBO(239, 256, 255, 100);
  static final backgroundColor = Color.fromRGBO(239,246, 255, 100);
  static final background2Color = Color.fromRGBO(232, 248, 245, 100);
  static final mainColor = Color.fromRGBO(41, 128, 185, 100);
  static final editColor = Color.fromRGBO(243, 156, 18, 100);
  static final disableColor = Color.fromRGBO(189, 195, 199, 100);
  static final errorColor = Color.fromRGBO(231, 76, 60, 100);
  static final saveColor = Color.fromRGBO(39, 174, 96, 100);

  // spacing
  static const smallSpace = SizedBox(height: 25);
  static final mediumSpace = SizedBox(height: screenHeight! * 0.05);
  static final largeSpace = SizedBox(height: screenHeight! * 0.08);

  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(
      color: Color.fromRGBO(41, 128, 185, 100)
    )
  );

  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(
      color: Color.fromRGBO(231, 76, 60, 100)
    )
  );
}

class AppText {
  static final myText = {
    'welcome': 'Selamat Datang',
    'login': 'Silahkan Login',
    'total-mhs': 'Total Mahasiswa',
    'bayar-mhs': 'Sudah Bayar',
    'cicil-mhs': 'Sedang Mencicil',
    'blm-bayar-mhs': 'Belum Bayar',
    'notif': 'Pemberitahuan',
    'nim': 'NIM',
    'nama-mhs': 'Nama Mahasiswa',
    'jurusan-mhs': 'Jurusan',
    'ukt': 'UKT',
    'stat': 'Status',
    'act': 'Aksi',
    'beasiswa': 'Beasiswa',
    'cicil': 'Sisa Cicilan',
  };
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle baseTextStyle() {
  return TextStyle(fontFamily: 'Poppins');
}
TextStyle baseTextStyleKr() {
  return TextStyle(fontFamily: 'NotoSerifKR');
}

TextStyle headerTextStyle() {
  return baseTextStyle().copyWith(
    color: Colors.black87,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );
}

TextStyle regularTextStyle() {
  return baseTextStyle().copyWith(
    color: Colors.white,
    fontSize: 9.0,
    fontWeight: FontWeight.w400,
  );
}

TextStyle subHeaderTextStyle() {
  return regularTextStyle().copyWith(fontSize: 14.0);
}

TextStyle descriptionTextStyle() {
  return baseTextStyle().copyWith(
    color: Colors.black87,
    fontSize: 14.0,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

class MindBloomingTextStyle {
  // bool isWeb = GetPlatform.isWeb;
  // bool isMobile = GetPlatform.isMobile;
  // bool isAndroid = GetPlatform.isAndroid;
  // bool isiOS = GetPlatform.isIOS;
  // bool isWindows = GetPlatform.isWindows;
  // bool isMac = GetPlatform.isMacOS;
  // bool isLinux = GetPlatform.isLinux;
  // bool isFuchsia = GetPlatform.isFuchsia;
  // bool isDesktop = GetPlatform.isDesktop;

  static bool returnMobile() {
    return GetPlatform.isMobile;
  }

  static bool returnDesktop() {
    return GetPlatform.isDesktop;
  }

  //NEW ENTRY PER GESTIONE GARNDEZZE IN VERSIONE WEBAPP

  static TextStyle introductionText = GoogleFonts.quicksand(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.8.sp
        : (GetPlatform.isDesktop ? 4.5.sp : 8.sp),
    letterSpacing: -1.4,
  );

  static TextStyle conditionName = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 13.sp
        : (GetPlatform.isDesktop ? 5.5.sp : 8.5.sp),
    letterSpacing: -1.4,
  );

  static TextStyle quoteHomePage = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 10.8.sp : (GetPlatform.isDesktop ? 6.sp : 7.sp),
    letterSpacing: -1.4,
  );

  static TextStyle calendarText = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 13.9.sp
        : (GetPlatform.isDesktop ? 4.sp : 8.5.sp),
  );

  static TextStyle calendarText2 = GoogleFonts.quicksand(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.8.sp
        : (GetPlatform.isDesktop ? 3.25.sp : 6.sp),
  );

  static TextStyle noDataText = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 10.8.sp : (GetPlatform.isDesktop ? 6.sp : 7.sp),
  );

  static TextStyle alertEsercizi = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.8.sp
        : (GetPlatform.isDesktop ? 4.9.sp : 7.sp),
  );

  static TextStyle alertEserciziButton = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.8.sp
        : (GetPlatform.isDesktop ? 4.9.sp : 7.sp),
  );

  static TextStyle rankOrderNumber = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 8.5.sp
        : (GetPlatform.isDesktop ? 2.7.sp : 6.5.sp),
  );

  static TextStyle loginTextStrong = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 12.2.sp
        : (GetPlatform.isDesktop ? 3.5.sp : 7.sp),
  );

  static TextStyle loginTextNormal = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 12.2.sp
        : (GetPlatform.isDesktop ? 3.5.sp : 7.sp),
  );

  static TextStyle loginTextTitle = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 22.sp : (GetPlatform.isDesktop ? 8.sp : 7.sp),
  );

  static TextStyle isSelectedStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 17.5.sp
        : (GetPlatform.isDesktop ? 6.4.sp : 11.sp),
    letterSpacing: -1.4,
  );

  static TextStyle isNotSelectedStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color.fromARGB(255, 104, 111, 109),
    fontSize: GetPlatform.isMobile
        ? 17.5.sp
        : (GetPlatform.isDesktop ? 6.4.sp : 11.sp),
    letterSpacing: -1.4,
  );

  static TextStyle dateFont = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.8.sp
        : (GetPlatform.isDesktop ? 3.3.sp : 7.sp),
  );

  static TextStyle header1 = GoogleFonts.quicksand(
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 26.sp : (GetPlatform.isDesktop ? 12.sp : 20.sp),
    letterSpacing: -1.4,
  );

  static TextStyle header2 = GoogleFonts.quicksand(
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 20.sp : (GetPlatform.isDesktop ? 9.sp : 15.sp),
    letterSpacing: -1.4,
  );

  static TextStyle header3 = GoogleFonts.quicksand(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 17.5.sp
        : (GetPlatform.isDesktop ? 6.4.sp : 11.sp),
    letterSpacing: -1.4,
  );

  static TextStyle subtitle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 13.sp
        : (GetPlatform.isDesktop ? 5.8.sp : 8.5.sp),
  );

  static TextStyle subtitleScreening = GoogleFonts.quicksand(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize: GetPlatform.isMobile
        ? 10.1.sp
        : (GetPlatform.isDesktop ? 5.8.sp : 8.5.sp),
  );

  static TextStyle pretitle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 9.8.sp : (GetPlatform.isDesktop ? 4.5.sp : 6.sp),
  );

  static TextStyle pretitleScreening = GoogleFonts.quicksand(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 8.8.sp : (GetPlatform.isDesktop ? 4.5.sp : 6.sp),
  );

  static TextStyle bottomNavbar = GoogleFonts.quicksand(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 8.sp : (GetPlatform.isDesktop ? 4.sp : 7.sp),
  );

  static TextStyle button = GoogleFonts.quicksand(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFFF7FFFC),
    fontSize:
        GetPlatform.isMobile ? 13.sp : (GetPlatform.isDesktop ? 5.3.sp : 8.sp),
    letterSpacing: 0.4,
  );

  static TextStyle normal = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 12.5.sp : (GetPlatform.isDesktop ? 4.sp : 7.sp),
  );

  static TextStyle strong = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 10.8.sp : (GetPlatform.isDesktop ? 4.sp : 7.sp),
  );

  static TextStyle small = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 8.5.sp : (GetPlatform.isDesktop ? 4.sp : 6.5.sp),
  );

  static TextStyle link = GoogleFonts.sourceSans3(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: const Color(0xFF091712),
    fontSize:
        GetPlatform.isMobile ? 10.8.sp : (GetPlatform.isDesktop ? 4.sp : 7.sp),
    decoration: TextDecoration.underline,
  );
}

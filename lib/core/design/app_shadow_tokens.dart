import 'package:flutter/material.dart';

abstract final class AppShadowTokens {
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: Color(0x12000000), offset: Offset(0, 6), blurRadius: 12),
  ];

  static const List<BoxShadow> level3 = <BoxShadow>[
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 4), blurRadius: 8),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 12),
      blurRadius: 20,
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> level4 = <BoxShadow>[
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 6), blurRadius: 12),
    BoxShadow(
      color: Color(0x18000000),
      offset: Offset(0, 16),
      blurRadius: 28,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> level5 = <BoxShadow>[
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 6), blurRadius: 12),
    BoxShadow(
      color: Color(0x18000000),
      offset: Offset(0, 18),
      blurRadius: 30,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 30),
      blurRadius: 44,
      spreadRadius: -10,
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const authTransitionIn = Duration(milliseconds: 400);
const authTransitionOut = Duration(milliseconds: 280);
const crudTransitionIn = Duration(milliseconds: 220);
const crudTransitionOut = Duration(milliseconds: 150);

CustomTransitionPage<T> fadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: authTransitionIn,
    reverseTransitionDuration: authTransitionOut,
  );
}

CustomTransitionPage<T> slidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(animation),
            child: child,
          ),
        ),
    transitionDuration: crudTransitionIn,
    reverseTransitionDuration: crudTransitionOut,
  );
}

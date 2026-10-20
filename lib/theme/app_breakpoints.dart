/// Layout widths for the billing desk.
abstract final class AppBreakpoints {
  static const tablet = 760.0;
  static const desktop = 1080.0;

  static bool isMobile(double width) => width < tablet;

  static bool isTablet(double width) => width >= tablet && width < desktop;

  static bool isDesktop(double width) => width >= desktop;
}

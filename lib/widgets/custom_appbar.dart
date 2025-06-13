import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showLogo;
  final String logoPath;
  final double logoHeight;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backButtonColor;
  final Color backButtonBackgroundColor;
  final double backButtonOpacity;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final List<Widget>? actions;
  final String? heroTag;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.showLogo = true,
    this.logoPath = 'assets/images/e_masjid.png',
    this.logoHeight = 60,
    this.centerTitle = true,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.showBackButton = true,
    this.onBackPressed,
    this.backButtonColor = Colors.black,
    this.backButtonBackgroundColor = Colors.black,
    this.backButtonOpacity = 0.08,
    this.systemOverlayStyle = SystemUiOverlayStyle.dark,
    this.actions,
    this.heroTag = 'app_logo',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: _buildTitle(),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: (showBackButton && Navigator.of(context).canPop())
          ? _buildBackButton(context)
          : null,
      actions: actions,
      systemOverlayStyle: systemOverlayStyle,
    );
  }

  Widget? _buildTitle() {
    if (titleWidget != null) return titleWidget;

    if (showLogo) {
      return Hero(
        tag: heroTag!,
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Image.asset(
            logoPath,
            height: logoHeight.h,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (title != null) {
      return Text(
        title!,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      );
    }

    return null;
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: backButtonBackgroundColor.withOpacity(backButtonOpacity),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: backButtonColor,
          size: 20.sp,
        ),
      ),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

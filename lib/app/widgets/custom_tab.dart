import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;

  const CustomTab({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(), //  removes underline
        dividerColor: Colors.transparent, //  removes extra line
        splashFactory: NoSplash.splashFactory, //  remove ripple effect
        tabs: List.generate(
          tabs.length,
              (index) {
            final isSelected = controller.index == index;
            return Tab(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final selected = controller.index == index;
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

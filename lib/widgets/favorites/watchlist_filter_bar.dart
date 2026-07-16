import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../service/watchlist_intelligence_service.dart';

enum WatchlistFilter {
  all,
  priceDrops,
  priceIncreases,
  lowestPrice,
  stable,
  moreDataNeeded,
}

class WatchlistFilterBar extends StatelessWidget {
  final WatchlistFilter selectedFilter;
  final ValueChanged<WatchlistFilter> onChanged;

  const WatchlistFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.star,
            filter: WatchlistFilter.all,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChip(
            label: 'Price Drops',
            icon: Icons.trending_down,
            filter: WatchlistFilter.priceDrops,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChip(
            label: 'Price Increases',
            icon: Icons.trending_up,
            filter: WatchlistFilter.priceIncreases,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChip(
            label: 'Lowest Price',
            icon: Icons.local_offer,
            filter: WatchlistFilter.lowestPrice,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChip(
            label: 'Stable',
            icon: Icons.trending_flat,
            filter: WatchlistFilter.stable,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChip(
            label: 'Needs Data',
            icon: Icons.info_outline,
            filter: WatchlistFilter.moreDataNeeded,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final WatchlistFilter filter;
  final WatchlistFilter selectedFilter;
  final ValueChanged<WatchlistFilter> onChanged;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.filter,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == selectedFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: isSelected,
        onSelected: (_) {
          onChanged(filter);
        },
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.white
              : AppColors.primary,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : null,
          ),
        ),
        selectedColor: AppColors.primary,
        backgroundColor:
            AppColors.primary.withValues(alpha: 0.06),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.18),
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

extension WatchlistFilterMatching on WatchlistFilter {
  bool matches(WatchlistInsight insight) {
    switch (this) {
      case WatchlistFilter.all:
        return true;
      case WatchlistFilter.priceDrops:
        return insight.type ==
            WatchlistInsightType.priceDrop;
      case WatchlistFilter.priceIncreases:
        return insight.type ==
            WatchlistInsightType.priceIncrease;
      case WatchlistFilter.lowestPrice:
        return insight.type ==
            WatchlistInsightType.lowestRecorded;
      case WatchlistFilter.stable:
        return insight.type ==
            WatchlistInsightType.stable;
      case WatchlistFilter.moreDataNeeded:
        return insight.type ==
            WatchlistInsightType.notEnoughData;
    }
  }
}
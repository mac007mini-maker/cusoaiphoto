import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/remote_config_service.dart';

class PremiumDebugWidget extends StatefulWidget {
  const PremiumDebugWidget({super.key});

  @override
  State<PremiumDebugWidget> createState() => _PremiumDebugWidgetState();
}

class _PremiumDebugWidgetState extends State<PremiumDebugWidget> {
  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final remoteConfig = RemoteConfigService();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔧 Premium & Ads Debug',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildStatusRow(
            'Premium Status',
            userService.isPremiumUser ? 'Premium ✨' : 'Free',
            userService.isPremiumUser ? Colors.amber : Colors.grey,
          ),
          SizedBox(height: 8),
          _buildStatusRow(
            'Ads Enabled (Remote)',
            remoteConfig.adsEnabled.toString(),
            remoteConfig.adsEnabled ? Colors.green : Colors.red,
          ),
          SizedBox(height: 8),
          _buildStatusRow(
            'Banner Ads',
            remoteConfig.bannerAdsEnabled.toString(),
            remoteConfig.bannerAdsEnabled ? Colors.green : Colors.red,
          ),
          SizedBox(height: 8),
          _buildStatusRow(
            'Rewarded Ads',
            remoteConfig.rewardedAdsEnabled.toString(),
            remoteConfig.rewardedAdsEnabled ? Colors.green : Colors.red,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await userService.setPremiumStatus(true);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Set Premium'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await userService.setPremiumStatus(false);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text('Set Free'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await remoteConfig.refresh();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text('Refresh Remote Config'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

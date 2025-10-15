import 'package:flutter/material.dart';
import '/services/applovin_service.dart';
import '/services/admob_rewarded_service.dart';

class AdDebugWidget extends StatefulWidget {
  const AdDebugWidget({super.key});

  @override
  State<AdDebugWidget> createState() => _AdDebugWidgetState();
}

class _AdDebugWidgetState extends State<AdDebugWidget> {
  String _status = 'Checking ad services...';
  
  @override
  void initState() {
    super.initState();
    _checkAdStatus();
  }

  void _checkAdStatus() {
    final appLovinInit = AppLovinService.isInitialized;
    final admobInit = AdMobRewardedService.isInitialized;
    final admobReady = AdMobRewardedService.isAdReady;
    
    setState(() {
      _status = '''
Ad Services Status:

AppLovin MAX:
- Initialized: ${appLovinInit ? '✅ Yes' : '❌ No'}

AdMob Rewarded:
- Initialized: ${admobInit ? '✅ Yes' : '❌ No'}
- Ad Ready: ${admobReady ? '✅ Yes' : '❌ No'}

Tips:
${!appLovinInit && !admobInit ? '⚠️ No ad services initialized!\nDid you build with: ./build_with_all_ads.sh apk ?' : ''}
${!admobReady && admobInit ? '⚠️ AdMob initialized but ad not loaded yet.\nWait a few seconds and refresh.' : ''}
''';
    });
  }

  Future<void> _testAppLovinAd() async {
    setState(() => _status = 'Testing AppLovin ad...');
    
    await AppLovinService.showRewardedAd(
      onComplete: () {
        setState(() => _status = '✅ AppLovin ad completed successfully!');
      },
      onFailed: () {
        setState(() => _status = '❌ AppLovin ad failed to show');
      },
    );
  }

  Future<void> _testAdMobAd() async {
    setState(() => _status = 'Testing AdMob ad...');
    
    await AdMobRewardedService.showRewardedAd(
      onComplete: () {
        setState(() => _status = '✅ AdMob ad completed successfully!');
      },
      onFailed: () {
        setState(() => _status = '❌ AdMob ad failed to show');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _checkAdStatus,
              icon: Icon(Icons.refresh),
              label: Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _testAppLovinAd,
              icon: Icon(Icons.play_arrow),
              label: Text('Test AppLovin Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _testAdMobAd,
              icon: Icon(Icons.play_arrow),
              label: Text('Test AdMob Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

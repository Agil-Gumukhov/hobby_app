import 'package:firstapp/pages/GolKralligi.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/pages/League_sonu%C3%A7detay.dart';
import 'package:firstapp/pages/Sport_sonu%C3%A7.dart';

class Tapbarview extends StatefulWidget {
  final String leagueKey;
  const Tapbarview({super.key, required this.leagueKey});

  @override
  State<Tapbarview> createState() => _TapbarviewState();
}

class _TapbarviewState extends State<Tapbarview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern gradient AppBar
      appBar: AppBar(
        title: const Text(
          'Lig Bilgileri',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Özel Tasarımlı TabBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Colors.white70, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: 'Puan Durumu'),
                Tab(text: 'Fikstür'),
                Tab(text: 'İstatistik'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // İlk sekmede puan durumu sayfası
          LeagueSonucdetay(leagueKey: widget.leagueKey),
          // İkinci sekmede fikstür sayfası
          SportSonuc(leagueKey: widget.leagueKey),
          Golkralligi(leagueKey: widget.leagueKey),
        ],
      ),
    );
  }
}

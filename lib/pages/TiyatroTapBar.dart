import 'package:firstapp/pages/TiyatroSayfas%C4%B1.dart';
import 'package:flutter/material.dart';

class Tiyatrotapbar extends StatefulWidget {
  const Tiyatrotapbar({super.key});

  @override
  State<Tiyatrotapbar> createState() => _TiyatrotapbarState();
}

class _TiyatrotapbarState extends State<Tiyatrotapbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> favorites = {}; // Shared favorites map
  String searchQuery = ''; // Holds the current search query

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern gradient AppBar with integrated search bar and TabBar
      appBar: AppBar(
        title: const Text(
          'Theatres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // AppBar altına arama çubuğu ve TabBar eklemek için PreferredSize kullanıyoruz.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140), // Arama çubuğu + TabBar için yeterli yükseklik
          child: Column(
            children: [
              // Arama çubuğu
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Theatres...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // TabBar kapsayıcısı
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Tab(text: 'All Theatres'),
                    Tab(text: 'Favorites'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // TabBarView içinde Tiyatrosayfasi widget’ına searchQuery parametresini de gönderiyoruz.
      body: TabBarView(
        controller: _tabController,
        children: [
          Tiyatrosayfasi(
              filter: TheathresFilter.all,
              favorites: favorites,
              searchQuery: searchQuery),
          Tiyatrosayfasi(
              filter: TheathresFilter.favorites,
              favorites: favorites,
              searchQuery: searchQuery),
        ],
      ),
    );
  }
}

import 'package:firstapp/pages/FilmSayfas%C4%B1.dart';
import 'package:flutter/material.dart';

class Filmtabbar extends StatefulWidget {
  const Filmtabbar({super.key});

  @override
  State<Filmtabbar> createState() => _FilmtabbarState();
}

class _FilmtabbarState extends State<Filmtabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, bool> favorites = {}; // Shared favorites map
  String searchQuery = ''; // Holds the current search query

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
      // Modern gradient AppBar with integrated search bar and TabBar
      appBar: AppBar(
        title: const Text(
          'Movies',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        // Use PreferredSize with a Column to include a search bar and TabBar.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120), // Adjust as needed
          child: Column(
            children: [
              // Search bar
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
                    hintText: 'Search Movies...',
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
              // TabBar container
              Container(
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
                    Tab(text: 'All Movies'),
                    Tab(text: 'Top Rated'),
                    Tab(text: 'Favorites'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Filmsayfasi(
            filter: MovieFilter.all,
            favorites: favorites,
            searchQuery: searchQuery,
          ),
          Filmsayfasi(
            filter: MovieFilter.topRated,
            favorites: favorites,
            searchQuery: searchQuery,
          ),
          Filmsayfasi(
            filter: MovieFilter.favorites,
            favorites: favorites,
            searchQuery: searchQuery,
          ),
        ],
      ),
    );
  }
}

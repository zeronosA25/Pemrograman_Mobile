import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================= PENGATURAN TEMA & KETAHANAN DATA =================

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

Future<void> muatPengaturanTema() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  final colorIndex = prefs.getInt('colorIndex') ?? 0;

  themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  if (colorIndex >= 0 && colorIndex < pilihanWarna.length) {
    seedColor.value = pilihanWarna[colorIndex];
  }
}

Future<void> simpanTema(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDark', isDark);
}

Future<void> simpanWarna(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  final index = pilihanWarna.indexOf(color);
  if (index != -1) {
    await prefs.setInt('colorIndex', index);
  }
}

// ================= MODEL DATA KATALOG =================

class ItemKatalog {
  final String id;
  final String nama;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
  bool isFavorite;

  ItemKatalog({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
    this.isFavorite = false,
  });
}

final List<ItemKatalog> daftarKatalog = [
  ItemKatalog(
    id: '1',
    nama: 'Kamera DSLR Pro',
    deskripsi: 'Kamera profesional dengan resolusi tinggi dan perekaman video 4K.',
    ikon: Icons.camera_alt,
    warna: Colors.orange,
  ),
  ItemKatalog(
    id: '2',
    nama: 'Gitar Akustik',
    deskripsi: 'Gitar kayu premium dengan suara jernih dan resonansi mendalam.',
    ikon: Icons.music_note,
    warna: Colors.pink,
  ),
  ItemKatalog(
    id: '3',
    nama: 'Laptop Gaming',
    deskripsi: 'Performa tinggi dengan GPU diskrit untuk gaming dan kreativitas.',
    ikon: Icons.laptop,
    warna: Colors.blue,
  ),
  ItemKatalog(
    id: '4',
    nama: 'Jam Tangan Pintar',
    deskripsi: 'Pelacak kebugaran dengan pemantau detak jantung dan layar AMOLED.',
    ikon: Icons.watch,
    warna: Colors.green,
  ),
];

// ================= MAIN & MYAPP =================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturanTema();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Katalog Interaktif',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColor.value,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColor.value,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (context) => const ShellPage(),
          },
          // Named route dengan argumen dan transisi custom FadeTransition
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item = settings.arguments as ItemKatalog;
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DetailPage(item: item);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return null;
          },
        );
      },
    );
  }
}

// ================= SHELL PAGE (NAVIGATION BAR 3 TAB) =================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final halaman = [
      BerandaTab(onUpdate: () => setState(() {})),
      FavoritTab(onUpdate: () => setState(() {})),
      const PengaturanTab(),
    ];

    final judul = ['Katalog Produk', 'Favorit Saya', 'Pengaturan Tema'];

    return Scaffold(
      appBar: AppBar(title: Text(judul[_index])),
      body: IndexedStack(index: _index, children: halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ================= TAB 1: BERANDA KATALOG =================

class BerandaTab extends StatefulWidget {
  final VoidCallback onUpdate;
  const BerandaTab({super.key, required this.onUpdate});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Animasi Eksplisit 1: AnimationController untuk rotasi lencana promo
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner Promo dengan Animasi Eksplisit Rotasi
        Card(
          color: tema.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                RotationTransition(
                  turns: _rotationController,
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: tema.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Katalog Unggulan',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih item favorit Anda dan nikmati transisinya.',
                        style: tema.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daftarKatalog.length,
          itemBuilder: (context, i) {
            final item = daftarKatalog[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Hero(
                  tag: 'ikon-${item.id}',
                  child: CircleAvatar(
                    backgroundColor: item.warna,
                    child: Icon(item.ikon, color: Colors.white),
                  ),
                ),
                title: Text(item.nama, style: tema.textTheme.titleMedium),
                subtitle: Text(
                  item.deskripsi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: item.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      item.isFavorite = !item.isFavorite;
                    });
                    widget.onUpdate();
                  },
                ),
                onTap: () async {
                  await Navigator.pushNamed(context, '/detail', arguments: item);
                  setState(() {});
                  widget.onUpdate();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ================= TAB 2: FAVORIT =================

class FavoritTab extends StatelessWidget {
  final VoidCallback onUpdate;
  const FavoritTab({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final favorits = daftarKatalog.where((element) => element.isFavorite).toList();

    if (favorits.isEmpty) {
      return Center(
        child: Text(
          'Belum ada item favorit',
          style: tema.textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorits.length,
      itemBuilder: (context, i) {
        final item = favorits[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Hero(
              tag: 'ikon-${item.id}',
              child: CircleAvatar(
                backgroundColor: item.warna,
                child: Icon(item.ikon, color: Colors.white),
              ),
            ),
            title: Text(item.nama, style: tema.textTheme.titleMedium),
            subtitle: Text(item.deskripsi, maxLines: 1),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: item);
            },
          ),
        );
      },
    );
  }
}

// ================= TAB 3: PENGATURAN TEMA =================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text('Mode Gelap', style: tema.textTheme.titleMedium),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                simpanTema(v);
              },
            ),
            const SizedBox(height: 12),
            Text('Warna Tema Utama', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () {
                      seedColor.value = c;
                      simpanWarna(c);
                    },
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ================= HALAMAN DETAIL KATALOG =================

class DetailPage extends StatefulWidget {
  final ItemKatalog item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _diperbesar = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.nama),
        actions: [
          IconButton(
            icon: Icon(
              widget.item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.item.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                widget.item.isFavorite = !widget.item.isFavorite;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'ikon-${widget.item.id}',
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: widget.item.warna,
                  child: Icon(widget.item.ikon, size: 70, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.item.nama,
                style: tema.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.deskripsi,
                style: tema.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Animasi Implisit: AnimatedContainer interaktif saat ditekan
              GestureDetector(
                onTap: () {
                  setState(() {
                    _diperbesar = !_diperbesar;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _diperbesar
                        ? tema.colorScheme.primary
                        : tema.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(_diperbesar ? 30 : 8),
                  ),
                  child: Text(
                    _diperbesar ? 'Gambar Produk Diperbesar' : 'Ketuk untuk Detail Ukuran',
                    style: TextStyle(
                      color: _diperbesar
                          ? Colors.white
                          : tema.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
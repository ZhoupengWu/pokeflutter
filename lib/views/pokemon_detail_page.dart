import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../model/pokemon_list_item.dart';
import '../model/pokemon.dart';
import '../utils/pokemon_api.dart';
import '../utils/pokemon_costants.dart';
import '../utils/capitalize.dart';
import '../utils/palette.dart';
import 'widgets/styled_text.dart';

class PokemonDetailPage extends StatefulWidget {
  final PokemonListItem pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  Pokemon? _pokemon;
  bool _isLoading = true;
  bool _hasError = false;
  Color _bgColor = const Color(0xFF919AA2); // fallback: normal grey

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    try {
      final result = await PokemonApi.getPokemonDetails(widget.pokemon.name);
      if (!mounted) return;
      setState(() {
        _pokemon = result;
        _bgColor = result != null
            ? (listPokemonTypeColor[result.typesList[0].toLowerCase()] ??
                _bgColor)
            : _bgColor;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _hasError
              ? _errorView()
              : _detailView(),
    );
  }

  Widget _errorView() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load Pokémon',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchDetails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _detailView() {
    final pokemon = _pokemon!;
    return Stack(
      children: [
        // Background pokeball watermark
        Positioned(
          top: -20.r,
          right: -40.r,
          child: SvgPicture.asset(
            'assets/pokeball.svg',
            height: 220.r,
            width: 220.r,
            colorFilter:
                const ColorFilter.mode(Colors.white12, BlendMode.srcIn),
          ),
        ),

        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        pokemon.name.capitalize(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // ── Type chips ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(left: 32.w, bottom: 8.h),
                child: Row(
                  children: pokemon.typesList
                      .map((t) => _typeChip(t))
                      .toList(),
                ),
              ),

              // ── Pokémon image ────────────────────────────────────────────
              Center(
                child: Image.network(
                  pokemon.urlImage,
                  height: 180.r,
                  width: 180.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_rounded,
                    size: 120.r,
                    color: Colors.white38,
                  ),
                ),
              ),

              // ── White card ───────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32.r)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Physical info ──────────────────────────────────
                        _sectionTitle('About'),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _infoTile(
                              icon: Icons.monitor_weight_outlined,
                              label: 'Weight',
                              value: '${pokemon.weight} kg',
                            ),
                            _divider(),
                            _infoTile(
                              icon: Icons.height_rounded,
                              label: 'Height',
                              value: '${pokemon.height} cm',
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // ── Abilities ──────────────────────────────────────
                        _sectionTitle('Abilities'),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: pokemon.abilities
                              .map((a) => _abilityChip(a))
                              .toList(),
                        ),

                        SizedBox(height: 24.h),

                        // ── Base stats ─────────────────────────────────────
                        _sectionTitle('Base Stats'),
                        SizedBox(height: 12.h),
                        ...pokemon.stats.map((s) => _statRow(s)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _bgColor,
              fontWeight: FontWeight.w700,
            ),
      );

  Widget _typeChip(String type) => Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          type.capitalize(),
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.white),
        ),
      );

  Widget _abilityChip(String ability) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _bgColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _bgColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          ability.capitalize(),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: _bgColor),
        ),
      );

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16.r, color: gray[400]),
                SizedBox(width: 4.w),
                StyledText(
                  text: value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: gray[500]),
                  textHeight: 20.h,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: gray[300]),
            ),
          ],
        ),
      );

  Widget _divider() => Container(
        height: 32.h,
        width: 1.w,
        color: gray[200],
      );

  Widget _statRow(PokemonStat stat) {
    const maxStat = 255.0;
    final statLabel = _statLabel(stat.name);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              statLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: _bgColor, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 28.w,
            child: Text(
              stat.value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: gray[500]),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: stat.value / maxStat,
                minHeight: 6.h,
                backgroundColor: gray[100],
                valueColor: AlwaysStoppedAnimation<Color>(_bgColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statLabel(String name) {
    const labels = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SpA',
      'special-defense': 'SpD',
      'speed': 'SPD',
    };
    return labels[name] ?? name.substring(0, 3).toUpperCase();
  }
}
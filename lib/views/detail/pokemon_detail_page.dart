import 'package:flutter/material.dart';
import '../shared/pokemon_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../controllers/pokemon_detail_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/contrast.dart';
import '../../core/pokemon_constants.dart';
import '../../theme/responsive.dart';
import '../../theme/theme.dart';
import 'about_sections.dart';
import 'detail_header.dart';
import 'evolution_section.dart';
import 'species_section.dart';
import 'type_matchups_section.dart';

/// Full details of one Pokémon: header with artwork, about, abilities,
/// base stats, type matchups and evolution chain.
class PokemonDetailPage extends StatefulWidget {
  /// [heroTag] makes the artwork fly in from the list cell that has the same
  /// tag; leave it null when opening from somewhere else.
  /// Pass a [controller] to drive the page from a test.
  const PokemonDetailPage({
    super.key,
    required this.pokemon,
    this.heroTag,
    this.controller,
  });

  final PokemonListItem pokemon;
  final Object? heroTag;
  final PokemonDetailController? controller;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late final PokemonDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        PokemonDetailController(
          item: widget.pokemon,
          api: context.read(),
          evolutionApi: context.read(),
          speciesApi: context.read(),
          abilityApi: context.read(),
          repository: context.read(),
        );
    _controller.load();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Color _accentOf(Pokemon? pokemon) {
    final type = pokemon?.typesList.firstOrNull?.toLowerCase();
    return listPokemonTypeColor[type] ?? context.colors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: coloredPageOverlayStyle(Theme.of(context).brightness),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final accent = _accentOf(_controller.pokemon);
          return Scaffold(
            backgroundColor: accent,
            body: switch (_controller.status) {
              LoadStatus.loading => _LoadingView(
                item: widget.pokemon,
                heroTag: widget.heroTag,
              ),
              LoadStatus.failed => _ErrorView(onRetry: _controller.load),
              LoadStatus.loaded => _DetailView(
                controller: _controller,
                accent: accent,
                heroTag: widget.heroTag,
                favouriteItem: widget.pokemon,
              ),
            },
          );
        },
      ),
    );
  }
}

/// Shows the list sprite (so the hero flight has somewhere to land) and a
/// spinner while the details load.
class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.item, required this.heroTag});

  final PokemonListItem item;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tag = heroTag;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag != null) ...[
            Hero(
              tag: tag,
              child: PokemonImage(
                item.spriteUrl,
                width: 96.r,
                height: 96.r,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => SizedBox(width: 96.r, height: 96.r),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: IconButton(
              tooltip: context.l10n.back,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                context.l10n.detailLoadFailed,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.controller,
    required this.accent,
    required this.heroTag,
    required this.favouriteItem,
  });

  final PokemonDetailController controller;
  final Color accent;
  final Object? heroTag;
  final PokemonListItem favouriteItem;

  @override
  Widget build(BuildContext context) {
    final pokemon = controller.pokemon!;
    final colors = context.colors;
    // Section titles and bars sit on the card, so they need to contrast with it.
    final readableAccent = ensureContrast(accent, colors.surface);

    return Stack(
      children: [
        Positioned(
          top: -20.r,
          right: -40.r,
          child: ExcludeSemantics(
            child: SvgPicture.asset(
              'assets/pokeball.svg',
              height: 220.r,
              width: 220.r,
              colorFilter: const ColorFilter.mode(
                Colors.white12,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailHeader(
                  pokemon: pokemon,
                  favouriteItem: favouriteItem,
                  heroTag: heroTag,
                ),

                // ── Card with the details ──────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32.r),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 24.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.species?.hasInfo ?? false) ...[
                              SpeciesSection(
                                species: controller.species!,
                                accent: readableAccent,
                              ),
                              SizedBox(height: 24.h),
                            ],
                            AboutSection(
                              pokemon: pokemon,
                              accent: readableAccent,
                            ),
                            SizedBox(height: 24.h),
                            AbilitiesSection(
                              pokemon: pokemon,
                              accent: readableAccent,
                              translations: controller.abilityNames,
                            ),
                            SizedBox(height: 24.h),
                            StatsSection(
                              pokemon: pokemon,
                              accent: readableAccent,
                            ),
                            SizedBox(height: 24.h),
                            TypeMatchupsSection(
                              pokemon: pokemon,
                              accent: readableAccent,
                            ),
                            SizedBox(height: 24.h),
                            EvolutionSection(
                              controller: controller,
                              accent: readableAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

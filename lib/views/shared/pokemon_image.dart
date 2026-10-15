import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Turns an image URL into the [ImageProvider] that loads it.
///
/// The app uses a disk-caching provider so artwork and sprites keep working
/// offline once seen; tests use a plain network provider.
typedef ImageProviderFactory = ImageProvider Function(String url);

/// A network image of a Pokémon (sprite or artwork), loaded through the
/// app's [ImageProviderFactory]. Same parameters as [Image.network].
class PokemonImage extends StatelessWidget {
  const PokemonImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: context.read<ImageProviderFactory>()(url),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      errorBuilder: errorBuilder,
    );
  }
}

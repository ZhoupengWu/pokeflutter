import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/team_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/responsive.dart';
import '../compare/pokemon_picker_sheet.dart';
import 'team_analysis_view.dart';
import 'team_slots.dart';

/// The Team tab: six slots and what the team is weak to and hits hard.
class TeamPage extends StatefulWidget {
  /// Pass a [controller] to drive the page from a test.
  const TeamPage({super.key, this.controller});

  final TeamController? controller;

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final TeamController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TeamController(
          team: context.read(),
          api: context.read(),
          repository: context.read(),
        );
    _controller.init();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final chosen = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => PokemonPickerSheet(allPokemon: _controller.available),
    );
    if (chosen != null) await _controller.add(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    // Room for the floating tab bar at the end of the scrolled content.
    final bottom = MediaQuery.paddingOf(context).bottom + 16.h;

    return Scaffold(
      // Not SafeArea at the bottom: the page scrolls under the floating tab bar.
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final slots = TeamSlots(controller: _controller, onAdd: _pick);
            final analysis = TeamAnalysisView(controller: _controller);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.teamTitle,
                          style: textTheme.displaySmall,
                        ),
                      ),
                      if (!_controller.isEmpty)
                        TextButton(
                          onPressed: _controller.clear,
                          child: Text(
                            l10n.teamClear,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 16.h),
                  child: Text(
                    l10n.teamSubtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.colors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => sideBySide(box)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(bottom: bottom),
                                  child: slots,
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(bottom: bottom),
                                  child: analysis,
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: bottom),
                            child: Column(children: [slots, analysis]),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

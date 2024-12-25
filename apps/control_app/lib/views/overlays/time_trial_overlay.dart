import 'package:control_app/views/loading_view.dart';
import 'package:control_app/widgets/elapsed_time_display.dart';
import 'package:control_app/widgets/video_overlay_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TimeTrialOverlay extends StatefulWidget {
  const TimeTrialOverlay({super.key});

  @override
  State<TimeTrialOverlay> createState() => _TimeTrialOverlayState();
}

class _TimeTrialOverlayState extends State<TimeTrialOverlay> {
  final _formKey = GlobalKey<FormState>();
  var _nameLoad = false;
  var name = "";

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return BlocProvider.value(
      value: context.read<TimeTrialBloc>(),
      child: BlocBuilder<TimeTrialBloc, TimeTrialState>(
        buildWhen: (previous, current) {
          if (previous.currentTrial != current.currentTrial) {
            return true;
          }

          return false;
        },
        builder: (context, state) {
          final currentTrial = state.currentTrial;
          if (currentTrial == null) {
            return const SizedBox();
          }

          if (currentTrial.userName == null) {
            return Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: _nameLoad
                        ? LoadingView(message: "Setting name...")
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Text(
                                "Enter your name",
                                style: theme.textTheme.displaySmall,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                  border: OutlineInputBorder(),
                                ),
                                validator: validateName,
                                autovalidateMode: AutovalidateMode.onUnfocus,
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FilledButton(
                                onPressed: _formKey.currentState?.validate() ==
                                        true
                                    ? () async {
                                        final timeTrialBloc =
                                            context.read<TimeTrialBloc>();

                                        setState(() {
                                          _nameLoad = true;
                                        });

                                        // TODO: set name
                                        await timeTrialBloc.stream.firstWhere(
                                          (state) =>
                                              state.currentTrial?.userName !=
                                              null,
                                        );

                                        setState(() {
                                          _nameLoad = false;
                                        });
                                      }
                                    : null,
                                child: Text("Continue"),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }

          if (currentTrial.startTime == null) {
            return Padding(
              padding: EdgeInsets.only(top: mediaQuery.viewPadding.top),
              child: Column(
                children: [
                  VideoOverlayText(text: 'Waiting for time trial to start...')
                ],
              ),
            );
          }

          if (currentTrial.startTime != null && currentTrial.endTime == null) {
            return Padding(
              padding: EdgeInsets.only(top: mediaQuery.viewPadding.top),
              child: ElapsedTimeDisplay(
                startTime: currentTrial.startTime!,
              ),
            );
          }

          // TODO: temporary
          if (currentTrial.startTime != null && currentTrial.endTime != null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Time trial completed",
                style: theme.textTheme.displayMedium,
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}

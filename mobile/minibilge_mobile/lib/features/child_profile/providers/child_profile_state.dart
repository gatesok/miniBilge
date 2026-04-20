import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/child_profile_dto.dart';

part 'child_profile_state.freezed.dart';

@freezed
class ChildProfileState with _$ChildProfileState {
  const factory ChildProfileState.initial() = _Initial;
  const factory ChildProfileState.loading() = _Loading;
  const factory ChildProfileState.loaded(List<ChildProfileDto> profiles) = _Loaded;
  const factory ChildProfileState.error(String message) = _Error;
}

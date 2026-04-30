// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_editor_validate_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityEditorValidateResponseDto
    extends SdkUnityEditorValidateResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final SdkUnityEditorValidateAppDto app;
  @override
  final SdkUnityEditorValidateChecksDto checks;
  @override
  final SdkUnityEditorValidateEditorDto editor;
  @override
  final bool ok;
  @override
  final String requestVersion;
  @override
  final BuiltList<String> warnings;

  factory _$SdkUnityEditorValidateResponseDto([
    void Function(SdkUnityEditorValidateResponseDtoBuilder)? updates,
  ]) => (SdkUnityEditorValidateResponseDtoBuilder()..update(updates))._build();

  _$SdkUnityEditorValidateResponseDto._({
    required this.acceptedAt,
    required this.app,
    required this.checks,
    required this.editor,
    required this.ok,
    required this.requestVersion,
    required this.warnings,
  }) : super._();
  @override
  SdkUnityEditorValidateResponseDto rebuild(
    void Function(SdkUnityEditorValidateResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityEditorValidateResponseDtoBuilder toBuilder() =>
      SdkUnityEditorValidateResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityEditorValidateResponseDto &&
        acceptedAt == other.acceptedAt &&
        app == other.app &&
        checks == other.checks &&
        editor == other.editor &&
        ok == other.ok &&
        requestVersion == other.requestVersion &&
        warnings == other.warnings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, app.hashCode);
    _$hash = $jc(_$hash, checks.hashCode);
    _$hash = $jc(_$hash, editor.hashCode);
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUnityEditorValidateResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('app', app)
          ..add('checks', checks)
          ..add('editor', editor)
          ..add('ok', ok)
          ..add('requestVersion', requestVersion)
          ..add('warnings', warnings))
        .toString();
  }
}

class SdkUnityEditorValidateResponseDtoBuilder
    implements
        Builder<
          SdkUnityEditorValidateResponseDto,
          SdkUnityEditorValidateResponseDtoBuilder
        > {
  _$SdkUnityEditorValidateResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  SdkUnityEditorValidateAppDtoBuilder? _app;
  SdkUnityEditorValidateAppDtoBuilder get app =>
      _$this._app ??= SdkUnityEditorValidateAppDtoBuilder();
  set app(SdkUnityEditorValidateAppDtoBuilder? app) => _$this._app = app;

  SdkUnityEditorValidateChecksDtoBuilder? _checks;
  SdkUnityEditorValidateChecksDtoBuilder get checks =>
      _$this._checks ??= SdkUnityEditorValidateChecksDtoBuilder();
  set checks(SdkUnityEditorValidateChecksDtoBuilder? checks) =>
      _$this._checks = checks;

  SdkUnityEditorValidateEditorDtoBuilder? _editor;
  SdkUnityEditorValidateEditorDtoBuilder get editor =>
      _$this._editor ??= SdkUnityEditorValidateEditorDtoBuilder();
  set editor(SdkUnityEditorValidateEditorDtoBuilder? editor) =>
      _$this._editor = editor;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  ListBuilder<String>? _warnings;
  ListBuilder<String> get warnings =>
      _$this._warnings ??= ListBuilder<String>();
  set warnings(ListBuilder<String>? warnings) => _$this._warnings = warnings;

  SdkUnityEditorValidateResponseDtoBuilder() {
    SdkUnityEditorValidateResponseDto._defaults(this);
  }

  SdkUnityEditorValidateResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _app = $v.app.toBuilder();
      _checks = $v.checks.toBuilder();
      _editor = $v.editor.toBuilder();
      _ok = $v.ok;
      _requestVersion = $v.requestVersion;
      _warnings = $v.warnings.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityEditorValidateResponseDto other) {
    _$v = other as _$SdkUnityEditorValidateResponseDto;
  }

  @override
  void update(
    void Function(SdkUnityEditorValidateResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityEditorValidateResponseDto build() => _build();

  _$SdkUnityEditorValidateResponseDto _build() {
    _$SdkUnityEditorValidateResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkUnityEditorValidateResponseDto._(
            acceptedAt: BuiltValueNullFieldError.checkNotNull(
              acceptedAt,
              r'SdkUnityEditorValidateResponseDto',
              'acceptedAt',
            ),
            app: app.build(),
            checks: checks.build(),
            editor: editor.build(),
            ok: BuiltValueNullFieldError.checkNotNull(
              ok,
              r'SdkUnityEditorValidateResponseDto',
              'ok',
            ),
            requestVersion: BuiltValueNullFieldError.checkNotNull(
              requestVersion,
              r'SdkUnityEditorValidateResponseDto',
              'requestVersion',
            ),
            warnings: warnings.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'app';
        app.build();
        _$failedField = 'checks';
        checks.build();
        _$failedField = 'editor';
        editor.build();

        _$failedField = 'warnings';
        warnings.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkUnityEditorValidateResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

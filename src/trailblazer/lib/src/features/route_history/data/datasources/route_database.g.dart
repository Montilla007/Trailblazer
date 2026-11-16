// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_database.dart';

// ignore_for_file: type=lint
class $RouteDaysTable extends RouteDays
    with TableInfo<$RouteDaysTable, RouteDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<String> localDay = GeneratedColumn<String>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, localDay, timezoneOffsetMinutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_day'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
    );
  }

  @override
  $RouteDaysTable createAlias(String alias) {
    return $RouteDaysTable(attachedDatabase, alias);
  }
}

class RouteDay extends DataClass implements Insertable<RouteDay> {
  final int id;
  final String localDay;
  final int timezoneOffsetMinutes;
  const RouteDay({
    required this.id,
    required this.localDay,
    required this.timezoneOffsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_day'] = Variable<String>(localDay);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    return map;
  }

  RouteDaysCompanion toCompanion(bool nullToAbsent) {
    return RouteDaysCompanion(
      id: Value(id),
      localDay: Value(localDay),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
    );
  }

  factory RouteDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteDay(
      id: serializer.fromJson<int>(json['id']),
      localDay: serializer.fromJson<String>(json['localDay']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localDay': serializer.toJson<String>(localDay),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
    };
  }

  RouteDay copyWith({int? id, String? localDay, int? timezoneOffsetMinutes}) =>
      RouteDay(
        id: id ?? this.id,
        localDay: localDay ?? this.localDay,
        timezoneOffsetMinutes:
            timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      );
  RouteDay copyWithCompanion(RouteDaysCompanion data) {
    return RouteDay(
      id: data.id.present ? data.id.value : this.id,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteDay(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localDay, timezoneOffsetMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteDay &&
          other.id == this.id &&
          other.localDay == this.localDay &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes);
}

class RouteDaysCompanion extends UpdateCompanion<RouteDay> {
  final Value<int> id;
  final Value<String> localDay;
  final Value<int> timezoneOffsetMinutes;
  const RouteDaysCompanion({
    this.id = const Value.absent(),
    this.localDay = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
  });
  RouteDaysCompanion.insert({
    this.id = const Value.absent(),
    required String localDay,
    required int timezoneOffsetMinutes,
  }) : localDay = Value(localDay),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes);
  static Insertable<RouteDay> custom({
    Expression<int>? id,
    Expression<String>? localDay,
    Expression<int>? timezoneOffsetMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDay != null) 'local_day': localDay,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
    });
  }

  RouteDaysCompanion copyWith({
    Value<int>? id,
    Value<String>? localDay,
    Value<int>? timezoneOffsetMinutes,
  }) {
    return RouteDaysCompanion(
      id: id ?? this.id,
      localDay: localDay ?? this.localDay,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<String>(localDay.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteDaysCompanion(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes')
          ..write(')'))
        .toString();
  }
}

class $RoutePointsTable extends RoutePoints
    with TableInfo<$RoutePointsTable, RoutePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeDayIdMeta = const VerificationMeta(
    'routeDayId',
  );
  @override
  late final GeneratedColumn<int> routeDayId = GeneratedColumn<int>(
    'route_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES route_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtUtcMeta = const VerificationMeta(
    'recordedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAtUtc =
      GeneratedColumn<DateTime>(
        'recorded_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeDayId,
    sequence,
    latitude,
    longitude,
    recordedAtUtc,
    accuracyMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutePoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_day_id')) {
      context.handle(
        _routeDayIdMeta,
        routeDayId.isAcceptableOrUnknown(
          data['route_day_id']!,
          _routeDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routeDayIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('recorded_at_utc')) {
      context.handle(
        _recordedAtUtcMeta,
        recordedAtUtc.isAcceptableOrUnknown(
          data['recorded_at_utc']!,
          _recordedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtUtcMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routeDayId, sequence},
  ];
  @override
  RoutePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutePoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_day_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      recordedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at_utc'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
    );
  }

  @override
  $RoutePointsTable createAlias(String alias) {
    return $RoutePointsTable(attachedDatabase, alias);
  }
}

class RoutePoint extends DataClass implements Insertable<RoutePoint> {
  final int id;
  final int routeDayId;
  final int sequence;
  final double latitude;
  final double longitude;
  final DateTime recordedAtUtc;
  final double? accuracyMeters;
  const RoutePoint({
    required this.id,
    required this.routeDayId,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.recordedAtUtc,
    this.accuracyMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_day_id'] = Variable<int>(routeDayId);
    map['sequence'] = Variable<int>(sequence);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['recorded_at_utc'] = Variable<DateTime>(recordedAtUtc);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    return map;
  }

  RoutePointsCompanion toCompanion(bool nullToAbsent) {
    return RoutePointsCompanion(
      id: Value(id),
      routeDayId: Value(routeDayId),
      sequence: Value(sequence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      recordedAtUtc: Value(recordedAtUtc),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
    );
  }

  factory RoutePoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutePoint(
      id: serializer.fromJson<int>(json['id']),
      routeDayId: serializer.fromJson<int>(json['routeDayId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      recordedAtUtc: serializer.fromJson<DateTime>(json['recordedAtUtc']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeDayId': serializer.toJson<int>(routeDayId),
      'sequence': serializer.toJson<int>(sequence),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'recordedAtUtc': serializer.toJson<DateTime>(recordedAtUtc),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
    };
  }

  RoutePoint copyWith({
    int? id,
    int? routeDayId,
    int? sequence,
    double? latitude,
    double? longitude,
    DateTime? recordedAtUtc,
    Value<double?> accuracyMeters = const Value.absent(),
  }) => RoutePoint(
    id: id ?? this.id,
    routeDayId: routeDayId ?? this.routeDayId,
    sequence: sequence ?? this.sequence,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    recordedAtUtc: recordedAtUtc ?? this.recordedAtUtc,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
  );
  RoutePoint copyWithCompanion(RoutePointsCompanion data) {
    return RoutePoint(
      id: data.id.present ? data.id.value : this.id,
      routeDayId: data.routeDayId.present
          ? data.routeDayId.value
          : this.routeDayId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      recordedAtUtc: data.recordedAtUtc.present
          ? data.recordedAtUtc.value
          : this.recordedAtUtc,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutePoint(')
          ..write('id: $id, ')
          ..write('routeDayId: $routeDayId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAtUtc: $recordedAtUtc, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeDayId,
    sequence,
    latitude,
    longitude,
    recordedAtUtc,
    accuracyMeters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePoint &&
          other.id == this.id &&
          other.routeDayId == this.routeDayId &&
          other.sequence == this.sequence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.recordedAtUtc == this.recordedAtUtc &&
          other.accuracyMeters == this.accuracyMeters);
}

class RoutePointsCompanion extends UpdateCompanion<RoutePoint> {
  final Value<int> id;
  final Value<int> routeDayId;
  final Value<int> sequence;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> recordedAtUtc;
  final Value<double?> accuracyMeters;
  const RoutePointsCompanion({
    this.id = const Value.absent(),
    this.routeDayId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.recordedAtUtc = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
  });
  RoutePointsCompanion.insert({
    this.id = const Value.absent(),
    required int routeDayId,
    required int sequence,
    required double latitude,
    required double longitude,
    required DateTime recordedAtUtc,
    this.accuracyMeters = const Value.absent(),
  }) : routeDayId = Value(routeDayId),
       sequence = Value(sequence),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAtUtc = Value(recordedAtUtc);
  static Insertable<RoutePoint> custom({
    Expression<int>? id,
    Expression<int>? routeDayId,
    Expression<int>? sequence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? recordedAtUtc,
    Expression<double>? accuracyMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeDayId != null) 'route_day_id': routeDayId,
      if (sequence != null) 'sequence': sequence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (recordedAtUtc != null) 'recorded_at_utc': recordedAtUtc,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
    });
  }

  RoutePointsCompanion copyWith({
    Value<int>? id,
    Value<int>? routeDayId,
    Value<int>? sequence,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? recordedAtUtc,
    Value<double?>? accuracyMeters,
  }) {
    return RoutePointsCompanion(
      id: id ?? this.id,
      routeDayId: routeDayId ?? this.routeDayId,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      recordedAtUtc: recordedAtUtc ?? this.recordedAtUtc,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeDayId.present) {
      map['route_day_id'] = Variable<int>(routeDayId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (recordedAtUtc.present) {
      map['recorded_at_utc'] = Variable<DateTime>(recordedAtUtc.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointsCompanion(')
          ..write('id: $id, ')
          ..write('routeDayId: $routeDayId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAtUtc: $recordedAtUtc, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }
}

abstract class _$RouteDatabase extends GeneratedDatabase {
  _$RouteDatabase(QueryExecutor e) : super(e);
  $RouteDatabaseManager get managers => $RouteDatabaseManager(this);
  late final $RouteDaysTable routeDays = $RouteDaysTable(this);
  late final $RoutePointsTable routePoints = $RoutePointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [routeDays, routePoints];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'route_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_points', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$RouteDaysTableCreateCompanionBuilder = RouteDaysCompanion Function({
  Value<int> id,
  required String localDay,
  required int timezoneOffsetMinutes,
});
typedef $$RouteDaysTableUpdateCompanionBuilder = RouteDaysCompanion Function({
  Value<int> id,
  Value<String> localDay,
  Value<int> timezoneOffsetMinutes,
});

final class $$RouteDaysTableReferences
    extends BaseReferences<_$RouteDatabase, $RouteDaysTable, RouteDay> {
  $$RouteDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutePointsTable, List<RoutePoint>>
  _routePointsRefsTable(_$RouteDatabase db) => MultiTypedResultKey.fromTable(
    db.routePoints,
    aliasName: 'route_days__id__route_points__route_day_id',
  );

  $$RoutePointsTableProcessedTableManager get routePointsRefs {
    final manager = $$RoutePointsTableTableManager(
      $_db,
      $_db.routePoints,
    ).filter((f) => f.routeDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routePointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RouteDaysTableFilterComposer
    extends Composer<_$RouteDatabase, $RouteDaysTable> {
  $$RouteDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routePointsRefs(
    Expression<bool> Function($$RoutePointsTableFilterComposer f) f,
  ) {
    final $$RoutePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.routeDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableFilterComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RouteDaysTableOrderingComposer
    extends Composer<_$RouteDatabase, $RouteDaysTable> {
  $$RouteDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RouteDaysTableAnnotationComposer
    extends Composer<_$RouteDatabase, $RouteDaysTable> {
  $$RouteDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  Expression<T> routePointsRefs<T extends Object>(
    Expression<T> Function($$RoutePointsTableAnnotationComposer a) f,
  ) {
    final $$RoutePointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.routeDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableAnnotationComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RouteDaysTableTableManager
    extends
        RootTableManager<
          _$RouteDatabase,
          $RouteDaysTable,
          RouteDay,
          $$RouteDaysTableFilterComposer,
          $$RouteDaysTableOrderingComposer,
          $$RouteDaysTableAnnotationComposer,
          $$RouteDaysTableCreateCompanionBuilder,
          $$RouteDaysTableUpdateCompanionBuilder,
          (RouteDay, $$RouteDaysTableReferences),
          RouteDay,
          PrefetchHooks Function({bool routePointsRefs})
        > {
  $$RouteDaysTableTableManager(_$RouteDatabase db, $RouteDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localDay = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
              }) => RouteDaysCompanion(
                id: id,
                localDay: localDay,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localDay,
                required int timezoneOffsetMinutes,
              }) => RouteDaysCompanion.insert(
                id: id,
                localDay: localDay,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RouteDaysTable, RouteDay>(table),
                  $$RouteDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routePointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routePointsRefs) db.routePoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routePointsRefs)
                    await $_getPrefetchedDataByColumns<
                      RouteDay,
                      $RouteDaysTable,
                      RoutePoint,
                      $RoutePointsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RouteDaysTableReferences
                          ._routePointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RouteDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).routePointsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'route_day_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RouteDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$RouteDatabase,
      $RouteDaysTable,
      RouteDay,
      $$RouteDaysTableFilterComposer,
      $$RouteDaysTableOrderingComposer,
      $$RouteDaysTableAnnotationComposer,
      $$RouteDaysTableCreateCompanionBuilder,
      $$RouteDaysTableUpdateCompanionBuilder,
      (RouteDay, $$RouteDaysTableReferences),
      RouteDay,
      PrefetchHooks Function({bool routePointsRefs})
    >;
typedef $$RoutePointsTableCreateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      required int routeDayId,
      required int sequence,
      required double latitude,
      required double longitude,
      required DateTime recordedAtUtc,
      Value<double?> accuracyMeters,
    });
typedef $$RoutePointsTableUpdateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      Value<int> routeDayId,
      Value<int> sequence,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> recordedAtUtc,
      Value<double?> accuracyMeters,
    });

final class $$RoutePointsTableReferences
    extends BaseReferences<_$RouteDatabase, $RoutePointsTable, RoutePoint> {
  $$RoutePointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RouteDaysTable _routeDayIdTable(_$RouteDatabase db) =>
      db.routeDays.createAlias('route_points__route_day_id__route_days__id');

  $$RouteDaysTableProcessedTableManager get routeDayId {
    final $_column = $_itemColumn<int>('route_day_id')!;

    final manager = $$RouteDaysTableTableManager(
      $_db,
      $_db.routeDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutePointsTableFilterComposer
    extends Composer<_$RouteDatabase, $RoutePointsTable> {
  $$RoutePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAtUtc => $composableBuilder(
    column: $table.recordedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  $$RouteDaysTableFilterComposer get routeDayId {
    final $$RouteDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeDayId,
      referencedTable: $db.routeDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteDaysTableFilterComposer(
            $db: $db,
            $table: $db.routeDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableOrderingComposer
    extends Composer<_$RouteDatabase, $RoutePointsTable> {
  $$RoutePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAtUtc => $composableBuilder(
    column: $table.recordedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  $$RouteDaysTableOrderingComposer get routeDayId {
    final $$RouteDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeDayId,
      referencedTable: $db.routeDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routeDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableAnnotationComposer
    extends Composer<_$RouteDatabase, $RoutePointsTable> {
  $$RoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAtUtc => $composableBuilder(
    column: $table.recordedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  $$RouteDaysTableAnnotationComposer get routeDayId {
    final $$RouteDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeDayId,
      referencedTable: $db.routeDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routeDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableTableManager
    extends
        RootTableManager<
          _$RouteDatabase,
          $RoutePointsTable,
          RoutePoint,
          $$RoutePointsTableFilterComposer,
          $$RoutePointsTableOrderingComposer,
          $$RoutePointsTableAnnotationComposer,
          $$RoutePointsTableCreateCompanionBuilder,
          $$RoutePointsTableUpdateCompanionBuilder,
          (RoutePoint, $$RoutePointsTableReferences),
          RoutePoint,
          PrefetchHooks Function({bool routeDayId})
        > {
  $$RoutePointsTableTableManager(_$RouteDatabase db, $RoutePointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutePointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeDayId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> recordedAtUtc = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
              }) => RoutePointsCompanion(
                id: id,
                routeDayId: routeDayId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                recordedAtUtc: recordedAtUtc,
                accuracyMeters: accuracyMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeDayId,
                required int sequence,
                required double latitude,
                required double longitude,
                required DateTime recordedAtUtc,
                Value<double?> accuracyMeters = const Value.absent(),
              }) => RoutePointsCompanion.insert(
                id: id,
                routeDayId: routeDayId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                recordedAtUtc: recordedAtUtc,
                accuracyMeters: accuracyMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutePointsTable, RoutePoint>(table),
                  $$RoutePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeDayId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routeDayId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routeDayId,
                        referencedTable: $$RoutePointsTableReferences
                            ._routeDayIdTable(db),
                        referencedColumn: $$RoutePointsTableReferences
                            ._routeDayIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$RouteDatabase,
      $RoutePointsTable,
      RoutePoint,
      $$RoutePointsTableFilterComposer,
      $$RoutePointsTableOrderingComposer,
      $$RoutePointsTableAnnotationComposer,
      $$RoutePointsTableCreateCompanionBuilder,
      $$RoutePointsTableUpdateCompanionBuilder,
      (RoutePoint, $$RoutePointsTableReferences),
      RoutePoint,
      PrefetchHooks Function({bool routeDayId})
    >;

class $RouteDatabaseManager {
  final _$RouteDatabase _db;
  $RouteDatabaseManager(this._db);
  $$RouteDaysTableTableManager get routeDays =>
      $$RouteDaysTableTableManager(_db, _db.routeDays);
  $$RoutePointsTableTableManager get routePoints =>
      $$RoutePointsTableTableManager(_db, _db.routePoints);
}

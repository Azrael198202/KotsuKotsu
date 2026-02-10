// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskProgressEntityCollection on Isar {
  IsarCollection<TaskProgressEntity> get taskProgressEntitys =>
      this.collection();
}

const TaskProgressEntitySchema = CollectionSchema(
  name: r'TaskProgressEntity',
  id: 9151898779164180793,
  properties: {
    r'correct': PropertySchema(
      id: 0,
      name: r'correct',
      type: IsarType.long,
    ),
    r'durationSeconds': PropertySchema(
      id: 1,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'grade': PropertySchema(
      id: 2,
      name: r'grade',
      type: IsarType.long,
    ),
    r'isPassed': PropertySchema(
      id: 3,
      name: r'isPassed',
      type: IsarType.bool,
    ),
    r'isPerfect': PropertySchema(
      id: 4,
      name: r'isPerfect',
      type: IsarType.bool,
    ),
    r'passScore': PropertySchema(
      id: 5,
      name: r'passScore',
      type: IsarType.long,
    ),
    r'scoreLabel': PropertySchema(
      id: 6,
      name: r'scoreLabel',
      type: IsarType.string,
    ),
    r'taskKey': PropertySchema(
      id: 7,
      name: r'taskKey',
      type: IsarType.string,
    ),
    r'timeLimitSeconds': PropertySchema(
      id: 8,
      name: r'timeLimitSeconds',
      type: IsarType.long,
    ),
    r'total': PropertySchema(
      id: 9,
      name: r'total',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _taskProgressEntityEstimateSize,
  serialize: _taskProgressEntitySerialize,
  deserialize: _taskProgressEntityDeserialize,
  deserializeProp: _taskProgressEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _taskProgressEntityGetId,
  getLinks: _taskProgressEntityGetLinks,
  attach: _taskProgressEntityAttach,
  version: '3.1.0+1',
);

int _taskProgressEntityEstimateSize(
  TaskProgressEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.scoreLabel.length * 3;
  bytesCount += 3 + object.taskKey.length * 3;
  return bytesCount;
}

void _taskProgressEntitySerialize(
  TaskProgressEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.correct);
  writer.writeLong(offsets[1], object.durationSeconds);
  writer.writeLong(offsets[2], object.grade);
  writer.writeBool(offsets[3], object.isPassed);
  writer.writeBool(offsets[4], object.isPerfect);
  writer.writeLong(offsets[5], object.passScore);
  writer.writeString(offsets[6], object.scoreLabel);
  writer.writeString(offsets[7], object.taskKey);
  writer.writeLong(offsets[8], object.timeLimitSeconds);
  writer.writeLong(offsets[9], object.total);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

TaskProgressEntity _taskProgressEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskProgressEntity();
  object.correct = reader.readLong(offsets[0]);
  object.durationSeconds = reader.readLong(offsets[1]);
  object.grade = reader.readLong(offsets[2]);
  object.id = id;
  object.passScore = reader.readLong(offsets[5]);
  object.taskKey = reader.readString(offsets[7]);
  object.timeLimitSeconds = reader.readLong(offsets[8]);
  object.total = reader.readLong(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _taskProgressEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskProgressEntityGetId(TaskProgressEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskProgressEntityGetLinks(
    TaskProgressEntity object) {
  return [];
}

void _taskProgressEntityAttach(
    IsarCollection<dynamic> col, Id id, TaskProgressEntity object) {
  object.id = id;
}

extension TaskProgressEntityQueryWhereSort
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QWhere> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TaskProgressEntityQueryWhere
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QWhereClause> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskProgressEntityQueryFilter
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QFilterCondition> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      correctEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      correctGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      correctLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      correctBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      durationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      gradeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grade',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      gradeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grade',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      gradeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grade',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      gradeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      isPassedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPassed',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      isPerfectEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPerfect',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      passScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passScore',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      passScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'passScore',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      passScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'passScore',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      passScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'passScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scoreLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scoreLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scoreLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      scoreLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scoreLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      taskKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      timeLimitSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeLimitSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      timeLimitSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeLimitSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      timeLimitSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeLimitSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      timeLimitSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeLimitSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      totalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      totalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      totalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      totalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskProgressEntityQueryObject
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QFilterCondition> {}

extension TaskProgressEntityQueryLinks
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QFilterCondition> {}

extension TaskProgressEntityQuerySortBy
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QSortBy> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByIsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByIsPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPerfect', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByIsPerfectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPerfect', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByPassScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passScore', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByPassScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passScore', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByScoreLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreLabel', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByScoreLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreLabel', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTimeLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeLimitSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTimeLimitSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeLimitSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskProgressEntityQuerySortThenBy
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QSortThenBy> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByIsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByIsPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPerfect', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByIsPerfectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPerfect', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByPassScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passScore', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByPassScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passScore', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByScoreLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreLabel', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByScoreLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreLabel', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTimeLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeLimitSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTimeLimitSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeLimitSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskProgressEntityQueryWhereDistinct
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct> {
  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correct');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grade');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPassed');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByIsPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPerfect');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByPassScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passScore');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByScoreLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByTaskKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByTimeLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeLimitSeconds');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<TaskProgressEntity, TaskProgressEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TaskProgressEntityQueryProperty
    on QueryBuilder<TaskProgressEntity, TaskProgressEntity, QQueryProperty> {
  QueryBuilder<TaskProgressEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correct');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations> gradeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grade');
    });
  }

  QueryBuilder<TaskProgressEntity, bool, QQueryOperations> isPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPassed');
    });
  }

  QueryBuilder<TaskProgressEntity, bool, QQueryOperations> isPerfectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPerfect');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations> passScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passScore');
    });
  }

  QueryBuilder<TaskProgressEntity, String, QQueryOperations>
      scoreLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreLabel');
    });
  }

  QueryBuilder<TaskProgressEntity, String, QQueryOperations> taskKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskKey');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations>
      timeLimitSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeLimitSeconds');
    });
  }

  QueryBuilder<TaskProgressEntity, int, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<TaskProgressEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

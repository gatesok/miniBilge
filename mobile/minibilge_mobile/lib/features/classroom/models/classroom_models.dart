/// Sprint 28 – Classroom modelleri
/// Backend ClassroomDto/AssignmentSummaryDto'yu yansıtır.

class AssignmentSummaryDto {
  final String  id;
  final String  levelId;
  final String  title;
  final String  topicName;
  final String  subjectName;
  final DateTime? dueDate;
  final int     minQuestions;
  final int     myProgress;
  final bool    isCompleted;
  final int     memberCount;
  final int     completedBy;
  final int     averageCorrectCount;

  const AssignmentSummaryDto({
    required this.id,
    required this.levelId,
    required this.title,
    required this.topicName,
    required this.subjectName,
    this.dueDate,
    required this.minQuestions,
    required this.myProgress,
    required this.isCompleted,
    required this.memberCount,
    required this.completedBy,
    required this.averageCorrectCount,
  });

  factory AssignmentSummaryDto.fromJson(Map<String, dynamic> j) =>
      AssignmentSummaryDto(
        id:           j['Id'] as String,
        levelId:      j['LevelId'] as String? ?? '',
        title:        j['Title'] as String,
        topicName:    j['TopicName'] as String? ?? '',
        subjectName:  j['SubjectName'] as String? ?? '',
        dueDate:      j['DueDate'] != null
            ? DateTime.parse(j['DueDate'] as String).toLocal()
            : null,
        minQuestions: j['MinQuestions'] as int? ?? 10,
        myProgress:   j['MyProgress'] as int? ?? 0,
        isCompleted:  j['IsCompleted'] as bool? ?? false,
        memberCount:  j['MemberCount'] as int? ?? 0,
        completedBy:  j['CompletedBy'] as int? ?? 0,
        averageCorrectCount: j['AverageCorrectCount'] as int? ?? 0,
      );
}

class ClassroomMemberDto {
  final String  childProfileId;
  final String  name;
  final String? avatarUrl;
  final int     completedAssignments;

  const ClassroomMemberDto({
    required this.childProfileId,
    required this.name,
    this.avatarUrl,
    required this.completedAssignments,
  });

  factory ClassroomMemberDto.fromJson(Map<String, dynamic> j) =>
      ClassroomMemberDto(
        childProfileId:      j['ChildProfileId'] as String,
        name:                j['Name'] as String,
        avatarUrl:           j['AvatarUrl'] as String?,
        completedAssignments: j['CompletedAssignments'] as int? ?? 0,
      );
}

class ClassroomDto {
  final String   id;
  final String   name;
  final String   inviteCode;
  final int      memberCount;
  final String   myRole;   // "Owner" | "Student"
  final List<AssignmentSummaryDto> assignments;

  const ClassroomDto({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
    required this.myRole,
    required this.assignments,
  });

  bool get isOwner => myRole == 'Owner';

  factory ClassroomDto.fromJson(Map<String, dynamic> j) => ClassroomDto(
        id:          j['Id'] as String,
        name:        j['Name'] as String,
        inviteCode:  j['InviteCode'] as String? ?? '',
        memberCount: j['MemberCount'] as int? ?? 0,
        myRole:      j['MyRole'] as String? ?? 'Student',
        assignments: (j['Assignments'] as List? ?? [])
            .map((e) => AssignmentSummaryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ClassroomDetailDto extends ClassroomDto {
  final List<ClassroomMemberDto> members;

  const ClassroomDetailDto({
    required super.id,
    required super.name,
    required super.inviteCode,
    required super.memberCount,
    required super.myRole,
    required super.assignments,
    required this.members,
  });

  factory ClassroomDetailDto.fromJson(Map<String, dynamic> j) =>
      ClassroomDetailDto(
        id:          j['Id'] as String,
        name:        j['Name'] as String,
        inviteCode:  j['InviteCode'] as String? ?? '',
        memberCount: j['MemberCount'] as int? ?? 0,
        myRole:      j['MyRole'] as String? ?? 'Student',
        assignments: (j['Assignments'] as List? ?? [])
            .map((e) => AssignmentSummaryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        members: (j['Members'] as List? ?? [])
            .map((e) => ClassroomMemberDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Sprint 28 – Classroom modelleri
/// Backend ClassroomDto/AssignmentSummaryDto'yu yansıtır.

class AssignmentSummaryDto {
  final String  id;
  final String  title;
  final String  topicName;
  final String  subjectName;
  final DateTime? dueDate;
  final int     minQuestions;
  final int     myProgress;
  final bool    isCompleted;
  final int     memberCount;
  final int     completedBy;

  const AssignmentSummaryDto({
    required this.id,
    required this.title,
    required this.topicName,
    required this.subjectName,
    this.dueDate,
    required this.minQuestions,
    required this.myProgress,
    required this.isCompleted,
    required this.memberCount,
    required this.completedBy,
  });

  factory AssignmentSummaryDto.fromJson(Map<String, dynamic> j) =>
      AssignmentSummaryDto(
        id:           j['id'] as String,
        title:        j['title'] as String,
        topicName:    j['topicName'] as String? ?? '',
        subjectName:  j['subjectName'] as String? ?? '',
        dueDate:      j['dueDate'] != null
            ? DateTime.parse(j['dueDate'] as String).toLocal()
            : null,
        minQuestions: j['minQuestions'] as int? ?? 10,
        myProgress:   j['myProgress'] as int? ?? 0,
        isCompleted:  j['isCompleted'] as bool? ?? false,
        memberCount:  j['memberCount'] as int? ?? 0,
        completedBy:  j['completedBy'] as int? ?? 0,
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
        childProfileId:      j['childProfileId'] as String,
        name:                j['name'] as String,
        avatarUrl:           j['avatarUrl'] as String?,
        completedAssignments: j['completedAssignments'] as int? ?? 0,
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
        id:          j['id'] as String,
        name:        j['name'] as String,
        inviteCode:  j['inviteCode'] as String,
        memberCount: j['memberCount'] as int? ?? 0,
        myRole:      j['myRole'] as String? ?? 'Student',
        assignments: (j['assignments'] as List? ?? [])
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
        id:          j['id'] as String,
        name:        j['name'] as String,
        inviteCode:  j['inviteCode'] as String,
        memberCount: j['memberCount'] as int? ?? 0,
        myRole:      j['myRole'] as String? ?? 'Student',
        assignments: (j['assignments'] as List? ?? [])
            .map((e) => AssignmentSummaryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        members: (j['members'] as List? ?? [])
            .map((e) => ClassroomMemberDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

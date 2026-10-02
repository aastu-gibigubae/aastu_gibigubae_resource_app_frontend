import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_database.dart';
import '../../domain/entities/course_item.dart';
import '../../domain/entities/resource_category_type.dart';
import '../../domain/entities/resource_item.dart';
import '../../domain/entities/stream_item.dart';

/// ================================================================
/// RESOURCE LOCAL DATASOURCE
///
/// Handles offline caching and retrieval of:
///  - Streams (Engineering, Science)
///  - Departments
///  - Courses
///  - Category Resource Items
///  - Downloaded Resource Records
/// ================================================================
class ResourceLocalDatasource {
  const ResourceLocalDatasource();

  // ── Streams ────────────────────────────────────────────────────

  Future<void> cacheStreams(List<StreamItem> streams) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final s in streams) {
        await LocalDatabase.insert(
          StorageKeys.cachedStreamsTable,
          {
            StorageKeys.colId: s.id,
            StorageKeys.colTitle: s.name,
            StorageKeys.colSyncedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] cacheStreams error: $e');
    }
  }

  Future<List<StreamItem>> getCachedStreams() async {
    try {
      final rows = await LocalDatabase.query(StorageKeys.cachedStreamsTable);
      return rows
          .map((r) => StreamItem(
                id: r[StorageKeys.colId] as int,
                name: r[StorageKeys.colTitle] as String,
              ))
          .toList();
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getCachedStreams error: $e');
      return [];
    }
  }

  // ── Departments ────────────────────────────────────────────────

  Future<void> cacheDepartments(
    int streamId,
    List<({int id, String name})> departments,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final d in departments) {
        await LocalDatabase.insert(
          StorageKeys.cachedDepartmentsTable,
          {
            StorageKeys.colId: d.id,
            StorageKeys.colStreamId: streamId,
            StorageKeys.colTitle: d.name,
            StorageKeys.colSyncedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] cacheDepartments error: $e');
    }
  }

  Future<List<({int id, String name})>> getCachedDepartments(
    int streamId,
  ) async {
    try {
      final rows = await LocalDatabase.query(
        StorageKeys.cachedDepartmentsTable,
        where: '${StorageKeys.colStreamId} = ?',
        whereArgs: [streamId],
      );
      return rows
          .map((r) => (
                id: r[StorageKeys.colId] as int,
                name: r[StorageKeys.colTitle] as String,
              ))
          .toList();
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getCachedDepartments error: $e');
      return [];
    }
  }

  // ── Courses ────────────────────────────────────────────────────

  Future<void> cacheCourses(List<CourseItem> courses) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final c in courses) {
        await LocalDatabase.insert(
          StorageKeys.cachedCoursesTable,
          {
            StorageKeys.colId: c.id,
            StorageKeys.colDepartmentId: c.departmentId,
            StorageKeys.colTitle: c.name,
            StorageKeys.colAcademicYear: c.academicYear,
            StorageKeys.colStreamId: c.streamId,
            StorageKeys.colIconKey: c.iconKey,
            StorageKeys.colResourceCount: c.resourceCount,
            StorageKeys.colSemesterLabel: c.semesterLabel,
            StorageKeys.colSyncedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] cacheCourses error: $e');
    }
  }

  Future<List<CourseItem>> getCachedCourses({
    int? streamId,
    int? departmentId,
    int? year,
  }) async {
    try {
      final conditions = <String>[];
      final args = <dynamic>[];

      if (year != null && year > 0) {
        conditions.add('${StorageKeys.colAcademicYear} = ?');
        args.add(year);
      }
      if (departmentId != null && departmentId > 0) {
        conditions.add('${StorageKeys.colDepartmentId} = ?');
        args.add(departmentId);
      }
      if (streamId != null && streamId > 0) {
        conditions.add(
          '(${StorageKeys.colStreamId} = ? OR ${StorageKeys.colStreamId} IS NULL)',
        );
        args.add(streamId);
      }

      final whereClause =
          conditions.isNotEmpty ? conditions.join(' AND ') : null;

      final rows = await LocalDatabase.query(
        StorageKeys.cachedCoursesTable,
        where: whereClause,
        whereArgs: args.isNotEmpty ? args : null,
        orderBy: '${StorageKeys.colTitle} ASC',
      );

      return rows
          .map((r) => CourseItem(
                id: r[StorageKeys.colId] as int,
                departmentId: (r[StorageKeys.colDepartmentId] as int?) ?? 0,
                name: r[StorageKeys.colTitle] as String,
                academicYear: r[StorageKeys.colAcademicYear] as int,
                iconKey: (r[StorageKeys.colIconKey] as String?) ?? 'book',
                resourceCount:
                    (r[StorageKeys.colResourceCount] as int?) ?? 16,
                semesterLabel: r[StorageKeys.colSemesterLabel] as String?,
                streamId: r[StorageKeys.colStreamId] as int?,
              ))
          .toList();
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getCachedCourses error: $e');
      return [];
    }
  }

  // ── Resources ──────────────────────────────────────────────────

  Future<void> cacheResources(
    int courseId,
    String category,
    List<ResourceItem> resources,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final r in resources) {
        await LocalDatabase.insert(
          StorageKeys.cachedResourceItemsTable,
          {
            StorageKeys.colId: r.id,
            StorageKeys.colCourseId: courseId,
            StorageKeys.colTitle: r.title,
            StorageKeys.colDescription: r.description,
            StorageKeys.colCategory: category,
            StorageKeys.colIsFreeSample: r.isFreeSample ? 1 : 0,
            StorageKeys.colLocked: r.locked ? 1 : 0,
            StorageKeys.colMessage: r.message,
            StorageKeys.colFileUrl: r.fileUrl,
            StorageKeys.colFileSizeBytes: r.fileSizeBytes,
            StorageKeys.colChecksum: r.checksum,
            StorageKeys.colCourseName: r.courseName,
            StorageKeys.colSemesterLabel: r.semester,
            StorageKeys.colAcademicYear: r.academicYear,
            StorageKeys.colSyncedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] cacheResources error: $e');
    }
  }

  Future<List<ResourceItem>> getCachedResources({
    required int courseId,
    required String category,
  }) async {
    try {
      final rows = await LocalDatabase.query(
        StorageKeys.cachedResourceItemsTable,
        where:
            '${StorageKeys.colCourseId} = ? AND ${StorageKeys.colCategory} = ?',
        whereArgs: [courseId, category],
        orderBy: '${StorageKeys.colId} ASC',
      );

      return rows.map(_mapRowToResourceItem).toList();
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getCachedResources error: $e');
      return [];
    }
  }

  Future<ResourceItem?> getCachedResourceById(int id) async {
    try {
      final rows = await LocalDatabase.query(
        StorageKeys.cachedResourceItemsTable,
        where: '${StorageKeys.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _mapRowToResourceItem(rows.first);
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getCachedResourceById error: $e');
      return null;
    }
  }

  // ── Downloaded Resources (Offline Store) ───────────────────────

  Future<void> saveDownloadedResource({
    required ResourceItem resource,
    required String filePath,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // 1. Insert into cachedResourcesTable (tracks file path & download state)
      await LocalDatabase.insert(
        StorageKeys.cachedResourcesTable,
        {
          StorageKeys.colResourceId: resource.id.toString(),
          StorageKeys.colFilePath: filePath,
          StorageKeys.colChecksum: resource.checksum ?? '',
          StorageKeys.colCachedAt: now,
          StorageKeys.colIsPremium: resource.locked ? 1 : 0,
          StorageKeys.colTitle: resource.title,
          StorageKeys.colCategory: resource.category.apiValue,
          StorageKeys.colCourseName: resource.courseName,
          StorageKeys.colFileSizeBytes: resource.fileSizeBytes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Also ensure it exists in cachedResourceItemsTable with local path
      await LocalDatabase.insert(
        StorageKeys.cachedResourceItemsTable,
        {
          StorageKeys.colId: resource.id,
          StorageKeys.colCourseId: resource.courseId,
          StorageKeys.colTitle: resource.title,
          StorageKeys.colDescription: resource.description,
          StorageKeys.colCategory: resource.category.apiValue,
          StorageKeys.colIsFreeSample: resource.isFreeSample ? 1 : 0,
          StorageKeys.colLocked: resource.locked ? 1 : 0,
          StorageKeys.colMessage: resource.message,
          StorageKeys.colFileUrl: resource.fileUrl,
          StorageKeys.colFileSizeBytes: resource.fileSizeBytes,
          StorageKeys.colChecksum: resource.checksum,
          StorageKeys.colCourseName: resource.courseName,
          StorageKeys.colSemesterLabel: resource.semester,
          StorageKeys.colAcademicYear: resource.academicYear,
          StorageKeys.colSyncedAt: now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] saveDownloadedResource error: $e');
    }
  }

  Future<List<ResourceItem>> getDownloadedResources() async {
    try {
      final rows = await LocalDatabase.query(
        StorageKeys.cachedResourcesTable,
        orderBy: '${StorageKeys.colCachedAt} DESC',
      );

      final items = <ResourceItem>[];
      for (final r in rows) {
        final filePath = r[StorageKeys.colFilePath] as String?;
        if (filePath != null && await File(filePath).exists()) {
          final resId =
              int.tryParse(r[StorageKeys.colResourceId].toString()) ?? 0;
          final title = (r[StorageKeys.colTitle] as String?) ?? 'Downloaded PDF';
          final categoryStr = (r[StorageKeys.colCategory] as String?) ?? 'handouts';
          final courseName = (r[StorageKeys.colCourseName] as String?) ?? '';
          final fileSizeBytes = (r[StorageKeys.colFileSizeBytes] as int?) ?? 0;

          items.add(ResourceItem(
            id: resId,
            title: title,
            courseName: courseName,
            category: ResourceCategoryType.fromString(categoryStr),
            fileSizeBytes: fileSizeBytes,
            fileUrl: filePath,
            locked: false,
          ));
        }
      }
      return items;
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] getDownloadedResources error: $e');
      return [];
    }
  }

  Future<void> deleteDownloadedResource(int resourceId) async {
    try {
      await LocalDatabase.delete(
        StorageKeys.cachedResourcesTable,
        where: '${StorageKeys.colResourceId} = ?',
        whereArgs: [resourceId.toString()],
      );
    } catch (e) {
      debugPrint('[ResourceLocalDatasource] deleteDownloadedResource error: $e');
    }
  }

  // ── Mapping Helper ─────────────────────────────────────────────

  ResourceItem _mapRowToResourceItem(Map<String, dynamic> r) {
    return ResourceItem(
      id: r[StorageKeys.colId] as int,
      courseId: (r[StorageKeys.colCourseId] as int?) ?? 0,
      title: r[StorageKeys.colTitle] as String,
      description: r[StorageKeys.colDescription] as String?,
      category: ResourceCategoryType.fromString(
        r[StorageKeys.colCategory] as String? ?? 'handouts',
      ),
      isFreeSample: (r[StorageKeys.colIsFreeSample] as int?) == 1,
      locked: (r[StorageKeys.colLocked] as int?) == 1,
      message: r[StorageKeys.colMessage] as String?,
      fileUrl: r[StorageKeys.colFileUrl] as String?,
      fileSizeBytes: (r[StorageKeys.colFileSizeBytes] as int?) ?? 0,
      checksum: r[StorageKeys.colChecksum] as String?,
      courseName: (r[StorageKeys.colCourseName] as String?) ?? '',
      semester: (r[StorageKeys.colSemesterLabel] as String?) ?? 'Semester 1',
      academicYear: (r[StorageKeys.colAcademicYear] as int?) ?? 1,
    );
  }
}

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseStorageClient _storage = Supabase.instance.client.storage;

  /// Uploads a file to path and returns the public download URL.
  Future<String> uploadFile(File file, String path) async {
    // Bucket name 'upload' as defined in Supabase dashboard
    final uploadPath = path;
    await _storage.from('upload').upload(uploadPath, file);
    return _storage.from('upload').getPublicUrl(uploadPath);
  }
}

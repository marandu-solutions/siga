import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // Importe o pacote path para lidar com extensões

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- MÉTODOS PÚBLICOS E ESPECÍFICOS ---

  /// Faz o upload da foto de um item do CATÁLOGO.
  /// Os arquivos são salvos em: /catalogo/{empresaId}/{nome_unico}.jpg
  Future<String?> uploadFotoCatalogo({
    required XFile file,
    required String empresaId,
  }) async {
    // Gera um nome de arquivo único usando o tempo atual para evitar sobreposições.
    final extensao = p.extension(file.path); // Pega a extensão original (.jpg, .png)
    final nomeArquivoUnico = '${DateTime.now().millisecondsSinceEpoch}$extensao';
    final path = 'catalogo/$empresaId/$nomeArquivoUnico';
    
    return await _uploadFile(file, path);
  }

  /// Faz o upload da foto de um item do ESTOQUE.
  /// Os arquivos são salvos em: /estoque/{empresaId}/{nome_unico}.jpg
  Future<String?> uploadFotoEstoque({
    required XFile file,
    required String empresaId,
  }) async {
    final extensao = p.extension(file.path);
    final nomeArquivoUnico = '${DateTime.now().millisecondsSinceEpoch}$extensao';
    final path = 'estoque/$empresaId/$nomeArquivoUnico';

    return await _uploadFile(file, path);
  }

  /// Faz o upload da foto de PERFIL de um usuário.
  /// Os arquivos são salvos em: /perfil_usuarios/{userId}/profile.jpg
  Future<String?> uploadFotoPerfil({
    required XFile file,
    required String userId,
  }) async {
    // Para fotos de perfil, geralmente queremos substituir a antiga,
    // então usamos um nome de arquivo fixo.
    final path = 'perfil_usuarios/$userId/profile.jpg';

    return await _uploadFile(file, path);
  }


  // --- MÉTODO PRIVADO DE UPLOAD ---

  /// Método auxiliar privado que contém a lógica de upload repetida.
  Future<String?> _uploadFile(XFile file, String path) async {
    try {
      final ref = _storage.ref(path);
      final uploadTask = await ref.putFile(File(file.path));
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      print("❌ Erro no upload da imagem para o caminho '$path': $e");
      return null;
    }
  }
}
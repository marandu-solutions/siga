import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:siga/Model/empresa.dart';
import 'package:siga/Model/funcionario.dart';


// ✅ ADICIONAMOS UM NOVO ESTADO
enum AuthStatus {
  uninitialized,
  authenticating, // Verificando login/senha no Firebase Auth
  loadingData,    // Já autenticado no Auth, mas carregando dados do Firestore
  authenticated,  // Autenticado e com todos os dados carregados
  unauthenticated,
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  Funcionario? _funcionarioLogado;
  Empresa? _empresaAtual;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  Funcionario? get funcionarioLogado => _funcionarioLogado;
  Empresa? get empresaAtual => _empresaAtual;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ✅ LÓGICA DO LISTENER REFINADA
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _funcionarioLogado = null;
      _empresaAtual = null;
    } else {
      _firebaseUser = user;
      
      // Imediatamente dizemos à UI que estamos carregando os dados do Firestore
      _status = AuthStatus.loadingData; 
      notifyListeners();

      await _loadUserData(user.uid);
      
      if (_funcionarioLogado != null && _empresaAtual != null) {
        // Apenas se TUDO carregou com sucesso, o estado se torna 'authenticated'
        _status = AuthStatus.authenticated;
      } else {
        print("🚨 ALERTA: Falha ao carregar dados do Firestore para o usuário ${user.uid}. Deslogando.");
        await signOut();
        // O próprio signOut vai mudar o status para unauthenticated e notificar.
        return; 
      }
    }
    notifyListeners();
  }

  /// Carrega os dados customizados do funcionário e da empresa do Firestore.
  Future<void> _loadUserData(String uid) async {
    try {
      final funcionarioDoc = await _db.collection('funcionarios').doc(uid).get();
      
      if (funcionarioDoc.exists) {
        _funcionarioLogado = Funcionario.fromFirestore(funcionarioDoc);

        if (_funcionarioLogado!.empresaId.isNotEmpty) {
          final empresaDoc = await _db.collection('empresas').doc(_funcionarioLogado!.empresaId).get();
          if (empresaDoc.exists) {
            _empresaAtual = Empresa.fromFirestore(empresaDoc);
          }
        }
      } else {
        // Garante que os dados fiquem nulos se o documento não for encontrado.
        _funcionarioLogado = null;
        _empresaAtual = null;
      }
    } catch (e) {
      print("❌ Erro ao carregar dados do usuário do Firestore: $e");
      _funcionarioLogado = null;
      _empresaAtual = null;
    }
  }

  /// Realiza o login de um usuário com e-mail e senha.
  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // O listener _onAuthStateChanged fará o resto, incluindo mudar para loadingData.
      return true;
    } catch (e) {
      print("❌ Erro no signIn: $e");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  /// Realiza o cadastro de uma nova empresa e seu primeiro funcionário (dono/admin).
  /// Usa um WriteBatch para garantir que ambas as operações no Firestore
  /// (criar empresa e criar funcionário) aconteçam de forma atômica.
  Future<bool> signUpAsOwner({
    required String nomeEmpresa,
    required String proprietario,
    required String cpf,
    required String telefone,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      // 1. Cria o usuário no Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUser = userCredential.user!;

      // 2. Prepara os objetos de modelo para o Firestore
      final novaEmpresa = Empresa(
        id: newUser.uid,
        nomeEmpresa: nomeEmpresa,
        proprietario: proprietario,
        email: email,
        telefone: telefone,
        cpf: cpf,
        createdAt: Timestamp.now(),
      );

      final primeiroFuncionario = Funcionario(
        uid: newUser.uid,
        empresaId: newUser.uid, // O dono pertence à sua própria empresa
        nome: proprietario,
        email: email,
        cargo: 'admin',
        ativo: true,
      );

      // 3. Executa a escrita atômica no Firestore
      final batch = _db.batch();
      batch.set(_db.collection('empresas').doc(novaEmpresa.id), novaEmpresa.toMap());
      batch.set(_db.collection('funcionarios').doc(primeiroFuncionario.uid), primeiroFuncionario.toMap());
      await batch.commit();
      
      // O listener _onAuthStateChanged cuidará do resto.
      return true;
    } catch (e) {
      print("❌ Erro no signUpAsOwner: $e");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  /// Realiza o logout do usuário atual.
  Future<void> signOut() async {
    await _auth.signOut();
    // O listener _onAuthStateChanged cuida da limpeza do estado.
  }
}
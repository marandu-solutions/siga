// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Model/empresa.dart';
import '../Model/funcionario.dart';

// (coloque o enum AuthStatus aqui se preferir)

enum AuthStatus {
  uninitialized, // Estado inicial, antes de checarmos
  authenticating, // Carregando, aguardando o Firebase
  authenticated,  // Logado com sucesso
  unauthenticated, // Não está logado
}

class AuthService with ChangeNotifier {
  // Instâncias do Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Estado interno do serviço
  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  Funcionario? _funcionarioLogado;
  Empresa? _empresaAtual;

  // Getters públicos para a UI acessar os dados
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  Funcionario? get funcionarioLogado => _funcionarioLogado;
  Empresa? get empresaAtual => _empresaAtual;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthService() {
    // Listener MÁGICO do Firebase Auth.
    // Ele é chamado automaticamente sempre que o usuário loga ou desloga.
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Método chamado pelo listener do Firebase Auth.
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      // Se o usuário deslogou
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _funcionarioLogado = null;
      _empresaAtual = null;
    } else {
      // Se o usuário logou
      _firebaseUser = user;
      // Agora, buscamos nossos dados customizados no Firestore
      await _loadUserData(user.uid);
      _status = AuthStatus.authenticated;
    }
    // Notifica todos os 'ouvintes' (a UI) que o estado mudou.
    notifyListeners();
  }

  /// Carrega os dados do Funcionário e da Empresa do Firestore.
  Future<void> _loadUserData(String uid) async {
    try {
      // 1. Busca o documento do funcionário
      DocumentSnapshot funcionarioDoc = await _db.collection('funcionarios').doc(uid).get();
      if (funcionarioDoc.exists) {
        _funcionarioLogado = Funcionario.fromFirestore(funcionarioDoc);

        // 2. Com o funcionário em mãos, busca a empresa correspondente
        if (_funcionarioLogado!.empresaId.isNotEmpty) {
          DocumentSnapshot empresaDoc = await _db.collection('empresas').doc(_funcionarioLogado!.empresaId).get();
          if (empresaDoc.exists) {
            _empresaAtual = Empresa.fromFirestore(empresaDoc);
          }
        }
      }
    } catch (e) {
      print("❌ Erro ao carregar dados do usuário: $e");
      // Se der erro, desloga para garantir a segurança
      await signOut();
    }
  }

  /// Novo método de LOGIN.
  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // O listener _onAuthStateChanged vai cuidar do resto automaticamente.
      return true;
    } catch (e) {
      print("❌ Erro no signIn: $e");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Novo método de CADASTRO de uma nova empresa.
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User newUser = userCredential.user!;

      // 2. Prepara nossos objetos de modelo
      Empresa novaEmpresa = Empresa(
        id: newUser.uid, // O ID da empresa é o UID do dono
        nomeEmpresa: nomeEmpresa,
        proprietario: proprietario,
        email: email,
        telefone: telefone,
        cpf: cpf,
        createdAt: Timestamp.now(),
      );

      Funcionario primeiroFuncionario = Funcionario(
        uid: newUser.uid, // O UID do funcionário é o mesmo do login
        empresaId: newUser.uid, // Ele pertence à empresa que acabou de criar
        nome: proprietario, // O nome do dono é o nome do primeiro funcionário
        email: email,
        cargo: 'admin', // O dono sempre começa como admin
        ativo: true,
      );

      // 3. Usa um WriteBatch para salvar os dois documentos de uma vez
      final batch = _db.batch();
      batch.set(_db.collection('empresas').doc(novaEmpresa.id), novaEmpresa.toMap());
      batch.set(_db.collection('funcionarios').doc(primeiroFuncionario.uid), primeiroFuncionario.toMap());

      await batch.commit();

      // O listener _onAuthStateChanged vai cuidar do resto.
      return true;
    } catch (e) {
      print("❌ Erro no signUpAsOwner: $e");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Novo método de LOGOUT.
  Future<void> signOut() async {
    await _auth.signOut();
    // O listener _onAuthStateChanged cuida da limpeza do estado.
  }
}
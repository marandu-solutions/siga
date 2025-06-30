import 'package:flutter/material.dart';

import '../../Model/custos.dart';
import 'Components/add_custo.dart';
import 'Components/custo_card.dart';



class CentroDeCustosPage extends StatefulWidget {
  const CentroDeCustosPage({super.key});

  @override
  State<CentroDeCustosPage> createState() => _CentroDeCustosPageState();
}

class _CentroDeCustosPageState extends State<CentroDeCustosPage> {
  // Dados de exemplo para a UI.
  final List<Custo> _custos = [
    Custo(id: '1', empresaId: 'emp1', descricao: 'Aluguel do Espaço', valor: 2500.00, tipo: TipoCusto.fixo, criadoPor: {'nome': 'Admin'}),
    Custo(id: '2', empresaId: 'emp1', descricao: 'Salário - Funcionário A', valor: 1800.00, tipo: TipoCusto.fixo, criadoPor: {'nome': 'Admin'}),
    Custo(id: '3', empresaId: 'emp1', descricao: 'Conta de Energia Elétrica', valor: 450.50, tipo: TipoCusto.variavel, criadoPor: {'nome': 'Admin'}),
    Custo(id: '4', empresaId: 'emp1', descricao: 'Conta de Água', valor: 120.75, tipo: TipoCusto.variavel, criadoPor: {'nome': 'Admin'}),
    Custo(id: '5', empresaId: 'emp1', descricao: 'Internet', valor: 150.00, tipo: TipoCusto.fixo, criadoPor: {'nome': 'Admin'}),
  ];

  // Função para abrir o diálogo de adicionar/editar custo.
  void _showAddCustoDialog({Custo? custo}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddCustoDialog(
          custo: custo,
          onSave: (novoCusto) {
            setState(() {
              if (custo == null) {
                _custos.add(novoCusto);
              } else {
                final index = _custos.indexWhere((c) => c.id == custo.id);
                if (index != -1) {
                  _custos[index] = novoCusto;
                }
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final custosFixos = _custos.where((c) => c.tipo == TipoCusto.fixo).toList();
    final custosVariaveis = _custos.where((c) => c.tipo == TipoCusto.variavel).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Custos"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, "Custos Fixos Mensais"),
          const SizedBox(height: 8),
          if (custosFixos.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhum custo fixo cadastrado.")))
          else
            ...custosFixos.map((custo) => CustoCard(
              custo: custo,
              onTap: () => _showAddCustoDialog(custo: custo),
              onDelete: () => setState(() => _custos.removeWhere((c) => c.id == custo.id)),
            )),
          const Divider(height: 40),
          _buildSectionTitle(context, "Custos Variáveis (Último Mês)"),
          const SizedBox(height: 8),
          if (custosVariaveis.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhum custo variável cadastrado.")))
          else
            ...custosVariaveis.map((custo) => CustoCard(
              custo: custo,
              onTap: () => _showAddCustoDialog(custo: custo),
              onDelete: () => setState(() => _custos.removeWhere((c) => c.id == custo.id)),
            )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustoDialog(),
        tooltip: 'Adicionar Custo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
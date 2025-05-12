import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/pedidos.dart';
import '../../Service/pedidos_service.dart';
import 'Components/add_pedido.dart';
import 'Components/pedido_details_page.dart';
import 'Components/kanban.dart';
import 'Components/tabela.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final PedidoService _pedidoService = PedidoService();
  bool _isLoading = false;
  String _viewMode = 'tabela'; // Estado para controlar a visualização

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  Future<void> _fetchPedidos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pedidos = await _pedidoService.getPedidos();
      if (mounted) {
        final pedidoModel = context.read<PedidoModel>();
        pedidoModel.limparPedidos();
        for (var pedido in pedidos) {
          pedidoModel.adicionarPedido(pedido);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pedidos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _adicionarPedido(Pedido pedido) async {
    try {
      final pedidoCriado = await _pedidoService.adicionarPedido(pedido);
      if (mounted) {
        context.read<PedidoModel>().adicionarPedido(pedidoCriado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #${pedidoCriado.numeroPedido} adicionado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar pedido: $e')),
        );
      }
    }
  }

  Future<void> _editarPedido(Pedido pedido) async {
    try {
      await _pedidoService.editarPedido(pedido);
      if (mounted) {
        context.read<PedidoModel>().atualizarPedido(pedido.id, pedido);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #${pedido.numeroPedido} atualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar pedido: $e')),
        );
      }
    }
  }

  Future<void> _deletarPedido(Pedido pedido) async {
    try {
      await _pedidoService.deletarPedido(pedido.id);
      if (mounted) {
        context.read<PedidoModel>().removerPedido(pedido.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #${pedido.numeroPedido} excluído')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir pedido: $e')),
        );
      }
    }
  }

  Future<void> _atualizarEstadoPedido(Pedido pedido, EstadoPedido novoEstado) async {
    try {
      await _pedidoService.atualizarEstadoPedido(pedido.id, novoEstado);
      if (mounted) {
        final atualizado = pedido.copyWith(estado: novoEstado);
        context.read<PedidoModel>().atualizarPedido(pedido.id, atualizado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado do pedido #${pedido.numeroPedido} atualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar estado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = context.watch<PedidoModel>().pedidos;

    // Definindo as cores para cada estado
    final corColuna = {
      EstadoPedido.emAberto: Colors.blue[100]!,
      EstadoPedido.emAndamento: Colors.yellow[100]!,
      EstadoPedido.entregaRetirada: Colors.orange[100]!,
      EstadoPedido.finalizado: Colors.green[100]!,
      EstadoPedido.cancelado: Colors.red[100]!,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () => setState(() => _viewMode = 'tabela'),
            color: _viewMode == 'tabela' ? null : Colors.grey,
            tooltip: 'Visualização Tabela',
          ),
          IconButton(
            icon: const Icon(Icons.view_kanban),
            onPressed: () => setState(() => _viewMode = 'kanban'),
            color: _viewMode == 'kanban' ? null : Colors.grey,
            tooltip: 'Visualização Kanban',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPedidos,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? const Center(child: Text('Nenhum pedido encontrado'))
          : _viewMode == 'tabela'
          ? Tabela(
        pedidos: pedidos,
        onEstadoChanged: (pedido) async {
          await _atualizarEstadoPedido(pedido, pedido.estado);
        },
        onDelete: (pedido) async {
          await _deletarPedido(pedido);
        },
        onEdit: (pedido) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PedidoDetailsPage(pedido: pedido),
            ),
          );
        },
      )
          : Kanban(
        pedidos: pedidos,
        corColuna: corColuna,
        onPedidoEstadoChanged: (pedido) async {
          await _atualizarEstadoPedido(pedido, pedido.estado);
        },
        onDelete: (pedido) async {
          await _deletarPedido(pedido);
        },
        onTapDetails: (pedido) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PedidoDetailsPage(pedido: pedido),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddPedidoDialog(
              onAdd: (pedido) async {
                await _adicionarPedido(pedido);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Pedido',
      ),
    );
  }
}
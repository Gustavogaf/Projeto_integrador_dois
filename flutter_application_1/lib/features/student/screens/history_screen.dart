import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/historico_model.dart';
import '../../../viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _accentBlue = const Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().carregarHistorico();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryBlue),
        title: Text(
          'Meu Histórico',
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumoDesempenho(viewModel),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Atividades Recentes', style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500)),
                      Text('Ver todos', style: TextStyle(color: _accentBlue, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (viewModel.historico.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Nenhum módulo concluído ainda.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...viewModel.historico.map((hist) => _buildAtividadeCard(hist)),
                  
                  const SizedBox(height: 24),
                  _buildSecurityTipBox(),
                ],
              ),
            ),
    );
  }

  Widget _buildResumoDesempenho(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo de Desempenho', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('${viewModel.totalQuizzes}', style: TextStyle(color: _primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Quizzes Concluídos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(viewModel.mediaAcertos, style: TextStyle(color: _primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Média de Acertos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtividadeCard(HistoricoModel historico) {
    final totalPerguntas = historico.acertos + historico.erros;
    final proporcaoAcertos = totalPerguntas > 0 ? historico.acertos / totalPerguntas : 0.0;
    
    final dataFormatada = DateFormat("dd MMM, yyyy", "pt_BR").format(historico.dataConclusao);

    IconData iconData = Icons.security;
    String titulo = historico.tema?.titulo ?? 'Tema Removido';
    
    if (titulo.toLowerCase().contains('phishing')) iconData = Icons.phishing;
    if (titulo.toLowerCase().contains('senha')) iconData = Icons.password;
    if (titulo.toLowerCase().contains('wi-fi') || titulo.toLowerCase().contains('rede')) iconData = Icons.wifi_lock;
    if (titulo.toLowerCase().contains('mfa') || titulo.toLowerCase().contains('2fa')) iconData = Icons.shield_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: _primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(dataFormatada, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${historico.acertos}/$totalPerguntas acertos', style: TextStyle(color: _primaryBlue, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Stack(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    FractionallySizedBox(
                      widthFactor: proporcaoAcertos,
                      child: Container(height: 4, decoration: BoxDecoration(color: _accentBlue, borderRadius: BorderRadius.circular(2))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTipBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFDBEAFE), const Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dica de Segurança', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'Mude suas senhas a cada 90 dias para manter suas contas blindadas.',
                  style: TextStyle(color: const Color(0xFF374151), height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _primaryBlue.withOpacity(0.2),
            ),
            child: Icon(Icons.memory, color: _primaryBlue, size: 36), // Ícone representando um chip/segurança
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/alternativa_model.dart';
import '../../../viewmodels/quiz_viewmodel.dart';
import '../../../viewmodels/student_home_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  final int temaId;
  final String temaTitulo;

  const QuizScreen({
    super.key,
    required this.temaId,
    required this.temaTitulo,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _successGreen = const Color(0xFF10B981);
  final Color _errorRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().iniciarQuiz(widget.temaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuizViewModel>();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryBlue),
        title: Text(
          widget.temaTitulo,
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryBlue))
          : viewModel.perguntas.isEmpty
              ? const Center(child: Text('Nenhuma pergunta cadastrada neste tema.'))
              : _buildQuizBody(viewModel),
    );
  }

  Widget _buildQuizBody(QuizViewModel viewModel) {
    final perguntaAtual = viewModel.perguntas[viewModel.currentIndex];
    final total = viewModel.perguntas.length;
    final double progresso = (viewModel.currentIndex + 1) / total;
    
    final letras = ['A', 'B', 'C', 'D', 'E', 'F']; 

    return SafeArea(
      child: Column(
        children: [
          // Header de Progresso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pergunta ${viewModel.currentIndex + 1} de $total',
                      style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(progresso * 100).toInt()}% concluído',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                    FractionallySizedBox(
                      widthFactor: progresso,
                      child: Container(height: 6, decoration: BoxDecoration(color: _primaryBlue, borderRadius: BorderRadius.circular(3))),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card da Pergunta
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.alternate_email, color: _primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)),
                              child: Text(widget.temaTitulo, style: TextStyle(color: _primaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          perguntaAtual.enunciado,
                          style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista de Alternativas
                  ...List.generate(perguntaAtual.alternativas.length, (index) {
                    final alt = perguntaAtual.alternativas[index];
                    return _buildAlternativaCard(viewModel, alt, letras[index]);
                  }),


                  if (viewModel.respondido) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: _primaryBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Color(0xFF374151), height: 1.4, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Dica de Segurança: ', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold)),
                                  const TextSpan(text: 'Desconfie de mensagens urgentes. Canais oficiais nunca pedem envio de senhas ou dados sensíveis através de links em e-mails.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bgLight,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.alternativaSelecionada == null
                    ? null
                    : () async {
                        if (!viewModel.respondido) {
                          viewModel.confirmarResposta();
                        } else {
                          final finalizou = await viewModel.proximaPergunta(widget.temaId);
                          if (finalizou && mounted) {
                            context.read<StudentHomeViewModel>().carregarDadosHome();
                            Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      !viewModel.respondido ? 'Confirmar' : (viewModel.currentIndex < total - 1 ? 'Próxima' : 'Finalizar Módulo'),
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativaCard(QuizViewModel viewModel, AlternativaModel alt, String letra) {
    final isSelected = viewModel.alternativaSelecionada?.id == alt.id;
    
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    Widget leadingIcon = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[400]!)),
      child: Center(child: Text(letra, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold))),
    );

    if (viewModel.respondido) {
      if (alt.isCorreta) {
        borderColor = _successGreen;
        bgColor = const Color(0xFFF0FDF4); // Verde super claro
        textColor = const Color(0xFF065F46); // Texto verde escuro
        leadingIcon = Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _successGreen)),
          child: Icon(Icons.check, size: 16, color: _successGreen),
        );
      } else if (isSelected && !alt.isCorreta) {
        borderColor = _errorRed;
        bgColor = const Color(0xFFFEF2F2); 
        textColor = const Color(0xFF991B1B); 
        leadingIcon = Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _errorRed)),
          child: Icon(Icons.close, size: 16, color: _errorRed),
        );
      }
    } else if (isSelected) {
      borderColor = _primaryBlue;
      bgColor = const Color(0xFFEFF6FF);
    }

    return GestureDetector(
      onTap: () => viewModel.selecionarAlternativa(alt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected || (viewModel.respondido && alt.isCorreta) ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            leadingIcon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                alt.enunciado,
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
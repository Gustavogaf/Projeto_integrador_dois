import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/tema_model.dart';
import '../../../viewmodels/student_home_viewmodel.dart';
import 'quiz_screen.dart'; 
import 'history_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final Color _primaryBlue = const Color(0xFF1E3A8A); 
  final Color _accentBlue = const Color(0xFF2563EB); 
  final Color _bgLight = const Color(0xFFF8FAFC); 
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentHomeViewModel>().carregarDadosHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentHomeViewModel>();

    return Scaffold(
      backgroundColor: _bgLight,
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryBlue))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(viewModel.nomeAluno),
                    const SizedBox(height: 24),
                    _buildLevelCard(viewModel),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Temas de Estudo', style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500)),
                        Text('Ver todos', style: TextStyle(color: _accentBlue, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ...viewModel.temas.map((tema) => _buildThemeCard(tema, viewModel.getStatusTema(tema.id))),
                    
                    const SizedBox(height: 24),
                    _buildSecurityTip(),
                  ],
                ),
              ),
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ).then((_) {
              context.read<StudentHomeViewModel>().carregarDadosHome();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildHeader(String nome) {
    String primeiroNome = nome.split(' ').first;
    if (primeiroNome.isEmpty) primeiroNome = 'Aluno';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), 
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bem-vindo,', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text('Olá, $primeiroNome', style: TextStyle(color: _primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            const Icon(Icons.notifications_none, size: 28, color: Colors.grey),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelCard(StudentHomeViewModel viewModel) {
    double progresso = 0.0;
    if (viewModel.totalPerguntasAtual > 0) {
      progresso = viewModel.perguntasRespondidasAtual / viewModel.totalPerguntasAtual;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), 
          opacity: 0.05,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nível ${viewModel.nivel}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text(
            'Você está no caminho certo para se tornar um Especialista Digital!',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: progresso,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: const Color(0xFF60A5FA), borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${viewModel.perguntasRespondidasAtual} / ${viewModel.totalPerguntasAtual} Perguntas respondidas',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(TemaModel tema, String status) {
    Color borderColor;
    Widget badge;
    Widget bottomContent;
    IconData iconData = Icons.security; 
    
    if (tema.titulo.toLowerCase().contains('phishing')) iconData = Icons.phishing;
    if (tema.titulo.toLowerCase().contains('senha')) iconData = Icons.lock_outline;
    if (tema.titulo.toLowerCase().contains('redes')) iconData = Icons.shield_outlined;

    switch (status) {
      case 'Concluído':
        borderColor = const Color(0xFF1E3A8A); 
        badge = _buildBadge('Concluído', const Color(0xFFE0E7FF), const Color(0xFF3730A3));
        bottomContent = Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(width: 12),
            Text('100%', style: TextStyle(color: borderColor, fontWeight: FontWeight.bold)),
          ],
        );
        break;
      case 'Próximo':
        borderColor = const Color(0xFF10B981);
        badge = _buildBadge('Próximo', const Color(0xFFD1FAE5), const Color(0xFF065F46));
        bottomContent = SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(temaId: tema.id, temaTitulo: tema.titulo)));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Text('Começar Agora', style: TextStyle(color: borderColor, fontSize: 16)),
            label: Icon(Icons.play_arrow, color: borderColor, size: 20),
          ),
        );
        break;
      default: 
        borderColor = const Color(0xFF8B5CF6); 
        badge = _buildBadge('Bloqueado', const Color(0xFFEDE9FE), const Color(0xFF5B21B6));
        bottomContent = Row(
          children: [
            const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Disponível após concluir os anteriores', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                              child: Icon(iconData, color: borderColor),
                            ),
                            const SizedBox(width: 12),
                            Text(tema.titulo, style: const TextStyle(fontSize: 16, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500)),
                          ],
                        ),
                        badge,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(tema.descricao, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    bottomContent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSecurityTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF), // Azul bem claro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF1E3A8A), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Dica de Segurança', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('Nunca compartilhe seus códigos de autenticação em duas etapas por telefone.', style: TextStyle(color: Color(0xFF374151), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
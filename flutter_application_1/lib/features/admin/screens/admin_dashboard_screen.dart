import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/tema_model.dart';
import '../../../viewmodels/admin_dashboard_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'create_question_screen.dart';
import 'create_theme_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessAndLoadData();
    });
  }

  void _checkAccessAndLoadData() {
    final authViewModel = context.read<AuthViewModel>();

    if (!authViewModel.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesso Negado: Privilégios insuficientes.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    context.read<AdminDashboardViewModel>().loadTemas();
  }

  Future<void> _deleteTema(int idTema) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tema?'),
        content: const Text(
          'Tem certeza que deseja excluir este tema? Todas as perguntas associadas serão apagadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    final success = await context.read<AdminDashboardViewModel>().deleteTema(
      idTema,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tema excluído com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir o tema.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.watch<AdminDashboardViewModel>();
    final authState = context.watch<AuthViewModel>();

    if (!authState.isAdmin)
      return const Scaffold(backgroundColor: Color(0xFFF8FAFC));

    if (dashboardState.isLoading && dashboardState.temas.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E3A8A)),
          onPressed: () {},
        ),
        title: const Text(
          'Security Quizz',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Text(
                'AU',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temas de Segurança',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerencie e organize os módulos de treinamento de segurança da sua organização.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: dashboardState.temas.isEmpty
                  ? const Center(child: Text('Nenhum tema cadastrado.'))
                  : ListView.builder(
                      itemCount: dashboardState.temas.length,
                      itemBuilder: (context, index) {
                        final tema = dashboardState.temas[index];

                        Color accentColor = Colors.blue;
                        if (tema.corHexadecimal.isNotEmpty) {
                          try {
                            accentColor = Color(
                              int.parse(
                                tema.corHexadecimal.replaceAll('#', '0xFF'),
                              ),
                            );
                          } catch (e) {
                            accentColor = Colors.blue;
                          }
                        }

                        return _buildThemeCard(tema, accentColor);
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(
          0xFF0F172A,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThemeScreen()),
          );
          if (result == true && mounted) {
            context.read<AdminDashboardViewModel>().loadTemas();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.dashboard_outlined, 'Painel'),
            _buildNavIcon(1, Icons.security_outlined, 'Temas'),
            _buildNavIcon(2, Icons.quiz_outlined, 'Perguntas'),
            _buildNavIcon(3, Icons.history_outlined, 'Registros'),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(TemaModel tema, Color accentColor) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield_outlined, color: accentColor),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.indigo,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateThemeScreen(temaParaEdicao: tema),
                          ),
                        );
                        if (result == true && mounted) {
                          context.read<AdminDashboardViewModel>().loadTemas();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteTema(tema.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tema.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tema.descricao,
              style: const TextStyle(color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ativo',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                Text(
                  '${tema.qtdPerguntas} Perguntas',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, String label) {
    final isActive = _selectedIndex == index;
    final color = isActive ? const Color(0xFF1E3A8A) : Colors.grey;
    return InkWell(
      onTap: () async {
        if (index == 2) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateQuestionScreen(),
            ),
          );
          if (result == true && mounted) {
            context.read<AdminDashboardViewModel>().loadTemas();
          }
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

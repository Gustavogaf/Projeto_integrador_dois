import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart';
import 'create_question_screen.dart';
import 'create_theme_screen.dart'; // A tela de "Configurar Tema" que vamos criar em seguida

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 1; // 1 = Tab 'Temas' ativa (conforme o design)
  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _temas = [];

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadData();
  }

  // RF03: Controle de Acesso
  Future<void> _checkAdminAndLoadData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        // Redirecionar para login se não houver usuário logado (precaução extra)
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Consulta a tabela 'perfil' para verificar o privilégio
      final response = await supabase
          .from('perfil')
          .select('is_admin, nome')
          .eq('id_user', user.id)
          .single();

      if (response['is_admin'] == true) {
        setState(() {
          _isAdmin = true;
        });
        _loadTemas(); // Carrega os temas apenas se for administrador
      } else {
        // Fluxo Alternativo UC05: Tentativa de acesso indevido
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acesso Negado: Privilégios insuficientes.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home'); // Redireciona para área do aluno
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao verificar permissões.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // UC02 / UC06: Consultar Temas
  Future<void> _loadTemas() async {
    try {
      // Usando uma query para buscar os temas e a contagem de perguntas (Aulas/Perguntas)
      // A query abaixo faz um count na tabela perguntas vinculado ao id do tema.
      final response = await supabase.from('temas').select('''
        id_temas,
        titulo,
        descricao,
        cor_hexadecimal,
        perguntas(count)
      ''').order('data_criacao', ascending: false);
      
      if (mounted) {
        setState(() {
          _temas = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar os temas.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // RF07: Regra de Exclusão e Confirmação (RF15)
  Future<void> _deleteTema(int idTema) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tema?'),
        content: const Text('Tem certeza que deseja excluir este tema? Todas as perguntas associadas serão apagadas.'),
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

    try {
      await supabase.from('temas').delete().eq('id_temas', idTema);
      _loadTemas(); // Recarrega a lista após a exclusão
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tema excluído com sucesso.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir o tema.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não terminou de carregar a verificação de admin, mostra a tela de carregamento.
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Proteção extra de renderização: se chegou aqui e não for admin, exibe tela em branco.
    if (!_isAdmin) return const Scaffold();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E3A8A)),
          onPressed: () {}, // TODO: Abrir Drawer se necessário
        ),
        title: const Text(
          'Security Quizz', // Nome oficial definido
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Text('AU', style: TextStyle(color: Color(0xFF1E3A8A))), // Placeholder avatar do admin
            ),
          )
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
            
            // RNF09: Renderização Eficiente de Listas
            Expanded(
              child: _temas.isEmpty
                  ? const Center(child: Text('Nenhum tema cadastrado.'))
                  : ListView.builder(
                      itemCount: _temas.length,
                      itemBuilder: (context, index) {
                        final tema = _temas[index];
                        // Processa a contagem de perguntas da subquery
                        int qtdPerguntas = 0;
                        if(tema['perguntas'] != null && (tema['perguntas'] as List).isNotEmpty) {
                           qtdPerguntas = tema['perguntas'][0]['count'] ?? 0;
                        }
                        
                        // Processa a cor_hexadecimal
                        Color accentColor = Colors.blue;
                        if(tema['cor_hexadecimal'] != null && tema['cor_hexadecimal'].toString().isNotEmpty) {
                           try {
                             accentColor = Color(int.parse(tema['cor_hexadecimal'].replaceAll('#', '0xFF')));
                           } catch (e) {
                             accentColor = Colors.blue; // Fallback
                           }
                        }

                        return _buildThemeCard(tema, qtdPerguntas, accentColor);
                      },
                    ),
            ),
          ],
        ),
      ),
      
      // Botão Flutuante de Criação (+) - Conforme o design (sobrepondo a bottom bar visualmente)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A), // Azul bem escuro/preto do design
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          // Navega para a tela de Configurar Tema e aguarda o retorno
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThemeScreen()),
          );
          // Se um tema foi salvo, recarrega a lista
          if(result == true) {
            _loadTemas();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      
      // Bottom Navigation Bar baseada no design
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.dashboard_outlined, 'Painel'),
            _buildNavIcon(1, Icons.security_outlined, 'Temas'), // Aba ativa
            _buildNavIcon(2, Icons.quiz_outlined, 'Perguntas'),
            _buildNavIcon(3, Icons.history_outlined, 'Registros'),
            const SizedBox(width: 48), // Espaço para o FloatingActionButton
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> tema, int qtdPerguntas, Color accentColor) {
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
                // Ícone com a cor de acento do tema
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield_outlined, color: accentColor), // Ícone genérico, pode evoluir depois
                ),
                // Ações de Edição e Exclusão (UC06)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                      onPressed: () async {
                        // RF16: Edição com Preenchimento Prévio trafegando o estado
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateThemeScreen(temaParaEdicao: tema),
                          ),
                        );
                        if(result == true) _loadTemas();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteTema(tema['id_temas']),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tema['titulo'] ?? 'Sem Título',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tema['descricao'] ?? 'Sem descrição',
              style: const TextStyle(color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag de Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ativo', // Static por enquanto
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                // Contagem de Perguntas (solicitada)
                Text(
                  '$qtdPerguntas Perguntas',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            )
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
          // Se clicar na aba "Perguntas", abre a tela de criação
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuestionScreen()),
          );
          // Atualiza o painel caso uma nova pergunta tenha sido salva
          if (result == true) _loadTemas();
        } else {
          // Para as outras abas, apenas muda a seleção visual por enquanto
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
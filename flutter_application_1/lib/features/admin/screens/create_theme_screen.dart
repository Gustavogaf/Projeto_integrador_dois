import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart'; // Importa a variável global supabase

class CreateThemeScreen extends StatefulWidget {
  // Parâmetro opcional. Se for passado, a tela se comporta como "Edição" (RF16)
  final Map<String, dynamic>? temaParaEdicao;

  const CreateThemeScreen({super.key, this.temaParaEdicao});

  @override
  State<CreateThemeScreen> createState() => _CreateThemeScreenState();
}

class _CreateThemeScreenState extends State<CreateThemeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  bool _isLoading = false;
  
  // Paleta de cores baseada no seu design
  final List<Color> _opcoesCores = [
    const Color(0xFF1E3A8A), // Azul Escuro (Padrão)
    const Color(0xFF4F46E5), // Indigo
    const Color(0xFF0F766E), // Teal Escuro
    const Color(0xFF0369A1), // Light Blue
    const Color(0xFF334155), // Slate/Cinza Escuro
  ];
  
  late Color _corSelecionada;

  @override
  void initState() {
    super.initState();
    _corSelecionada = _opcoesCores[0]; // Cor inicial padrão
    
    // Se recebemos um tema para edição (RF16), preenchemos os campos
    if (widget.temaParaEdicao != null) {
      _tituloController.text = widget.temaParaEdicao!['titulo'] ?? '';
      _descricaoController.text = widget.temaParaEdicao!['descricao'] ?? '';
      
      // Tenta recuperar a cor hexadecimal do banco e aplicar no visual
      if (widget.temaParaEdicao!['cor_hexadecimal'] != null) {
        try {
          String hexString = widget.temaParaEdicao!['cor_hexadecimal'];
          hexString = hexString.replaceAll('#', '0xFF');
          _corSelecionada = Color(int.parse(hexString));
        } catch (e) {
          // Se falhar o parse, mantém a cor padrão
        }
      }
    }
  }

  // Função que converte a cor do Flutter (Color) para String '#RRGGBB' pro Banco de Dados
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  Future<void> _salvarTema() async {
    // RF14: Validação Client-side
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final temaData = {
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'cor_hexadecimal': _colorToHex(_corSelecionada),
        // O campo data_criacao é gerado automaticamente pelo banco, ou podemos enviar:
        // 'data_criacao': DateTime.now().toIso8601String(), se não houver valor default no Postgres.
      };

      if (widget.temaParaEdicao == null) {
        // Fluxo de Criação (Novo Tema)
        await supabase.from('temas').insert(temaData);
      } else {
        // Fluxo de Atualização (Edição)
        await supabase
            .from('temas')
            .update(temaData)
            .eq('id_temas', widget.temaParaEdicao!['id_temas']);
      }

      // RNF10: Retorna "true" para a tela anterior saber que deve recarregar a lista
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tema salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar o tema. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.temaParaEdicao != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        title: const Text(
          'Security Quizz',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Text('AU', style: TextStyle(color: Color(0xFF1E3A8A))),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb de navegação
            Row(
              children: [
                const Text('Temas de Segurança', style: TextStyle(color: Colors.grey)),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                Text(
                  isEditing ? 'Editar Tema' : 'Novo Tema',
                  style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configurar Tema',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 24),

            // Card Principal do Formulário
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Título do Tema'),
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'ex: Integridade Financeira Global',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) => value!.isEmpty ? 'Forneça um nome claro para o tema' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Forneça um nome claro e oficial para o tema de segurança.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Descrição'),
                    TextFormField(
                      controller: _descricaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Descreva o escopo e o rigor deste tema...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) => value!.isEmpty ? 'A descrição é obrigatória' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Assinatura de Cor do Tema'),
                    Wrap(
                      spacing: 12,
                      children: _opcoesCores.map((cor) {
                        final isSelected = _corSelecionada.value == cor.value;
                        return GestureDetector(
                          onTap: () => setState(() => _corSelecionada = cor),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: cor,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: const Color(0xFF0F172A), width: 3) : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('PRÉ-VISUALIZAÇÃO EM TEMPO REAL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    
                    // Container de Pré-visualização com atualização via setState
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _corSelecionada.withOpacity(0.1),
                            _corSelecionada.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _corSelecionada,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Acento do Tema',
                            style: TextStyle(
                              color: _corSelecionada,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botões de Ação
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _salvarTema,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A), // Cor escura do botão de salvar
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save_outlined, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Salvando...' : 'Salvar Tema',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.black87, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15),
      ),
    );
  }
}
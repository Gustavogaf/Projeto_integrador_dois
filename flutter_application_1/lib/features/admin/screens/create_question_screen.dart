import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/alternativa_item.dart';
import '../../../viewmodels/create_question_viewmodel.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enunciadoController = TextEditingController();
  final List<TextEditingController> _altControllers = [];
  
  int _selectedIndex = -1;
  int? _selectedTemaId;

  final Color _primaryBlue = const Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateQuestionViewModel>().carregarTemas();
    });
    
    _addAlternativa();
    _addAlternativa();
    _addAlternativa();
  }

  void _addAlternativa() {
    setState(() => _altControllers.add(TextEditingController()));
  }

  void _removeAlternativa(int index) {
    setState(() {
      _altControllers[index].dispose();
      _altControllers.removeAt(index);
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else if (_selectedIndex > index) {
        _selectedIndex--;
      }
    });
  }

  Future<void> _salvarPergunta() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_altControllers.length < 2) {
      _showSnackBar('Adicione pelo menos duas alternativas.', isError: true);
      return;
    }
    
    if (_selectedIndex == -1) {
      _showSnackBar('Selecione qual é a alternativa correta.', isError: true);
      return;
    }

    List<String> textosAlternativas = [];
    for (var controller in _altControllers) {
      if (controller.text.trim().isEmpty) {
        _showSnackBar('Preencha o texto de todas as alternativas.', isError: true);
        return;
      }
      textosAlternativas.add(controller.text.trim());
    }

    final viewModel = context.read<CreateQuestionViewModel>();

    final success = await viewModel.salvarPergunta(
      temaId: _selectedTemaId!,
      enunciado: _enunciadoController.text.trim(),
      alternativas: textosAlternativas,
      corretaIndex: _selectedIndex,
    );

    if (mounted) {
      if (success) {
        _showSnackBar('Pergunta salva com sucesso!');
        Navigator.pop(context, true);
      } else if (viewModel.errorMessage != null) {
        _showSnackBar(viewModel.errorMessage!, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    for (var controller in _altControllers) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = context.watch<CreateQuestionViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryBlue),
        title: Text('Security Quizz', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: _primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text('BANCO DE QUESTÕES', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Novo Item de Avaliação', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),

              const Text('Tema Vinculado', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              
              DropdownButtonFormField<int>(
                value: _selectedTemaId,
                hint: const Text('Selecione o tema da pergunta'),
                icon: const Icon(Icons.arrow_drop_down),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: viewModelState.temas.map((tema) {
                  return DropdownMenuItem<int>(
                    value: tema.id,
                    child: Text(tema.titulo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTemaId = value;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecione um tema' : null,
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enunciado da Pergunta', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Rich Text Ativado', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _enunciadoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Descreva o contexto e a questão central de forma clara...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value!.isEmpty ? 'O enunciado é obrigatório' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alternativas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
                    child: Text('Selecione uma', style: TextStyle(color: _primaryBlue, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _altControllers.length,
                itemBuilder: (context, index) {
                  return AlternativaItem(
                    index: index,
                    isSelected: _selectedIndex == index,
                    controller: _altControllers[index],
                    onTapRadio: () => setState(() => _selectedIndex = index),
                    onRemove: _altControllers.length > 2 
                        ? () => _removeAlternativa(index) 
                        : null,
                  );
                },
              ),

              InkWell(
                onTap: _addAlternativa,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.4)), 
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: _primaryBlue),
                      const SizedBox(width: 8),
                      Text('Adicionar Alternativa', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: viewModelState.isLoading ? null : _salvarPergunta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: viewModelState.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    viewModelState.isLoading ? 'Salvando...' : 'Salvar Pergunta',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
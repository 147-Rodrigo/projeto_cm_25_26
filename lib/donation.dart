import 'package:flutter/material.dart';
import 'Style/custom_appbar.dart';
import 'Style/text_styles.dart';
import 'home.dart';
import 'eventos.dart';
import 'forum.dart';
import 'info.dart';
import 'perfil.dart';
import 'notificacoes.dart';
import 'noticias.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Doações",
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticiasPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificacoesPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Escolha uma ONG para doar",
                    style: AppTextStyles.welcomeTitle,
                  ),

                  const SizedBox(height: 20),

                  _DonationCard(
                    title: "Cáritas Portuguesa",
                    imagePath: "assets/doações/caritas.png",
                  ),
                  const SizedBox(height: 15),

                  _DonationCard(
                    title: "Banco Alimentar Contra a Fome",
                    imagePath: "assets/doações/banco_alimentar.png",
                  ),
                  const SizedBox(height: 15),

                  _DonationCard(
                    title: "Comunidade Vida e Paz",
                    imagePath: "assets/doações/comunidade_vida.png",
                  ),
                  const SizedBox(height: 15),

                  _DonationCard(
                    title: "Santa Casa da Misericórdia",
                    imagePath: "assets/doações/santa_casa.png",
                  ),
                  const SizedBox(height: 15),

                  _DonationCard(
                    title: "Cruz Vermelha Portuguesa",
                    imagePath: "assets/doações/cruz.png",
                  ),
                  const SizedBox(height: 15),

                  _DonationCard(
                    title: "Liga dos Bombeiros Portugueses",
                    imagePath: "assets/doações/bombeiros.png",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Barra de navegação
          Container(
            width: double.infinity,
            color: Colors.green,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildNavButton(Icons.map, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const HomePage()));
                  }),
                  _divider(),
                  _buildNavButton(Icons.calendar_month, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const EventosPage()));
                  }),
                  _divider(),
                  _buildNavButton(Icons.volunteer_activism, () {}),
                  _divider(),
                  _buildNavButton(Icons.message, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ForumPage()));
                  }),
                  _divider(),
                  _buildNavButton(Icons.info, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const InfoPage()));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 30, color: Colors.white30);
  }
}

// ─── DONATION CARD ────────────────────────────────────────────────────────────

class _DonationCard extends StatefulWidget {
  final String title;
  final String imagePath;

  const _DonationCard({required this.title, required this.imagePath});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  bool _expanded = false;
  int? _selectedAmount;

  static const List<int> _amounts = [10, 20, 40, 60, 80, 100];

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 255, 156, 1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Doação Realizada!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "A sua doação de ${_selectedAmount}€ para\n${widget.title}\nfoi realizada com sucesso.",
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Obrigado pela sua generosidade e por fazer a diferença! 💚",
                style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _expanded = false;
                      _selectedAmount = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Fechar",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 255, 156, 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Cabeçalho clicável ──
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
                if (!_expanded) _selectedAmount = null;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(widget.imagePath),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(widget.title, style: AppTextStyles.cardTitle),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.green.shade700,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          // ── Painel de doação expansível ──
          if (_expanded) ...[
            const Divider(height: 1, color: Colors.green, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Escolha o valor a doar:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grade de valores 3x2
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _amounts.length,
                    itemBuilder: (context, index) {
                      final amount = _amounts[index];
                      final isSelected = _selectedAmount == amount;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAmount = amount),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.green.shade700 : Colors.green.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$amount€",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Botão Doar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAmount == null
                          ? null
                          : () => _showSuccessDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.green.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 2,
                      ),
                      child: Text(
                        _selectedAmount == null
                            ? "Selecione um valor"
                            : "Doar ${_selectedAmount}€",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
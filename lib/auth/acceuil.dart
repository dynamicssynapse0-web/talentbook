import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Étape de l'animation :
  // 0 = Attente initiale, 1 = "Bonjour", 2 = "Nouveau sur SynapseMarket", 3 = Boutons
  int _animationStep = 0;

  // Variables pour gérer la position verticale et l'opacité
  double _textYOffset = 0.0; // 0.0 = centré au milieu
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState() ;
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Attendre 2 secondes avant de faire apparaître "Bonjour"
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _animationStep = 1;
      _textOpacity = 1.0;
    });

    // Laisser le texte visible 1.5 seconde
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    // Déplacer vers le haut et faire disparaître "Bonjour"
    setState(() {
      _textYOffset = -100.0;
      _textOpacity = 0.0;
    });

    // Attendre la fin de la transition (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    // Réinitialiser la position pour le texte suivant sans qu'on le voie
    setState(() {
      _textYOffset = 0.0;
      _animationStep = 2;
    });

    // Petite pause et faire apparaître "Nouveau sur SynapseMarket"
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _textOpacity = 1.0;
    });

    // Laisser visible 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Déplacer vers le haut et faire disparaître
    setState(() {
      _textYOffset = -100.0;
      _textOpacity = 0.0;
    });

    // Attendre la fin de la transition (500ms) puis afficher les boutons
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _animationStep = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calcul des tailles responsives
          double dynamicFontSize = constraints.maxWidth * 0.07;
          if (dynamicFontSize < 22) dynamicFontSize = 22;
          if (dynamicFontSize > 40) dynamicFontSize = 40;

          return Stack(
            children: [
              // --- SECTION DES TEXTES ANIMÉS (Étapes 1 et 2) ---
              if (_animationStep == 1 || _animationStep == 2)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  top: (constraints.maxHeight / 2) - (dynamicFontSize / 2) + _textYOffset,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _textOpacity,
                    child: Text(
                      _animationStep == 1 ? 'Bonjour' : 'Nouveau sur SynapseMarket',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: dynamicFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

              // --- SECTION DES BOUTONS FINAUX (Étape 3) ---
              if (_animationStep == 3)
              // --- SECTION DES BOUTONS FINAUX (Étape 3) ---
                if (_animationStep == 3)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🔗 Lien "Mot de passe oublié ?" cliquable et aligné à droite
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Action pour mot de passe oublié
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Réduit la zone invisible cliquable inutile
                              ),
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4), // Petit espace entre le lien et le bouton de connexion

                          // 🟦 Bouton Connectez-vous
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Action de connexion
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Connectez-vous',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ⬜ Bouton Créer un compte
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                // Action d'inscription
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.deepPurple, width: 2),
                                foregroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Créer un compte',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
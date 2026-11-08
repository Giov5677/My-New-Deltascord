import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const DeltascordApp());
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Configuração do Supabase ausente. Configure SUPABASE_URL e SUPABASE_ANON_KEY nas variáveis do GitHub Actions.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}

class DeltascordApp extends StatelessWidget {
  const DeltascordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deltascord',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7954D6),
          brightness: Brightness.dark,
          surface: const Color(0xFF171323),
        ),
        scaffoldBackgroundColor: const Color(0xFF100D18),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF211B30),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final nickname = TextEditingController();
  final password = TextEditingController();
  bool isSignup = true;
  bool busy = false;
  String? error;

  SupabaseClient get supabase => Supabase.instance.client;

  @override
  void dispose() {
    nickname.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final nick = nickname.text.trim();
    final pass = password.text;

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(nick)) {
      setState(() => error = 'O nick precisa ter 3 a 20 caracteres: letras, números ou _.');
      return;
    }
    if (pass.length < 8) {
      setState(() => error = 'A senha precisa ter pelo menos 8 caracteres.');
      return;
    }

    setState(() { busy = true; error = null; });
    try {
      final syntheticEmail = '${nick.toLowerCase()}@deltascord.invalid';
      if (isSignup) {
        await supabase.auth.signUp(email: syntheticEmail, password: pass);
      } else {
        await supabase.auth.signInWithPassword(email: syntheticEmail, password: pass);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Não foi possível concluir. Confira a conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.forum_rounded, size: 64, color: Color(0xFFB99AFF)),
                  const SizedBox(height: 12),
                  const Text('Deltascord', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(isSignup ? 'Crie sua conta' : 'Entre na sua conta',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 28),
                  TextField(controller: nickname, textInputAction: TextInputAction.next,
                      autocorrect: false, decoration: const InputDecoration(labelText: 'Nickname')),
                  const SizedBox(height: 14),
                  TextField(controller: password, obscureText: true,
                      onSubmitted: (_) => busy ? null : submit(),
                      decoration: const InputDecoration(labelText: 'Senha')),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Text(busy ? 'Aguarde...' : isSignup ? 'Criar conta' : 'Entrar'),
                    ),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => setState(() {
                      isSignup = !isSignup;
                      error = null;
                    }),
                    child: Text(isSignup ? 'Já tenho uma conta' : 'Quero criar uma conta'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Protótipo inicial. Cadastro e login precisam ser testados antes de uso real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <(IconData, String, String)>[
      (Icons.groups_rounded, 'Amigos', 'Sistema de amigos em desenvolvimento'),
      (Icons.chat_bubble_rounded, 'Mensagens', 'Conversas privadas em desenvolvimento'),
      (Icons.headphones_rounded, 'Salas de voz', 'Salas para até 5 participantes, planejadas'),
      (Icons.screen_share_rounded, 'Compartilhar tela', 'Recurso ainda não implementado'),
      (Icons.graphic_eq_rounded, 'Soundboard', 'Envio e reprodução de MP3 ainda não implementados'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deltascord'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Bem-vindo(a)!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Esta é a primeira estrutura visual do aplicativo.'),
          const SizedBox(height: 18),
          for (final item in sections)
            Card(
              color: const Color(0xFF211B30),
              child: ListTile(
                leading: Icon(item.$1, color: const Color(0xFFB99AFF), size: 30),
                title: Text(item.$2),
                subtitle: Text(item.$3),
              ),
            ),
        ],
      ),
    );
  }
}

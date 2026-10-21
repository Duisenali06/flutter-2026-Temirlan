import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2004),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  void _startOver() => setState(() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.clear();
    }
    _group = null;
    _birth = null;
    _agreed = false;
    _done = false;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _summary() : _form(),
  );

  Widget _summary() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SummaryCard(
          name: _name.text.trim(),
          email: _email.text.trim(),
          group: _group ?? '',
          birthDate: _birthText.text,
        ),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _form() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: _unfocus,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'At least 2 characters' : null,
          ),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: _unfocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            validator: (v) {
              final value = (v ?? '').trim();
              final at = value.indexOf('@');
              if (at < 1 || !value.substring(at).contains('.')) {
                return 'Email looks wrong';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _password,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onTapOutside: _unfocus,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            validator: (v) =>
                (v ?? '').length < 8 ? 'At least 8 characters' : null,
          ),
          Text(
            '${_password.text.length} of 8',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _agreed ? _signUp() : null,
            onTapOutside: _unfocus,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            validator: (v) =>
                v != _password.text ? 'Passwords do not match' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (g) => setState(() => _group = g),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          TextFormField(
            controller: _birthText,
            readOnly: true,
            onTap: _pickBirth,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (_) => _birth == null ? 'Pick a date' : null,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _signUp : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}

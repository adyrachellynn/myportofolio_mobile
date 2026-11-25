import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  String? _required(String? value, String label, {int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && value.trim().runes.length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  String? _url(String? value, int maxLength) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (url.length > maxLength ||
        uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.port > 65535 ||
        RegExp(r'\s').hasMatch(url) ||
        (!uri.host.contains(':') &&
            !uri.host
                .split('.')
                .every(
                  (label) =>
                      RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$')
                          .hasMatch(label),
                ))) {
      return 'Masukkan URL http atau https yang valid (maksimal $maxLength karakter)!';
    }
    return null;
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final auth = context.read<AuthState>();
      final project = Project(
        title: _title.trim(),
        description: _description.trim(),
        techStack: _techStack.trim(),
        projectUrl: _projectUrl.trim(),
        projectImageUrl: _projectImageUrl.trim(),
      );
      final saved = await context.read<ApiClient>().createProject(
        project,
        token: auth.token!,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: ${saved.title}'),
                Text('Deskripsi: ${saved.description}'),
                Text('Teknologi: ${saved.techStack}'),
                Text('Tautan: ${saved.projectUrl}'),
                Text('URL Gambar Proyek: ${saved.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                _title = _description = _techStack = _projectUrl =
                    _projectImageUrl = '';
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        context.read<AuthState>().clearSession();
        _message('Sesi berakhir. Silakan login ulang lalu tekan Save kembali.');
        await ensureLoggedIn(context);
      } else if (error.statusCode == 403) {
        _message(
          'Akun ini tidak punya izin menambahkan proyek. Gunakan akun superuser.',
        );
      } else {
        _message(
          'Proyek belum tersimpan (${error.statusCode}). Silakan coba lagi.',
        );
      }
    } on Exception {
      if (mounted) {
        _message(
          'Tidak dapat menyimpan proyek. Periksa koneksi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label,
    ValueChanged<String> onChanged, {
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.all(8),
    child: TextFormField(
      enabled: !_isSubmitting,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onChanged: onChanged,
      validator: validator,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                'Nama Proyek',
                (value) => _title = value,
                validator: (value) =>
                    _required(value, 'Nama proyek', maxLength: 255),
              ),
              _field(
                'Deskripsi Proyek',
                (value) => _description = value,
                maxLines: 5,
                validator: (value) => _required(value, 'Deskripsi proyek'),
              ),
              _field(
                'Teknologi yang Digunakan',
                (value) => _techStack = value,
                hint: 'Contoh: Flutter, Django, Figma',
                validator: (value) =>
                    _required(value, 'Teknologi', maxLength: 255),
              ),
              _field(
                'Tautan Proyek',
                (value) => _projectUrl = value,
                hint: 'URL Proyek (opsional)',
                validator: (value) => _url(value, 200),
              ),
              _field(
                'URL Gambar Proyek',
                (value) => _projectImageUrl = value,
                hint: 'URL Gambar Proyek (opsional)',
                validator: (value) => _url(value, 500),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
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

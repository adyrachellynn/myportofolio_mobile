import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(project.description),
            const SizedBox(height: 12),
            Text('Teknologi: ${project.techStack}'),
            const SizedBox(height: 12),
            Text('Tautan Proyek: ${project.projectUrl}'),
            if (project.projectImageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Image.network(
                project.projectImageUrl,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Gambar tidak dapat dimuat.'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

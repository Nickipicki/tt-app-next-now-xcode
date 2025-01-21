import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profil-Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Max Mustermann',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mitarbeiter-ID: 12345',
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Persönliche Einstellungen
        const Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Persönliche Einstellungen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('E-Mail'),
                subtitle: Text('max.mustermann@example.com'),
                trailing: Icon(Icons.edit),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Telefon'),
                subtitle: Text('+41 123 456 789'),
                trailing: Icon(Icons.edit),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Passwort ändern'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // App-Einstellungen
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'App-Einstellungen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(themeProvider.selectedColor.colorCode),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(themeProvider.selectedColor.colorCode).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  title: const Text('Farbschema'),
                  subtitle: Text(themeProvider.selectedColor.name),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Farbschema wählen'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: ThemeProvider.colorOptions.length,
                            itemBuilder: (context, index) {
                              final colorOption = ThemeProvider.colorOptions[index];
                              final isSelected = themeProvider.selectedColor.colorCode == colorOption.colorCode;
                              return ListTile(
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color(colorOption.colorCode),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(colorOption.colorCode).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(colorOption.name),
                                trailing: isSelected 
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Color(colorOption.colorCode),
                                      )
                                    : null,
                                onTap: () {
                                  themeProvider.setColor(colorOption);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Benachrichtigungen'),
                subtitle: const Text('Push-Benachrichtigungen aktivieren'),
                value: true,
                onChanged: (bool value) {
                  // TODO: Implement notification settings
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Dunkles Design aktivieren'),
                value: true,
                onChanged: (bool value) {
                  // TODO: Implement theme settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Sprache'),
                subtitle: const Text('Deutsch'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Arbeitszeiteinstellungen
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Arbeitszeiteinstellungen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Standard-Arbeitszeit'),
                subtitle: const Text('8:00 - 17:00'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement working hours settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.free_breakfast),
                title: const Text('Standard-Pausenzeit'),
                subtitle: const Text('30 Minuten'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement break time settings
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Farbschema-Einstellungen
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Farbschema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => Column(
                  children: ThemeProvider.colorOptions.map((colorOption) {
                    final isSelected = 
                        themeProvider.selectedColor.colorCode == colorOption.colorCode;
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(colorOption.colorCode),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white 
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(colorOption.colorCode).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      title: Text(colorOption.name),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: Color(colorOption.colorCode),
                            )
                          : null,
                      onTap: () => themeProvider.setColor(colorOption),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Logout Button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 50),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Abmelden'),
          onPressed: () {
            // TODO: Implement logout
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Abmelden'),
                content: const Text('Möchten Sie sich wirklich abmelden?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement logout logic
                      Navigator.pop(context);
                    },
                    child: const Text('Abmelden'),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),
        
        // Version Info
        Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
} 
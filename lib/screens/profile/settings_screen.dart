import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _SettingItem(
            label: "Notifications",
            value: true,
            onChanged: (val) {},
          ),
          _SettingItem(
            label: "Dark Mode",
            value: false,
            onChanged: (val) {},
          ),
          _SettingItem(
            label: "App Language",
            value: true, // dummy value
            onChanged: (val) {},
            isSwitch: false,
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          Divider(height: 36),
          ListTile(
            title: Text("Terms & Conditions"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            title: Text("Privacy Policy"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isSwitch;
  final Widget? trailing;
  const _SettingItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isSwitch = true,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSwitch
          ? Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF4B8BFF),
      )
          : trailing,
      onTap: isSwitch ? null : () {},
    );
  }
}

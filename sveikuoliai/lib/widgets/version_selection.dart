import 'package:flutter/material.dart';

class VersionSelection extends StatefulWidget {
  final String currentVersion;
  final Function(String) onVersionChanged;

  const VersionSelection(
      {Key? key, required this.currentVersion, required this.onVersionChanged})
      : super(key: key);

  @override
  _VersionSelectionState createState() => _VersionSelectionState();
}

class _VersionSelectionState extends State<VersionSelection> {
  late String selectedVersion;

  @override
  void initState() {
    super.initState();
    selectedVersion = widget.currentVersion;
    print('Selected version: $selectedVersion');
  }

  void _changeVersion(String newVersion) {
    setState(() {
      selectedVersion = newVersion;
    });
    widget.onVersionChanged(newVersion);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildVersionButton(
            'Gija NULIS',
            '0€ /mėn',
            selectedVersion == 'Gija NULIS' || selectedVersion == 'free',
            Color(0xFF72ddf7),
            'free'),
        const SizedBox(width: 10),
        _buildVersionButton(
            'Gija PREMIUM',
            '5€ /mėn',
            selectedVersion == 'Gija PREMIUM' || selectedVersion == 'premium',
            Color(0xFFB388EB),
            'premium'),
      ],
    );
  }

  Widget _buildVersionButton(String label, String price, bool isSelected,
      Color color, String version) {
    return GestureDetector(
      onTap: () => _changeVersion(version),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5)]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

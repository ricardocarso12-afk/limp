import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../models/product_type.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';
import '../widgets/tb_button.dart';

class ProductEntryScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  const ProductEntryScreen({super.key, required this.i18n, required this.session});

  @override
  State<ProductEntryScreen> createState() => _ProductEntryScreenState();
}

class _ProductEntryScreenState extends State<ProductEntryScreen> {
  late final api = ApiClient(widget.session);
  final location = LocationService();
  final picker = ImagePicker();
  final name = TextEditingController();
  final description = TextEditingController();
  final address = TextEditingController();
  final lat = TextEditingController();
  final lng = TextEditingController();
  List<ProductType> types = [];
  ProductType? selectedType;
  final List<File?> photos = List<File?>.filled(5, null);
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final result = await api.productTypes();
      setState(() {
        types = result;
        selectedType = result.isEmpty ? null : result.first;
      });
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _pickPhoto(int index) async {
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 82, maxWidth: 1600);
    if (image != null) setState(() => photos[index] = File(image.path));
  }

  Future<void> _getLocation() async {
    try {
      final pos = await location.currentPosition();
      setState(() {
        lat.text = pos.latitude.toStringAsFixed(7);
        lng.text = pos.longitude.toStringAsFixed(7);
      });
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _submit() async {
    final t = widget.i18n.t;
    final files = photos.whereType<File>().toList();
    if (name.text.trim().isEmpty || selectedType == null || lat.text.trim().isEmpty || lng.text.trim().isEmpty) {
      showAppSnack(context, t('required'), error: true);
      return;
    }
    if (files.length != 5) {
      showAppSnack(context, t('five_photos_required'), error: true);
      return;
    }
    setState(() => loading = true);
    try {
      await api.productEntry(
        name: name.text.trim(),
        productTypeId: selectedType!.id,
        description: description.text.trim(),
        address: address.text.trim(),
        latitude: double.parse(lat.text),
        longitude: double.parse(lng.text),
        photos: files,
      );
      if (mounted) showAppSnack(context, t('entry_saved'));
      setState(() {
        name.clear();
        description.clear();
        address.clear();
        lat.clear();
        lng.clear();
        for (var i = 0; i < photos.length; i++) photos[i] = null;
      });
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n.t;
    return Scaffold(
      appBar: TbAppBar(title: t('entry')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Column(
              children: [
                TextField(controller: name, decoration: InputDecoration(labelText: t('name'), prefixIcon: const Icon(Icons.cleaning_services_outlined))),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductType>(
                  value: selectedType,
                  items: types.map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
                  onChanged: (type) => setState(() => selectedType = type),
                  decoration: InputDecoration(labelText: t('type'), prefixIcon: const Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(controller: description, maxLines: 3, decoration: InputDecoration(labelText: t('description'), prefixIcon: const Icon(Icons.description_outlined))),
                const SizedBox(height: 12),
                TextField(controller: address, decoration: InputDecoration(labelText: t('address'), prefixIcon: const Icon(Icons.place_outlined))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: lat, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('latitude')))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: lng, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('longitude')))),
                ]),
                const SizedBox(height: 12),
                TbButton(text: t('get_location'), icon: Icons.my_location, secondary: true, onPressed: _getLocation),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('five_photos_required'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forest)),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemBuilder: (context, index) {
                  final file = photos[index];
                  return InkWell(
                    onTap: () => _pickPhoto(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: file == null ? AppColors.sage : AppColors.forest, width: file == null ? 1 : 2),
                      ),
                      child: file == null
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.camera_alt_outlined, color: AppColors.leaf),
                              const SizedBox(height: 8),
                              Text('${t('photo')} ${index + 1}', style: const TextStyle(color: AppColors.leaf)),
                            ])
                          : ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(file, fit: BoxFit.cover)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TbButton(text: t('submit_entry'), icon: Icons.save_outlined, loading: loading, onPressed: _submit),
            ]),
          ),
        ],
      ),
    );
  }
}

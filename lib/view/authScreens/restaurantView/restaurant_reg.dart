/* import 'dart:convert';
import 'package:flutter/material.dart';
class Branch {
  String street;
  String floor;
  String zip;
  String province;
  String city;
  double? latitude;
  double? longitude;

  Branch({
    this.street = '',
    this.floor = '',
    this.zip = '',
    this.province = '',
    this.city = '',
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'street': street,
    'floor': floor,
    'zip': zip,
    'province': province,
    'city': city,
    'lat': latitude,
    'lng': longitude,
  };
}

class Restaurant {
  String name;
  String description;
  bool verified;
  String phone; // +92XXXXXXXXXX
  List<Branch> branches;
  TimeOfDay? opening;
  TimeOfDay? closing;

  Restaurant({
    this.name = '',
    this.description = '',
    this.verified = false,
    this.phone = '',
    List<Branch>? branches,
    this.opening,
    this.closing,
  }) : branches = branches ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'verified': verified,
    'phone': phone,
    'opening': opening != null ? _timeOfDayToString(opening!) : null,
    'closing': closing != null ? _timeOfDayToString(closing!) : null,
    'branches': branches.map((b) => b.toJson()).toList(),
  };

  static String _timeOfDayToString(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

/// =======================
/// Province -> Cities map
/// limited, expand as needed
/// =======================
const Map<String, List<String>> provinceCityMap = {
  'Punjab': [
    'Lahore',
    'Faisalabad',
    'Rawalpindi',
    'Gujranwala',
    'Multan',
    'Sialkot'
  ],
  'Sindh': ['Karachi', 'Hyderabad', 'Sukkur', 'Larkana'],
  'KPK': ['Peshawar', 'Mardan', 'Abbottabad', 'Swat'],
  'Balochistan': ['Quetta', 'Gwadar', 'Turbat', 'Khuzdar'],
  'AJK': ['Muzaffarabad', 'Mirpur', 'Kotli'],
  'Gilgit-Baltistan': ['Gilgit', 'Skardu'],
  'Islamabad Capital Territory': ['Islamabad'],
};

/// =======================
/// Utility validators & helpers
/// =======================
final RegExp _nameReg = RegExp(r'^[A-Za-z0-9 ]+$');
final RegExp _pakPhoneReg = RegExp(r'^\+92[0-9]{10}$'); // +92XXXXXXXXXX

bool _isValidName(String s) =>
    s.length >= 3 && s.length <= 15 && _nameReg.hasMatch(s);

bool _isValidPhone(String s) => _pakPhoneReg.hasMatch(s);

/// Allowed time: between 10:00 (10 AM) and 02:00 (next day, 02:00)
bool _isValidOpeningClosing(TimeOfDay? open, TimeOfDay? close) {
  if (open == null || close == null) return false;

  // Helper to convert to minutes since 00:00
  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  final openM = toMinutes(open);
  final closeM = toMinutes(close);

  // allowed open time window: [10:00 -> 26:00) where 26:00 means 2:00 next day (i.e., 02:00 but we treat as +24 hours)
  int normalize(int minutes) {
    // if minutes < 10:00 (600), treat as next day (i.e., add 24h)
    return minutes < 600 ? minutes + 24 * 60 : minutes;
  }

  final openNorm = normalize(openM);
  final closeNorm = normalize(closeM);

  // opening must be >= 10:00 and closing must be after opening and <= 26:00(2am)
  final minAllowed = 10 * 60; // 600 -> 10:00
  final maxAllowedNorm = 26 * 60; // 1560 -> 02:00 next day

  // check original open is >= 10:00 (or it's next-day invalid)
  if (openNorm < minAllowed) return false;
  if (closeNorm > maxAllowedNorm) return false;
  if (closeNorm <= openNorm) return false;

  return true;
}

/// =======================
/// Main Page Widget
/// =======================
class RegisterRestaurantPage extends StatefulWidget {
  const RegisterRestaurantPage({super.key});

  @override
  State<RegisterRestaurantPage> createState() =>
      _RegisterRestaurantPageState();
}

class _RegisterRestaurantPageState extends State<RegisterRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final Restaurant _restaurant = Restaurant();

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  // Temporary branch input controls (single branch editing form)
  String? _branchProvince;
  String? _branchCity;
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _floorCtrl = TextEditingController();
  final TextEditingController _zipCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _floorCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _pickBranchLocation(Branch b) async {
    // This should open a full-screen map picker and return LatLng.
    // For demo we push to MapPickerPage (stub below).
    final LatLng? picked = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (picked != null) {
      setState(() {
        b.latitude = picked.latitude;
        b.longitude = picked.longitude;
      });
    }
  }

  Future<void> _addBranch() async {
    if (_branchProvince == null || _branchCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select province and city for the branch')),
      );
      return;
    }
    final newBranch = Branch(
      province: _branchProvince!,
      city: _branchCity!,
      street: _streetCtrl.text.trim(),
      floor: _floorCtrl.text.trim(),
      zip: _zipCtrl.text.trim(),
    );

    setState(() {
      _restaurant.branches.add(newBranch);
      // clear temp fields
      _streetCtrl.clear();
      _floorCtrl.clear();
      _zipCtrl.clear();
      _branchCity = null;
      _branchProvince = null;
    });
  }

  void _removeBranch(int index) {
    setState(() => _restaurant.branches.removeAt(index));
  }

  Future<void> _pickTime({required bool isOpening}) async {
    final initial = TimeOfDay(hour: 10, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    setState(() {
      if (isOpening) {
        _restaurant.opening = picked;
      } else {
        _restaurant.closing = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // validate opening/closing
    if (!_isValidOpeningClosing(_restaurant.opening, _restaurant.closing)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select valid opening & closing times (10:00 - 02:00 next day).')),
      );
      return;
    }

    if (_restaurant.branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one branch/location.')),
      );
      return;
    }

    // fill restaurant data from controllers
    _restaurant.name = _nameCtrl.text.trim();
    _restaurant.description = _descCtrl.text.trim();
    _restaurant.phone = _phoneCtrl.text.trim();

    // final json
    final payload = _restaurant.toJson();

    // Example API call (adjust URL, headers, auth)
    try {
      final res = await http.post(
        Uri.parse('https://your-api.example.com/restaurants'),
        headers: {
          'Content-Type': 'application/json',
          // Authorization: 'Bearer <token>'
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        // success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant registered successfully')),
        );
        // navigate or reset as needed
      } else {
        final body = res.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.statusCode} ${body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Restaurant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Restaurant Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Restaurant Name'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                ],
                validator: (v) {
                  v = v?.trim() ?? '';
                  if (!_isValidName(v)) {
                    return 'Name must be 3-15 characters and contain only letters, numbers and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLength: 150,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Verified checkbox
              Row(
                children: [
                  Checkbox(
                    value: _restaurant.verified,
                    onChanged: (v) => setState(() => _restaurant.verified = v ?? false),
                  ),
                  const SizedBox(width: 6),
                  const Text('Verified (checked if verified)'),
                ],
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact (+92XXXXXXXXXX)'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  v = v?.trim() ?? '';
                  if (!_isValidPhone(v)) return 'Enter valid Pakistani number starting with +92';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Opening & Closing times
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Opening'),
                      subtitle: Text(_restaurant.opening?.format(context) ?? '10:00 AM (default)'),
                      onTap: () => _pickTime(isOpening: true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Closing'),
                      subtitle: Text(_restaurant.closing?.format(context) ?? '02:00 AM (next day)'),
                      onTap: () => _pickTime(isOpening: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Branch adding area (province, city, street..)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Branch / Location', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Province dropdown
                      DropdownButtonFormField<String>(
                        value: _branchProvince,
                        items: provinceCityMap.keys
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        decoration: const InputDecoration(labelText: 'Province'),
                        onChanged: (v) {
                          setState(() {
                            _branchProvince = v;
                            _branchCity = null; // reset city
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // City dropdown dependent on province
                      DropdownButtonFormField<String>(
                        value: _branchCity,
                        items: (_branchProvince != null
                            ? provinceCityMap[_branchProvince]!
                            : <String>[])
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        decoration: const InputDecoration(labelText: 'City'),
                        onChanged: (v) => setState(() => _branchCity = v),
                      ),
                      const SizedBox(height: 8),

                      // Street / Floor / Zip
                      TextFormField(controller: _streetCtrl, decoration: const InputDecoration(labelText: 'Street / Address')),
                      const SizedBox(height: 8),
                      TextFormField(controller: _floorCtrl, decoration: const InputDecoration(labelText: 'Floor / Unit (optional)')),
                      const SizedBox(height: 8),
                      TextFormField(controller: _zipCtrl, decoration: const InputDecoration(labelText: 'ZIP code (optional)')),
                      const SizedBox(height: 8),

                      // Pick exact location on Map
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // create a temp Branch to pick into
                              final temp = Branch(
                                province: _branchProvince ?? '',
                                city: _branchCity ?? '',
                                street: _streetCtrl.text,
                                floor: _floorCtrl.text,
                                zip: _zipCtrl.text,
                              );
                              _pickBranchLocation(temp).then((_) {
                                // if map pick set lat/lng, we can set to controller fields or directly to newBranch later
                                // to keep simple, if picked set values then add branch with coords
                                if (temp.latitude != null) {
                                  // pick location - add branch
                                  setState(() {
                                    _restaurant.branches.add(temp);
                                    _streetCtrl.clear();
                                    _floorCtrl.clear();
                                    _zipCtrl.clear();
                                    _branchCity = null;
                                    _branchProvince = null;
                                  });
                                }
                              });
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Pick on map'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addBranch,
                            child: const Text('Add Branch'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Show added branches
              if (_restaurant.branches.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text('Added Branches:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _restaurant.branches.length,
                  itemBuilder: (context, i) {
                    final b = _restaurant.branches[i];
                    return ListTile(
                      title: Text('${b.province} • ${b.city}'),
                      subtitle: Text('${b.street} ${b.floor.isNotEmpty ? ' • ${b.floor}' : ''} ${b.zip.isNotEmpty ? ' • ${b.zip}' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Optional: open branch edit modal
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeBranch(i),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Text('Register Restaurant'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _center = const LatLng(33.6844, 73.0479); // Islamabad default
  LatLng? _picked;

  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
            onMapCreated: (c) => _mapController = c,
            onTap: (pos) => setState(() => _picked = pos),
            markers: _picked == null ? {} : {Marker(markerId: const MarkerId('m'), position: _picked!)},
          ),

          Positioned(
            left: 16, right: 16, bottom: 24,
            child: ElevatedButton(
              onPressed: _picked == null ? null : () {
                Navigator.of(context).pop(_picked);
              },
              child: const Text('Select this location'),
            ),
          )
        ],
      ),
    );
  }
}
*/
class PakistaniLocations {
  static const Map<String, List<String>> provinces = {
    'KPK': [
      'Peshawar',
      'Mardan',
      'Abbottabad',
      'Swat',
      'Kohat',
      'Bannu',
      'Charsadda',
      'Nowshera',
      'Mansehra',
      'Haripur',
    ],
    'Balochistan': [
      'Quetta',
      'Turbat',
      'Chaman',
      'Gwadar',
      'Khuzdar',
      'Sibi',
      'Zhob',
      'Loralai',
      'Dera Murad Jamali',
      'Saranan',
    ],
    'AJK': [
      'Muzaffarabad',
      'Mirpur',
      'Kotli',
      'Bhimber',
      'Rawalakot',
      'Bagh',
      'Hattian',
      'Neelum',
      'Sudhnuti',
      'Haveli',
    ],
    'Gilgit-Baltistan': [
      'Gilgit',
      'Skardu',
      'Hunza',
      'Chitral',
      'Diamer',
      'Ghanche',
      'Astore',
      'Ghizer',
      'Kharmang',
      'Shigar',
    ],
    'Sindh': [
      'Karachi',
      'Hyderabad',
      'Sukkur',
      'Larkana',
      'Nawabshah',
      'Mirpur Khas',
      'Jacobabad',
      'Shikarpur',
      'Khairpur',
      'Badin',
    ],
    'Punjab': [
      'Lahore',
      'Faisalabad',
      'Rawalpindi',
      'Multan',
      'Gujranwala',
      'Sialkot',
      'Bahawalpur',
      'Sargodha',
      'Sheikhupura',
      'Jhang',
      'Gujrat',
      'Kasur',
      'Sahiwal',
      'Okara',
      'Mianwali',
    ],
    'Islamabad Capital Territory': [
      'Islamabad',
    ],
  };

  static List<String> getCitiesForProvince(String province) {
    return provinces[province] ?? [];
  }

  static List<String> getProvinces() {
    return provinces.keys.toList();
  }
}


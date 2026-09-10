import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  runApp(const SaglikApp());
}

class SaglikApp extends StatelessWidget {
  const SaglikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Akıllı Sağlık Takip",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Arial",
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
      ),
      home: const LoginPage(),
    );
  }
}

/* ================= MODELLER ================= */

class Kullanici {
  int id;
  String ad;
  String soyad;
  String email;
  String sifre;
  int yas;
  int doktorId;

  Kullanici({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.sifre,
    required this.yas,
    required this.doktorId,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "ad": ad,
        "soyad": soyad,
        "email": email,
        "sifre": sifre,
        "yas": yas,
        "doktorId": doktorId,
      };

  factory Kullanici.fromJson(Map<String, dynamic> json) {
    return Kullanici(
      id: json["id"],
      ad: json["ad"],
      soyad: json["soyad"],
      email: json["email"],
      sifre: json["sifre"],
      yas: json["yas"],
      doktorId: json["doktorId"] ?? 0,
    );
  }
}

class Doktor {
  int id;
  String ad;
  String soyad;
  String email;
  String sifre;
  String uzmanlik;

  Doktor({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.sifre,
    required this.uzmanlik,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "ad": ad,
        "soyad": soyad,
        "email": email,
        "sifre": sifre,
        "uzmanlik": uzmanlik,
      };

  factory Doktor.fromJson(Map<String, dynamic> json) {
    return Doktor(
      id: json["id"],
      ad: json["ad"],
      soyad: json["soyad"],
      email: json["email"],
      sifre: json["sifre"],
      uzmanlik: json["uzmanlik"],
    );
  }
}

class SaglikVerisi {
  int id;
  int kullaniciId;
  int nabiz;
  String tansiyon;
  String tarih;

  SaglikVerisi({
    required this.id,
    required this.kullaniciId,
    required this.nabiz,
    required this.tansiyon,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "kullaniciId": kullaniciId,
        "nabiz": nabiz,
        "tansiyon": tansiyon,
        "tarih": tarih,
      };

  factory SaglikVerisi.fromJson(Map<String, dynamic> json) {
    return SaglikVerisi(
      id: json["id"],
      kullaniciId: json["kullaniciId"],
      nabiz: json["nabiz"],
      tansiyon: json["tansiyon"],
      tarih: json["tarih"],
    );
  }
}

class DoktorUyarisi {
  int id;
  int kullaniciId;
  int doktorId;
  String doktorAdi;
  String mesaj;
  String tarih;

  DoktorUyarisi({
    required this.id,
    required this.kullaniciId,
    required this.doktorId,
    required this.doktorAdi,
    required this.mesaj,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "kullaniciId": kullaniciId,
        "doktorId": doktorId,
        "doktorAdi": doktorAdi,
        "mesaj": mesaj,
        "tarih": tarih,
      };

  factory DoktorUyarisi.fromJson(Map<String, dynamic> json) {
    return DoktorUyarisi(
      id: json["id"],
      kullaniciId: json["kullaniciId"],
      doktorId: json["doktorId"],
      doktorAdi: json["doktorAdi"],
      mesaj: json["mesaj"],
      tarih: json["tarih"],
    );
  }
}

class ChatMessage {
  String mesaj;
  bool kullaniciMesaji;

  ChatMessage({required this.mesaj, required this.kullaniciMesaji});
}

/* ================= STORAGE ================= */
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> kullaniciOlustur({
    required String email,
    required String sifre,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: sifre,
    );
  }

  static Future<UserCredential> girisYap({
    required String email,
    required String sifre,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: sifre,
    );
  }

  static Future<void> sifreSifirlamaMailiGonder(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> cikisYap() async {
    await _auth.signOut();
  }
}


class StorageService {
  static const kullaniciKey = "kullanicilar";
  static const doktorKey = "doktorlar";
  static const veriKey = "saglik_verileri";
  static const uyariKey = "doktor_uyarilari";

  static Future<List<Kullanici>> kullanicilariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(kullaniciKey);
    if (data == null) return [];
    List liste = jsonDecode(data);
    return liste.map((e) => Kullanici.fromJson(e)).toList();
  }

  static Future<void> kullanicilariKaydet(List<Kullanici> liste) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kullaniciKey,
      jsonEncode(liste.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> kullaniciKaydet(Kullanici kullanici) async {
    final liste = await kullanicilariGetir();
    liste.add(kullanici);
    await kullanicilariKaydet(liste);
  }

  static Future<List<Doktor>> doktorlariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(doktorKey);
    if (data == null) return [];
    List liste = jsonDecode(data);
    return liste.map((e) => Doktor.fromJson(e)).toList();
  }

  static Future<void> doktorlariKaydet(List<Doktor> liste) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      doktorKey,
      jsonEncode(liste.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> doktorKaydet(Doktor doktor) async {
    final liste = await doktorlariGetir();
    liste.add(doktor);
    await doktorlariKaydet(liste);
  }

  static Future<List<SaglikVerisi>> verileriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(veriKey);
    if (data == null) return [];
    List liste = jsonDecode(data);
    return liste.map((e) => SaglikVerisi.fromJson(e)).toList();
  }

  static Future<void> saglikVerisiKaydet(SaglikVerisi veri) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = await verileriGetir();
    liste.add(veri);
    await prefs.setString(
      veriKey,
      jsonEncode(liste.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<DoktorUyarisi>> uyarilariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(uyariKey);
    if (data == null) return [];
    List liste = jsonDecode(data);
    return liste.map((e) => DoktorUyarisi.fromJson(e)).toList();
  }

  static Future<void> uyariKaydet(DoktorUyarisi uyari) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = await uyarilariGetir();
    liste.add(uyari);
    await prefs.setString(
      uyariKey,
      jsonEncode(liste.map((e) => e.toJson()).toList()),
    );
  }
}

/* ================= RİSK ANALİZİ ================= */

class RiskAnalizi {
  static bool riskliMi(int nabiz, String tansiyon) {
    return nabiz < 60 || nabiz > 100 || tansiyonAnalizEt(tansiyon).contains("risk");
  }

  static String nabizAnalizEt(int nabiz) {
    if (nabiz < 60) return "Düşük nabız riski olabilir.";
    if (nabiz > 100) return "Yüksek nabız riski olabilir.";
    return "Nabız normal aralıktadır.";
  }

  static String tansiyonAnalizEt(String tansiyon) {
    try {
      final p = tansiyon.split("/");
      final buyuk = int.parse(p[0].trim());
      final kucuk = int.parse(p[1].trim());
      if (buyuk < 90 || kucuk < 60) return "Düşük tansiyon riski olabilir.";
      if (buyuk > 140 || kucuk > 90) return "Yüksek tansiyon riski olabilir.";
      return "Tansiyon normal aralıktadır.";
    } catch (e) {
      return "Tansiyon formatı hatalı.";
    }
  }
}

/* ================= TASARIM ================= */
class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'risk_channel',
      'Risk Bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notifications.show(
      0,
      title,
      body,
      details,
    );
  }
}

class AppColors {
  static const blue = Color(0xff1e88e5);
  static const darkBlue = Color(0xff0d47a1);
  static const bg = Color(0xffeef7ff);
  static const red = Color(0xffe53935);
  static const green = Color(0xff43a047);
  static const orange = Color(0xffff9800);
}

class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType type;

  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= LOGIN ================= */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String rol = "Kullanıcı";
  final emailController = TextEditingController();
  final sifreController = TextEditingController();

  void girisYap() async {
  final email = emailController.text.trim();
  final sifre = sifreController.text.trim();

  if (email.isEmpty || sifre.isEmpty) {
    mesaj("Email ve şifre boş olamaz.");
    return;
  }

  try {
    await AuthService.girisYap(
      email: email,
      sifre: sifre,
    );

    if (rol == "Kullanıcı") {
      final kullanicilar = await StorageService.kullanicilariGetir();

      for (var k in kullanicilar) {
        if (k.email == email) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(kullanici: k),
            ),
          );

          return;
        }
      }
    } else {
      final doktorlar = await StorageService.doktorlariGetir();

      for (var d in doktorlar) {
        if (d.email == email) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DoktorHomePage(doktor: d),
            ),
          );

          return;
        }
      }
    }

    mesaj("Kullanıcı bulundu ama sistem verisi eksik.");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      mesaj("Kullanıcı bulunamadı.");
    } else if (e.code == 'wrong-password') {
      mesaj("Şifre hatalı.");
    } else {
      mesaj("Firebase hata: ${e.message}");
    }
  } catch (e) {
    mesaj("Hata oluştu: $e");
  }
}

  void mesaj(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void kayitSayfasinaGit() {
    if (rol == "Kullanıcı") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciRegisterPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoktorRegisterPage()));
    }
  }

  void sifremiUnuttumGit() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordPage(rol: rol)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/logo.png", width: 120),
                  const SizedBox(height: 14),
                  const Text(
                    "Akıllı Sağlık Takip",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: "Kullanıcı", label: Text("Kullanıcı"), icon: Icon(Icons.person)),
                      ButtonSegment(value: "Doktor", label: Text("Doktor"), icon: Icon(Icons.medical_services)),
                    ],
                    selected: {rol},
                    onSelectionChanged: (secim) => setState(() => rol = secim.first),
                  ),
                  const SizedBox(height: 20),
                  AppInput(controller: emailController, label: "Email", icon: Icons.email),
                  const SizedBox(height: 14),
                  AppInput(controller: sifreController, label: "Şifre", icon: Icons.lock, obscure: true),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white),
                      onPressed: girisYap,
                      icon: const Icon(Icons.login),
                      label: Text("$rol Girişi Yap"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: sifremiUnuttumGit, child: const Text("Şifremi unuttum")),
                  TextButton(onPressed: kayitSayfasinaGit, child: Text("$rol kaydı oluştur")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= ŞİFREMİ UNUTTUM ================= */

class ForgotPasswordPage extends StatefulWidget {
  final String rol;
  const ForgotPasswordPage({super.key, required this.rol});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();


  void sifreGuncelle() async {
  if (email.text.trim().isEmpty) {
    mesaj("Email boş olamaz.");
    return;
  }

  try {
    await AuthService.sifreSifirlamaMailiGonder(
      email.text.trim(),
    );

    if (!mounted) return;

    mesaj("Şifre sıfırlama bağlantısı email adresinize gönderildi.");
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    mesaj("Firebase hata: ${e.message}");
  } catch (e) {
    mesaj("Hata oluştu: $e");
  }
}

  void mesaj(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.rol} Şifre Yenileme")),
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInput(controller: email, label: "Kayıtlı Email", icon: Icons.email),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: sifreGuncelle,
                icon: const Icon(Icons.refresh),
                label: const Text("Sıfırlama Maili Gönder"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/* ================= KAYIT EKRANLARI ================= */

class KullaniciRegisterPage extends StatefulWidget {
  const KullaniciRegisterPage({super.key});

  @override
  State<KullaniciRegisterPage> createState() => _KullaniciRegisterPageState();
}

class _KullaniciRegisterPageState extends State<KullaniciRegisterPage> {
  final ad = TextEditingController();
  final soyad = TextEditingController();
  final email = TextEditingController();
  final sifre = TextEditingController();
  final yas = TextEditingController();
  List<Doktor> doktorlar = [];
  Doktor? secilenDoktor;

  @override
  void initState() {
    super.initState();
    doktorlariYukle();
  }

  Future<void> doktorlariYukle() async {
    final liste = await StorageService.doktorlariGetir();
    setState(() {
      doktorlar = liste;
      if (doktorlar.isNotEmpty) secilenDoktor = doktorlar.first;
    });
  }

  void kaydet() async {
  final kullanicilar = await StorageService.kullanicilariGetir();

  if (ad.text.isEmpty ||
      soyad.text.isEmpty ||
      email.text.isEmpty ||
      sifre.text.isEmpty ||
      yas.text.isEmpty) {
    mesaj("Tüm alanları doldurun.");
    return;
  }

  if (secilenDoktor == null) {
    mesaj("Lütfen doktor seçin.");
    return;
  }

  final yasInt = int.tryParse(yas.text.trim());

  if (yasInt == null) {
    mesaj("Yaş sayı olmalı.");
    return;
  }

  try {
    await AuthService.kullaniciOlustur(
      email: email.text.trim(),
      sifre: sifre.text.trim(),
    );

    await StorageService.kullaniciKaydet(
      Kullanici(
        id: kullanicilar.length + 1,
        ad: ad.text.trim(),
        soyad: soyad.text.trim(),
        email: email.text.trim(),
        sifre: sifre.text.trim(),
        yas: yasInt,
        doktorId: secilenDoktor!.id,
      ),
    );

    if (!mounted) return;

    mesaj("Kayıt başarılı.");
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      mesaj("Bu email zaten kayıtlı.");
    } else if (e.code == 'weak-password') {
      mesaj("Şifre çok zayıf.");
    } else {
      mesaj("Firebase hata: ${e.message}");
    }
  } catch (e) {
    mesaj("Hata oluştu: $e");
  }
}

  void mesaj(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("Kullanıcı Kayıt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInput(controller: ad, label: "Ad", icon: Icons.person),
            const SizedBox(height: 12),
            AppInput(controller: soyad, label: "Soyad", icon: Icons.person_outline),
            const SizedBox(height: 12),
            AppInput(controller: email, label: "Email", icon: Icons.email),
            const SizedBox(height: 12),
            AppInput(controller: sifre, label: "Şifre", icon: Icons.lock, obscure: true),
            const SizedBox(height: 12),
            AppInput(controller: yas, label: "Yaş", icon: Icons.cake, type: TextInputType.number),
            const SizedBox(height: 12),
            doktorlar.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
                    child: const Text("Sistemde kayıtlı doktor yok.\nÖnce doktor kaydı oluşturmalısınız.", textAlign: TextAlign.center),
                  )
                : DropdownButtonFormField<Doktor>(
                    value: secilenDoktor,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Doktor Seç",
                      prefixIcon: const Icon(Icons.medical_services),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                    items: doktorlar.map((doktor) {
                      return DropdownMenuItem<Doktor>(
                        value: doktor,
                        child: Text("Dr. ${doktor.ad} ${doktor.soyad} - ${doktor.uzmanlik}", overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (doktor) => setState(() => secilenDoktor = doktor),
                  ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(onPressed: kaydet, icon: const Icon(Icons.check), label: const Text("Kaydı Tamamla")),
            ),
          ],
        ),
      ),
    );
  }
}

class DoktorRegisterPage extends StatefulWidget {
  const DoktorRegisterPage({super.key});

  @override
  State<DoktorRegisterPage> createState() => _DoktorRegisterPageState();
}

class _DoktorRegisterPageState extends State<DoktorRegisterPage> {
  final ad = TextEditingController();
  final soyad = TextEditingController();
  final email = TextEditingController();
  final sifre = TextEditingController();
  final uzmanlik = TextEditingController();

  void kaydet() async {
  final doktorlar = await StorageService.doktorlariGetir();

  if (ad.text.isEmpty ||
      soyad.text.isEmpty ||
      email.text.isEmpty ||
      sifre.text.isEmpty ||
      uzmanlik.text.isEmpty) {
    mesaj("Tüm alanları doldurun.");
    return;
  }

  try {
    await AuthService.kullaniciOlustur(
      email: email.text.trim(),
      sifre: sifre.text.trim(),
    );

    await StorageService.doktorKaydet(
      Doktor(
        id: doktorlar.length + 1,
        ad: ad.text.trim(),
        soyad: soyad.text.trim(),
        email: email.text.trim(),
        sifre: sifre.text.trim(),
        uzmanlik: uzmanlik.text.trim(),
      ),
    );

    if (!mounted) return;

    mesaj("Doktor kaydı başarılı.");
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      mesaj("Bu email zaten kayıtlı.");
    } else {
      mesaj("Firebase hata: ${e.message}");
    }
  } catch (e) {
    mesaj("Hata oluştu: $e");
  }
}

  void mesaj(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doktor Kayıt")),
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInput(controller: ad, label: "Ad", icon: Icons.person),
            const SizedBox(height: 12),
            AppInput(controller: soyad, label: "Soyad", icon: Icons.person_outline),
            const SizedBox(height: 12),
            AppInput(controller: email, label: "Email", icon: Icons.email),
            const SizedBox(height: 12),
            AppInput(controller: sifre, label: "Şifre", icon: Icons.lock, obscure: true),
            const SizedBox(height: 12),
            AppInput(controller: uzmanlik, label: "Uzmanlık", icon: Icons.medical_services),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(onPressed: kaydet, icon: const Icon(Icons.check), label: const Text("Doktor Kaydını Tamamla")),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= KULLANICI PANELİ ================= */

class HomePage extends StatelessWidget {
  final Kullanici kullanici;
  const HomePage({super.key, required this.kullanici});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Paneli"),
        actions: [
          IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await AuthService.cikisYap();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  },
),
        ],
      ),
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Merhaba, ${kullanici.ad}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(icon: const Icon(Icons.monitor_heart), label: const Text("Nabız ve Tansiyon Ölç"), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OlcumPage(kullanici: kullanici)))),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.history), label: const Text("Geçmiş Veriler"), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GecmisVerilerPage(kullanici: kullanici)))),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.warning), label: const Text("Doktor Uyarıları"), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KullaniciUyarilariPage(kullanici: kullanici)))),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.smart_toy), label: const Text("AI Sağlık Asistanı"), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotPage(kullanici: kullanici)))),
          ],
        ),
      ),
    );
  }
}

class OlcumPage extends StatefulWidget {
  final Kullanici kullanici;
  const OlcumPage({super.key, required this.kullanici});

  @override
  State<OlcumPage> createState() => _OlcumPageState();
}

class _OlcumPageState extends State<OlcumPage> {
  final nabiz = TextEditingController();
  final tansiyon = TextEditingController();

  void kaydet() async {
    final nabizInt = int.tryParse(nabiz.text.trim());
    if (nabizInt == null || tansiyon.text.trim().isEmpty || !tansiyon.text.contains("/")) {
      mesaj("Nabız sayı, tansiyon 120/80 formatında olmalı.");
      return;
    }
    final veriler = await StorageService.verileriGetir();
    await StorageService.saglikVerisiKaydet(
      SaglikVerisi(
        id: veriler.length + 1,
        kullaniciId: widget.kullanici.id,
        nabiz: nabizInt,
        tansiyon: tansiyon.text.trim(),
        tarih: DateTime.now().toString(),
      ),
    );
    await trendBildirimKontrolEt();

    final riskli = RiskAnalizi.riskliMi(nabizInt, tansiyon.text.trim());
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(riskli ? "Risk Durumu Var" : "Değerler Normal"),
        content: Text("${RiskAnalizi.nabizAnalizEt(nabizInt)}\n${RiskAnalizi.tansiyonAnalizEt(tansiyon.text.trim())}"),
        actions: [TextButton(onPressed: () { Navigator.pop(context); nabiz.clear(); tansiyon.clear(); }, child: const Text("Tamam"))],
      ),
    );
  }

  Future<void> trendBildirimKontrolEt() async {
  final tumVeriler = await StorageService.verileriGetir();

  final kullaniciVerileri = tumVeriler
      .where((v) => v.kullaniciId == widget.kullanici.id)
      .toList();

  if (kullaniciVerileri.length < 3) return;

  final son3 = kullaniciVerileri.reversed.take(3).toList();

  bool nabizRisk = son3.every((v) => v.nabiz > 100);

  bool tansiyonRisk = son3.every((v) {
    try {
      final p = v.tansiyon.split("/");
      final buyuk = int.parse(p[0]);
      final kucuk = int.parse(p[1]);

      return buyuk > 140 || kucuk > 90;
    } catch (e) {
      return false;
    }
  });

  if (nabizRisk || tansiyonRisk) {
    await NotificationService.showNotification(
      title: "Risk Durumu Tespit Edildi",
      body:
          "Son ölçümlerinizde yüksek nabız veya tansiyon tespit edildi.",
    );
  }
}

  void mesaj(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ölçüm Yap")),
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInput(controller: nabiz, label: "Nabız", icon: Icons.monitor_heart, type: TextInputType.number),
            const SizedBox(height: 12),
            AppInput(controller: tansiyon, label: "Tansiyon Örn: 120/80", icon: Icons.bloodtype),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: kaydet, icon: const Icon(Icons.save), label: const Text("Kaydet")),
          ],
        ),
      ),
    );
  }
}

class GecmisVerilerPage extends StatefulWidget {
  final Kullanici kullanici;
  const GecmisVerilerPage({super.key, required this.kullanici});

  @override
  State<GecmisVerilerPage> createState() => _GecmisVerilerPageState();
}

class _GecmisVerilerPageState extends State<GecmisVerilerPage> {
  List<SaglikVerisi> veriler = [];

  @override
  void initState() {
    super.initState();
    yukle();
  }

  void yukle() async {
    final tumVeriler = await StorageService.verileriGetir();
    setState(() => veriler = tumVeriler.where((v) => v.kullaniciId == widget.kullanici.id).toList().reversed.toList());
  }

  String tarihKisalt(String tarih) => tarih.length >= 16 ? tarih.substring(0, 16) : tarih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Veriler")),
      backgroundColor: AppColors.bg,
      body: veriler.isEmpty
          ? const Center(child: Text("Henüz veri yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: veriler.length,
              itemBuilder: (context, index) {
                final v = veriler[index];
                final riskli = RiskAnalizi.riskliMi(v.nabiz, v.tansiyon);
                return Card(
                  child: ListTile(
                    leading: Icon(riskli ? Icons.warning : Icons.check_circle, color: riskli ? Colors.red : Colors.green),
                    title: Text("Nabız: ${v.nabiz} | Tansiyon: ${v.tansiyon}"),
                    subtitle: Text(tarihKisalt(v.tarih)),
                    trailing: Text(riskli ? "Risk" : "Normal"),
                  ),
                );
              },
            ),
    );
  }
}

class KullaniciUyarilariPage extends StatefulWidget {
  final Kullanici kullanici;
  const KullaniciUyarilariPage({super.key, required this.kullanici});

  @override
  State<KullaniciUyarilariPage> createState() => _KullaniciUyarilariPageState();
}

class _KullaniciUyarilariPageState extends State<KullaniciUyarilariPage> {
  List<DoktorUyarisi> uyarilar = [];

  @override
  void initState() {
    super.initState();
    yukle();
  }

  void yukle() async {
    final tum = await StorageService.uyarilariGetir();
    setState(() => uyarilar = tum.where((u) => u.kullaniciId == widget.kullanici.id).toList().reversed.toList());
  }

  String tarihKisalt(String tarih) => tarih.length >= 16 ? tarih.substring(0, 16) : tarih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doktor Uyarıları")),
      backgroundColor: AppColors.bg,
      body: uyarilar.isEmpty
          ? const Center(child: Text("Henüz doktor uyarısı yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: uyarilar.length,
              itemBuilder: (context, index) {
                final u = uyarilar[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services, color: AppColors.blue),
                    title: Text(u.mesaj),
                    subtitle: Text("${u.doktorAdi}\n${tarihKisalt(u.tarih)}"),
                  ),
                );
              },
            ),
    );
  }
}

/* ================= DOKTOR PANELİ ================= */

class DoktorHomePage extends StatefulWidget {
  final Doktor doktor;
  const DoktorHomePage({super.key, required this.doktor});

  @override
  State<DoktorHomePage> createState() => _DoktorHomePageState();
}

class _DoktorHomePageState extends State<DoktorHomePage> {
  List<Kullanici> hastalar = [];
  List<SaglikVerisi> veriler = [];
  bool sadeceRiskli = false;

  @override
  void initState() {
    super.initState();
    yukle();
  }

  void yukle() async {
    final tumKullanicilar = await StorageService.kullanicilariGetir();
    final tumVeriler = await StorageService.verileriGetir();
    final doktorunHastalari = tumKullanicilar.where((k) => k.doktorId == widget.doktor.id).toList();
    final hastaIdleri = doktorunHastalari.map((k) => k.id).toSet();
    setState(() {
      hastalar = doktorunHastalari;
      veriler = tumVeriler.where((v) => hastaIdleri.contains(v.kullaniciId)).toList();
    });
  }

  SaglikVerisi? sonOlcum(Kullanici hasta) {
    final liste = veriler.where((v) => v.kullaniciId == hasta.id).toList();
    if (liste.isEmpty) return null;
    return liste.last;
  }

  bool hastaRiskliMi(Kullanici hasta) {
    final son = sonOlcum(hasta);
    if (son == null) return false;
    return RiskAnalizi.riskliMi(son.nabiz, son.tansiyon);
  }

  @override
  Widget build(BuildContext context) {
    final riskliHastalar = hastalar.where(hastaRiskliMi).toList();
    final listelenecek = sadeceRiskli ? riskliHastalar : hastalar;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text("Dr. ${widget.doktor.ad}"),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))],
      ),
      body: RefreshIndicator(
        onRefresh: () async => yukle(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Doktor Paneli", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text("Uzmanlık: ${widget.doktor.uzmanlik}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            StatCard(title: "Toplam Hasta", value: hastalar.length.toString(), icon: Icons.groups, color: AppColors.blue),
            StatCard(title: "Riskli Hasta", value: riskliHastalar.length.toString(), icon: Icons.warning, color: AppColors.red),
            StatCard(title: "Toplam Ölçüm", value: veriler.length.toString(), icon: Icons.monitor_heart, color: AppColors.green),
            const SizedBox(height: 10),
            SwitchListTile(
              value: sadeceRiskli,
              onChanged: (v) => setState(() => sadeceRiskli = v),
              title: const Text("Sadece riskli hastaları göster"),
              secondary: const Icon(Icons.filter_alt),
            ),
            const SizedBox(height: 10),
            if (listelenecek.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: Text("Gösterilecek hasta yok.")))
            else
              ...listelenecek.map((hasta) {
                final son = sonOlcum(hasta);
                final riskli = son != null && RiskAnalizi.riskliMi(son.nabiz, son.tansiyon);
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: riskli ? AppColors.red.withOpacity(0.15) : AppColors.green.withOpacity(0.15),
                      child: Icon(riskli ? Icons.warning : Icons.person, color: riskli ? AppColors.red : AppColors.green),
                    ),
                    title: Text("${hasta.ad} ${hasta.soyad}"),
                    subtitle: Text(son == null ? "Henüz ölçüm yok" : "Son ölçüm: Nabız ${son.nabiz} | Tansiyon ${son.tansiyon}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HastaDetayPage(doktor: widget.doktor, hasta: hasta))).then((_) => yukle()),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class HastaDetayPage extends StatefulWidget {
  final Doktor doktor;
  final Kullanici hasta;
  const HastaDetayPage({super.key, required this.doktor, required this.hasta});

  @override
  State<HastaDetayPage> createState() => _HastaDetayPageState();
}

class _HastaDetayPageState extends State<HastaDetayPage> {
  List<SaglikVerisi> veriler = [];
  List<DoktorUyarisi> uyarilar = [];

  @override
  void initState() {
    super.initState();
    yukle();
  }

  void yukle() async {
    final tumVeriler = await StorageService.verileriGetir();
    final tumUyarilar = await StorageService.uyarilariGetir();
    setState(() {
      veriler = tumVeriler.where((v) => v.kullaniciId == widget.hasta.id).toList().reversed.toList();
      uyarilar = tumUyarilar.where((u) => u.kullaniciId == widget.hasta.id).toList().reversed.toList();
    });
  }

  String tarihKisalt(String tarih) => tarih.length >= 16 ? tarih.substring(0, 16) : tarih;

  void uyariGonder() {
    final mesajController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${widget.hasta.ad} için uyarı"),
        content: TextField(
          controller: mesajController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Örn: Ölçümlerinizi takip edin ve dinlenme halinde tekrar ölçüm yapın.", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (mesajController.text.trim().isEmpty) return;
              final tumUyarilar = await StorageService.uyarilariGetir();
              await StorageService.uyariKaydet(
                DoktorUyarisi(
                  id: tumUyarilar.length + 1,
                  kullaniciId: widget.hasta.id,
                  doktorId: widget.doktor.id,
                  doktorAdi: "Dr. ${widget.doktor.ad} ${widget.doktor.soyad}",
                  mesaj: mesajController.text.trim(),
                  tarih: DateTime.now().toString(),
                ),
              );
              if (!mounted) return;
              Navigator.pop(context);
              yukle();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uyarı gönderildi.")));
            },
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final son = veriler.isNotEmpty ? veriler.first : null;
    final riskli = son != null && RiskAnalizi.riskliMi(son.nabiz, son.tansiyon);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text("${widget.hasta.ad} ${widget.hasta.soyad}")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uyariGonder,
        icon: const Icon(Icons.send),
        label: const Text("Uyarı Gönder"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hasta Bilgileri", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Ad Soyad: ${widget.hasta.ad} ${widget.hasta.soyad}"),
                  Text("Yaş: ${widget.hasta.yas}"),
                  Text("Email: ${widget.hasta.email}"),
                  const SizedBox(height: 8),
                  Text("Son Durum: ${son == null ? "Ölçüm yok" : riskli ? "Riskli" : "Normal"}", style: TextStyle(fontWeight: FontWeight.bold, color: riskli ? AppColors.red : AppColors.green)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (son != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: Icon(riskli ? Icons.warning : Icons.check_circle, color: riskli ? AppColors.red : AppColors.green),
                title: Text("Son Ölçüm: Nabız ${son.nabiz} | Tansiyon ${son.tansiyon}"),
                subtitle: Text("${tarihKisalt(son.tarih)}\n${RiskAnalizi.nabizAnalizEt(son.nabiz)}\n${RiskAnalizi.tansiyonAnalizEt(son.tansiyon)}"),
              ),
            ),
          const SizedBox(height: 18),
          const Text("Geçmiş Ölçümler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (veriler.isEmpty)
            const Text("Henüz ölçüm yok.")
          else
            ...veriler.map((v) {
              final r = RiskAnalizi.riskliMi(v.nabiz, v.tansiyon);
              return Card(
                child: ListTile(
                  leading: Icon(r ? Icons.warning : Icons.check_circle, color: r ? AppColors.red : AppColors.green),
                  title: Text("Nabız: ${v.nabiz} | Tansiyon: ${v.tansiyon}"),
                  subtitle: Text(tarihKisalt(v.tarih)),
                  trailing: Text(r ? "Risk" : "Normal"),
                ),
              );
            }),
          const SizedBox(height: 18),
          const Text("Gönderilen Uyarılar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (uyarilar.isEmpty)
            const Text("Henüz uyarı gönderilmedi.")
          else
            ...uyarilar.map((u) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.message, color: AppColors.blue),
                    title: Text(u.mesaj),
                    subtitle: Text("${u.doktorAdi}\n${tarihKisalt(u.tarih)}"),
                  ),
                )),
        ],
      ),
    );
  }
}

/* ================= AI CHATBOT ================= */

class ChatBotPage extends StatefulWidget {
  final Kullanici kullanici;
  const ChatBotPage({super.key, required this.kullanici});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final soruController = TextEditingController();
  List<ChatMessage> mesajlar = [
    ChatMessage(mesaj: "Merhaba, ben AI Sağlık Asistanı. Nabız, tansiyon, son ölçüm ve risk durumunuz hakkında yardımcı olabilirim.", kullaniciMesaji: false),
  ];

  void soruGonder() async {
    final soru = soruController.text.trim();
    if (soru.isEmpty) return;
    setState(() {
      mesajlar.add(ChatMessage(mesaj: soru, kullaniciMesaji: true));
      soruController.clear();
    });
    final cevap = await cevapUret(soru);
    setState(() => mesajlar.add(ChatMessage(mesaj: cevap, kullaniciMesaji: false)));
  }

  Future<String> cevapUret(String soru) async {
    try {
      final tumVeriler = await StorageService.verileriGetir();
      final kullaniciVerileri = tumVeriler.where((v) => v.kullaniciId == widget.kullanici.id).toList();
      SaglikVerisi? sonVeri;
      if (kullaniciVerileri.isNotEmpty) sonVeri = kullaniciVerileri.last;

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"soru": soru, "nabiz": sonVeri?.nabiz, "tansiyon": sonVeri?.tansiyon}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["cevap"];
      } else {
        return "AI sunucusu hata verdi.\nKod: ${response.statusCode}\nCevap: ${response.body}";
      }
    } catch (e) {
      return "Bağlantı hatası oluştu.\nDetay: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("AI Sağlık Asistanı")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = mesajlar[index];
                return Align(
                  alignment: mesaj.kullaniciMesaji ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(color: mesaj.kullaniciMesaji ? AppColors.blue : Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Text(mesaj.mesaj, style: TextStyle(color: mesaj.kullaniciMesaji ? Colors.white : Colors.black87)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: soruController,
                    decoration: InputDecoration(hintText: "Sorunuzu yazın...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(18))),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: soruGonder, icon: const Icon(Icons.send), color: AppColors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

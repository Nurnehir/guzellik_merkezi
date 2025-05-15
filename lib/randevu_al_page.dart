import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class RandevuAlPage extends StatefulWidget {
  final Map<String, dynamic> salonData;
  final String? existingAppointmentId;
  final String? serviceName;

  RandevuAlPage({
    required this.salonData,
    this.existingAppointmentId,
    this.serviceName,
  });

  @override
  _RandevuAlPageState createState() => _RandevuAlPageState();
}

class _RandevuAlPageState extends State<RandevuAlPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? selectedDate;
  String? selectedTime;
  List<String> timeSlots = [];
  List<String> bookedHours = [];

  @override
  void initState() {
    super.initState();
    generateTimeSlots();
  }

  void generateTimeSlots() {
    final times = <String>[];
    for (int hour = 9; hour < 18; hour++) {
      times.add('${hour.toString().padLeft(2, '0')}:00');
      times.add('${hour.toString().padLeft(2, '0')}:30');
    }
    times.add('18:00');
    timeSlots = times;
  }

  Future<void> fetchBookedHours() async {
    if (selectedDate == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('appointments')
            .where('salonId', isEqualTo: widget.salonData['id'])
            .get();

    final sameDayAppointments = querySnapshot.docs.where((doc) {
      final ts = doc['appointmentDate'] as Timestamp;
      final apptDate = ts.toDate();
      return DateFormat('yyyy-MM-dd').format(apptDate) == dateStr;
    });

    setState(() {
      bookedHours =
          sameDayAppointments.map((doc) {
            final ts = doc['appointmentDate'] as Timestamp;
            return DateFormat('HH:mm').format(ts.toDate());
          }).toList();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
      locale: Locale("tr", "TR"),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple.shade300,
            colorScheme: ColorScheme.light(primary: Colors.purple.shade300),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
      await fetchBookedHours();
    }
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      final datetime = DateFormat("yyyy-MM-dd HH:mm").parse(
        "${DateFormat('yyyy-MM-dd').format(selectedDate!)} $selectedTime",
      );

      final data = {
        'salonId': widget.salonData['id'],
        'salonName': widget.salonData['name'],
        'salonAddress': widget.salonData['address'] ?? '',
        'salonCategory': widget.salonData['category'] ?? '',
        'userName': _nameController.text,
        'userSurname': _surnameController.text,
        'phone': _phoneController.text,
        'service': widget.serviceName ?? '',
        'userEmail': FirebaseAuth.instance.currentUser?.email ?? '',
        'appointmentDate': datetime,
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      if (widget.existingAppointmentId != null) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.existingAppointmentId)
            .update(data);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Randevunuz güncellendi!")));
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('appointments').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Randevunuz başarıyla kaydedildi!")),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAD4D4), Color(0xFFA3CEF1), Color(0xFFD9B8F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Randevu Al - ${widget.salonData['name']}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                SizedBox(height: 20),
                _buildInput(_nameController, 'İsim', Icons.person),
                _buildInput(
                  _surnameController,
                  'Soyisim',
                  Icons.person_outline,
                ),
                _buildInput(
                  _phoneController,
                  'Telefon',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                Text(
                  'Tarih Seçin:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate != null
                        ? DateFormat(
                          'dd MMMM yyyy',
                          'tr_TR',
                        ).format(selectedDate!)
                        : 'Tarih Seç',
                  ),
                  onPressed: _selectDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (selectedDate != null) ...[
                  Text(
                    'Saat Seçin:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        timeSlots.map((time) {
                          final isBooked = bookedHours.contains(time);
                          final isSelected = selectedTime == time;
                          return ChoiceChip(
                            label: Text(
                              time,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isBooked
                                        ? Colors.white
                                        : isSelected
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected:
                                isBooked
                                    ? null
                                    : (_) {
                                      setState(() => selectedTime = time);
                                    },
                            selectedColor: Colors.green.shade400,
                            backgroundColor:
                                isBooked
                                    ? Colors.red.shade400
                                    : Colors.grey.shade200,
                            disabledColor: Colors.red.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color:
                                    isBooked
                                        ? Colors.red
                                        : isSelected
                                        ? Colors.green
                                        : Colors.grey.shade400,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveAppointment,
                  child: Text(
                    widget.existingAppointmentId != null
                        ? 'Randevuyu Güncelle'
                        : 'Randevuyu Kaydet',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.pink.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters:
            label == 'Telefon'
                ? [
                  LengthLimitingTextInputFormatter(11),
                  FilteringTextInputFormatter.digitsOnly,
                ]
                : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label boş bırakılamaz';
          }
          if (label == 'Telefon' && value.length != 11) {
            return 'Telefon numarası 11 haneli olmalıdır';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.purple),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

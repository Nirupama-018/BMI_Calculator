import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(BMICalculator());
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _bmiResult = "";
  String _selectedGender = "1"; // 1 = Male, 2 = Female
  String _heightUnit = "cm"; // Default to cm
  Map<String, dynamic>? bmiData;

  @override
  void initState() {
    super.initState();
    _loadBMIData();
  }

  Future<void> _loadBMIData() async {
    try {
      String data = await rootBundle.loadString('assets/bmi_percentiles.json');
      setState(() {
        bmiData = json.decode(data);
      });
    } catch (e) {
      print("Error loading BMI data: $e");
    }
  }

  void _calculateBMI() {
    double? weight = double.tryParse(_weightController.text);
    double? height;

    if (_heightUnit == "cm") {
      height = double.tryParse(_heightCmController.text);
    } else {
      double? feet = double.tryParse(_heightFeetController.text);
      double? inches = double.tryParse(_heightInchesController.text);

      if (feet != null && inches != null) {
        height = (feet * 30.48) + (inches * 2.54); // Convert feet & inches to cm
      }
    }

    int? age = int.tryParse(_ageController.text);

    if (weight == null || height == null || height == 0 || age == null || bmiData == null) {
      setState(() {
        _bmiResult = "Please enter valid values.";
      });
      return;
    }

    height = height / 100; // Convert cm to meters
    double bmi = weight / (height * height);

    String status = _classifyBMI(bmi, age, _selectedGender);

    setState(() {
      _bmiResult = "Your BMI is ${bmi.toStringAsFixed(2)} ($status).";
    });
  }

  String _classifyBMI(double bmi, int age, String gender) {
    if (bmiData == null || !bmiData!.containsKey(gender)) {
      return "Classification unavailable";
    }

    List<dynamic>? ageList = bmiData![gender];
    if (ageList == null || ageList.isEmpty) {
      return "Classification unavailable";
    }

    double ageInMonths = age * 12;
    Map<String, dynamic>? closestAgeEntry;
    double closestAgeDiff = double.infinity;

    for (var entry in ageList) {
      if (entry is Map<String, dynamic> && entry.containsKey("age_months")) {
        double entryAge = entry["age_months"];
        double ageDiff = entryAge - ageInMonths;
        if (ageDiff >= 0 && ageDiff < closestAgeDiff) {
          closestAgeDiff = ageDiff;
          closestAgeEntry = entry;
        }
      }
    }

    if (closestAgeEntry == null) {
      for (var entry in ageList) {
        if (entry is Map<String, dynamic> && entry.containsKey("age_months")) {
          double entryAge = entry["age_months"];
          double ageDiff = ageInMonths - entryAge;
          if (ageDiff > 0 && ageDiff < closestAgeDiff) {
            closestAgeDiff = ageDiff;
            closestAgeEntry = entry;
          }
        }
      }
    }

    if (closestAgeEntry == null) {
      return "Classification unavailable";
    }

    double underweightThreshold = closestAgeEntry["underweight_threshold"];
    double overweightThreshold = closestAgeEntry["overweight_threshold"];
    double obesityThreshold = closestAgeEntry["obesity_threshold"];

    if (bmi < underweightThreshold) return "Underweight";
    if (bmi < overweightThreshold) return "Normal weight";
    if (bmi < obesityThreshold) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8967B3), // Background color
      appBar: AppBar(
        title: Text("BMI Calculator"),
        backgroundColor: Color(0xFFCB80AB),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGenderSelector(),
            _buildTextField("Age (years)", _ageController),
            _buildHeightInput(),
            _buildTextField("Weight (kg)", _weightController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCB80AB),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Calculate BMI"),
            ),
            SizedBox(height: 20),
            Text(
              _bmiResult,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Height Unit:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildRadioButton("cm"),
            SizedBox(width: 10),
            _buildRadioButton("feet"),
          ],
        ),
        SizedBox(height: 5),
        if (_heightUnit == "cm")
          _buildTextField("Height (cm)", _heightCmController)
        else
          Row(
            children: [
              Expanded(child: _buildTextField("Feet", _heightFeetController)),
              SizedBox(width: 10),
              Expanded(child: _buildTextField("Inches", _heightInchesController)),
            ],
          ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _heightUnit,
          activeColor: Color(0xFFCB80AB),
          onChanged: (String? newValue) {
            setState(() {
              _heightUnit = newValue!;
              _heightCmController.clear();
              _heightFeetController.clear();
              _heightInchesController.clear();
            });
          },
        ),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _genderOption("Male", "1"),
        SizedBox(width: 20),
        _genderOption("Female", "2"),
      ],
    );
  }

  Widget _genderOption(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedGender == value ? Color(0xFFCB80AB) : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

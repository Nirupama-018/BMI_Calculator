# BMI Calculator

A Flutter application that calculates **Body Mass Index (BMI)** and classifies the result using **age- and gender-specific BMI percentile data**. The application supports both metric and imperial height input and provides an easy-to-use interface for quick health assessment.

## Features

* 📱 Built with Flutter
* ⚖️ BMI calculation based on weight and height
* 👤 Age and gender input
* 📏 Supports:

  * Height in centimeters
  * Height in feet and inches
* 📊 BMI classification using external percentile data
* 📂 Loads BMI percentile information from JSON assets
* ✅ Input validation for invalid or incomplete values

## How It Works

1. Enter your weight.
2. Select your preferred height unit.
3. Enter your height.
4. Enter your age.
5. Select your gender.
6. Press **Calculate** to view:

   * Calculated BMI
   * BMI category based on the loaded percentile dataset

## Technologies Used

* Flutter
* Dart
* Material Design
* JSON Asset Loading

## Project Structure

```text
BMI_Calculator/
│── lib/
│   └── main.dart
│── assets/
│   ├── bmi_percentiles.json
│   ├── bmi-age-2022.csv
│   └── cdc_bmi_data.json
│── pubspec.yaml
└── README.md
```

## Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK

### Installation

Clone the repository:

```bash
git clone https://github.com/Nirupama-018/BMI_Calculator.git
```

Navigate into the project:

```bash
cd BMI_Calculator
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Notes

This project uses external BMI percentile datasets stored as JSON assets to determine BMI classifications based on the user's age and gender. Ensure the required asset files are present before running the application.

## Future Improvements

* Save BMI history
* Dark mode
* Health recommendations
* BMI charts and visualizations
* Unit tests
* Better UI/UX

## Author

Developed as a Flutter application to explore mobile development, JSON asset handling, and health-related calculations.

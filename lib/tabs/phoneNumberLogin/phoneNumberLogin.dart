import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safehome/api/auth_service.dart';
import '../../home_page.dart';
import 'phoneAuthService.dart';

class Phonenumberlogin extends StatefulWidget {
  const Phonenumberlogin({super.key});

  @override
  State<Phonenumberlogin> createState() => _PhonenumberloginState();
}

class _PhonenumberloginState extends State<Phonenumberlogin> {
  CountryCode _selectedCountry = countries[0];
  final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9), // e.g. 9 digits after +256
              ],
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    style: BorderStyle.solid,
                    color: Colors.black38,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black38, width: 2),
                  borderRadius: BorderRadius.circular(2),
                ),
                filled: true,
                fillColor: Colors.white,

                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CountryCode>(
                      value: _selectedCountry,
                      onChanged: (CountryCode? newValue) {
                        setState(() {
                          _selectedCountry = newValue!;
                        });
                      },
                      items: countries.map((country) {
                        return DropdownMenuItem<CountryCode>(
                          value: country,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country.flag,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(country.code),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                labelText: "Phone Number",
                hintText: "7XXXXXXXX",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final localNumber = phoneController.text.trim();
                  if (localNumber.isEmpty) {
                    // show error
                    return;
                  }

                  // Remove leading 0 if typed
                  final cleaned = localNumber.startsWith('0')
                      ? localNumber.substring(1)
                      : localNumber;

                  final fullNumber = "${_selectedCountry.code}$cleaned";

                  debugPrint("Saving phone: $fullNumber");
                  PhoneAuthService().verifyPhoneNumber(
                    phoneNumber: fullNumber,
                    onCodeSent: (verificationId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtpScreen(verificationId, fullNumber),
                        ),
                      );
                    },
                    onError: (error) {
                      print(error);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(20),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  elevation: 15,
                  shadowColor: Colors.grey,
                ),
                child: const Text("Login"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpScreen extends StatelessWidget {
  final String verificationId;
  final String finalNumber;
  OtpScreen(this.verificationId, this.finalNumber, {super.key});

  final TextEditingController otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  String getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> otpVerification(BuildContext context) async {
    final otp = getOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter complete OTP")));
      return;
    }

    print("OTP entered: $otp");
  }

  Future<void> _handleOTP(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String getOtp() {
      return _otpControllers.map((c) => c.text).join();
    }

    final otp = getOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter complete OTP")));
      return;
    }

    try {
      final success = await authService.signInWithOTP(verificationId, otp);

      if (!success) {
        debugPrint("Phone Login Failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Phone Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SafeSpace()),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Verify Code",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Please enter the OTP sent to your phone",
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Text(
                finalNumber,
                style: TextStyle(fontSize: 18, color: Colors.amber),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              ElevatedButton(
                onPressed: () async {
                  _handleOTP(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  fixedSize: Size(double.infinity, 50),
                  shadowColor: Colors.grey,
                ),
                child: const Text("Verify"),
              ),
              Text(
                "Didn't receive the code?",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: Text("Resend the Code"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode(this.name, this.code, this.flag);
}

final List<CountryCode> countries = [
  CountryCode("Uganda", "+256", "🇺🇬"),
  CountryCode("Kenya", "+254", "🇰🇪"),
  CountryCode("Tanzania", "+255", "🇹🇿"),
  CountryCode("Rwanda", "+250", "🇷🇼"),
  CountryCode("USA", "+1", ""),
];

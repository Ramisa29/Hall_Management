

import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final EmailVerificationScreenController _emailVerificationScreenController =
      Get.find<EmailVerificationScreenController>();
  final OtpVerificationScreenController _otpVerificationScreenController =
      Get.find<OtpVerificationScreenController>();
  final TextEditingController _otpTEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpVerificationScreenController.seconds = 120;
    _otpVerificationScreenController.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Enter OTP Code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text('A 6 digit OTP Code has been Sent',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(
                  height: 24,
                ),
                PinCodeTextField(
                  controller: _otpTEController,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: AppColors.primaryColor,
                    inactiveColor: AppColors.primaryColor,
                    selectedColor: Colors.green,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  onCompleted: (v) {},
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    return true;
                  },
                  appContext: context,
                ),
                const SizedBox(


height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: GetBuilder<OtpVerificationScreenController>(
                      builder: (otpController) {
                    if (otpController.otpVerificationInProgress) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () {
                        verifyOtp(otpController);
                      },
                      child: const Text('Next'),
                    );
                  }),
                ),
                const SizedBox(
                  height: 24,
                ),
                GetBuilder<OtpVerificationScreenController>(
                    builder: (otpVerificationScreenController) {
                  return Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            const TextSpan(text: 'This code will expire in '),
                            TextSpan(
                              text: '${otpVerificationScreenController.seconds}'
                                  's',
                              style: TextStyle(
                                color:
                                    otpVerificationScreenController.seconds == 0
                                        ? Colors.grey
                                        : AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_otpVerificationScreenController.seconds == 0) {
                            _emailVerificationScreenController
                                .verifyEmail(widget.email);
                            _otpVerificationScreenController.seconds = 120;
                            _otpVerificationScreenController.startTimer();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              _otpVerificationScreenController.seconds == 0
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                        ),
                        child: const Text('Resend Code'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyOtp(OtpVerificationScreenController controller) async {
    final response =
        await controller.verifyOtp(widget.email, _otpTEController.text.trim());
    if (response) {
      Get.snackbar('Success', 'OTP verification successful.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          borderRadius: 10,
          snackPosition: SnackPosition.BOTTOM);
      await Get.find<ReadProfileController>().readProfileData();

      Get.find<ReadProfileController>().readProfileModel.data == null
          ? Get.offAll(() => CreateProfileScreen())
          : Get.offAll(() => const MainBottomNavScreen());
    } else {
      Get.snackbar('Failed', 'Otp verification failed! Try again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 10,
          snackPosition: SnackPosition.BOTTOM);
      _otpTEController.clear();
      controller.timer.cancel();
    }
  }
}
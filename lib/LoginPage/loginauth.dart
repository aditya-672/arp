import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final _firebase = FirebaseAuth.instance;

class _LoginPageState extends State<LoginPage> {
  TextEditingController otpController = TextEditingController();
  var key = GlobalKey<ScaffoldState>();
  var _enteredEmail = '';
  var _enteredName = '';
  var _enteredPassword = '';
  var _enteredPhoneNumber = '';
  var _enternedGender = '';
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _verificatID = '';
  var _isSigning = false;

  void _submitOTP(String vid) async {
    try {
      var otp = otpController.text;

      PhoneAuthProvider.credential(verificationId: vid, smsCode: otp);

      // await _firebase.signInWithCredential(cred);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'OTP has been Verified. Successfully Signed In',
            style: TextStyle(color: Colors.black),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          padding: const EdgeInsets.all(20),
          dismissDirection: DismissDirection.vertical,
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          margin: const EdgeInsets.only(bottom: 60, right: 40, left: 40),
          backgroundColor: Colors.green.shade300,
        ),
      );
      Navigator.of(context).pop();
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        "name": _enteredName,
        "email": _enteredEmail,
        "phonenumber": _enteredPhoneNumber,
        "gender": _enternedGender,
      });

      // ignore: use_build_context_synchronously
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      if (error.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).clearSnackBars();
        _showSnackbar('Email Already In User');
      }
      if (error.code == 'invalid-verification-code') {
        ScaffoldMessenger.of(context).clearSnackBars();
        _showSnackbar('Invalid Verification Vode');
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected Error Occured : ${error.message!}')));
    }
  }

  void _showModal(String vid) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 23,
      isDismissible: true,
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 400,
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "OTP Verification",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: otpController,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      hintText: '******',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () => _submitOTP(vid),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    child: _isSigning
                        ? const CircularProgressIndicator()
                        : Text(
                            'Verify',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        padding: const EdgeInsets.all(20),
        dismissDirection: DismissDirection.vertical,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
        margin: const EdgeInsets.only(bottom: 60, right: 40, left: 40),
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.6),
      ),
    );
  }

  void _submit() async {
    setState(() {
      _isSigning = true;
    });
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      setState(() {
        _isSigning = false;
      });
      return;
    }

    _form.currentState!.save();

    if (_isLogin) {
      try {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } on FirebaseAuthException catch (error) {
        if (!mounted) return;
        if (error.code == 'wrong-password') {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackbar('Wrong Password Provided');
        } else if (error.code == 'user-not-found') {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackbar('No user found for that email.');
        } else if (error.code == "invalid-credential") {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackbar('Invalid Credentials');
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackbar('Unexpected error: ${error.code}');
        }
      }
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91$_enteredPhoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).clearSnackBars();
            _showSnackbar(e.code);
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificatID = verificationId;
            setState(() {
              _isSigning = false;
            });
            _showModal(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } on FirebaseAuthException catch (error) {
        setState(() {
          _isSigning = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        _showSnackbar(error.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const FlutterLogo(
                size: 120,
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 26,
                  margin: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Enter address',
                                contentPadding: EdgeInsets.all(8),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email address';
                                }

                                if (!value.contains('@')) {
                                  return 'Invalid Email Address';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredEmail = newValue!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter full name';
                                  }
                                  return null;
                                },
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                onSaved: (newValue) {
                                  _enteredName = newValue!;
                                },
                              ),
                            if (!_isLogin)
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (value.length != 10) {
                                    return 'Please enter 10 digit number';
                                  }
                                  return null;
                                },
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                  prefixText: '+91 ',
                                  labelText: 'Phone Number',
                                  contentPadding: EdgeInsets.all(8),
                                  helper: Text(
                                    "*This number will be used for OTP verification",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13),
                                  ),
                                ),
                                onSaved: (newValue) {
                                  _enteredPhoneNumber = newValue!;
                                },
                              ),
                            if (!_isLogin)
                              DropdownButtonFormField(
                                // value: selectedvalue,
                                decoration: const InputDecoration(
                                  labelText: 'Select Gender',
                                ),
                                // isDense: true,
                                autofocus: false,
                                padding: const EdgeInsets.all(8),
                                borderRadius: BorderRadius.circular(20),
                                dropdownColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _enternedGender = value!;
                                  });
                                },
                                onSaved: (newValue) {
                                  _enternedGender = newValue!;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Select a gender';
                                  }
                                  return null;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Enter password',
                                contentPadding: EdgeInsets.all(8),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.trim().length < 6) {
                                  return 'Password Length should be greater than 6';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _enteredPassword = newValue!,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: _isSigning
                                  ? const CircularProgressIndicator()
                                  : Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

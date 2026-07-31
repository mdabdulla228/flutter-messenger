import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text('Messenger'),
                              ),
                                    body: const Center(
                                            child: Text(
                                                      'Hello Messenger',
                                                                style: TextStyle(fontSize: 24),
                                                                        ),
                                                                              ),
                                                                                  );
                                                                                    }
                                                                                    }
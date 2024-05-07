import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String environmentValue = "PRODUCTION";
  String appId = "";
  String merchantId = "PGTESTPAYUAT";
  bool enableLogging = true;
  String saltKey="099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex="1";
  Object? result;
  String body = "";
  String appSchema = "";
  String checksum = "";
  String? packageName;
  String callback="";
  // String uat="https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay";
  String endPoint="/pg/v1/pay";

  @override

  void initState() {
    initPhonepe();
    body=getChecksum().toString();
    super.initState();
  }

  initPhonepe() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
          print(error);
      handleError(error);
      return <dynamic>{};
    });
  }

  startTransaction() {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) => {
              setState(() {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                   result= "Flow Completed - Status: Success!";
                  } else {
                  result=  "Flow Completed - Status: $status and Error: $error";
                  }
                } else {
                 result= "Flow Incomplete";
                }
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  getChecksum(){
   final data= {
      "merchantId": merchantId,
    "merchantTransactionId": "t_52554",
    "merchantUserId": "MUID123",
    "amount": 10000,
    "callbackUrl": callback,
    "mobileNumber": "9999999999",
    "paymentInstrument": {
    "type": "PAY_PAGE"
  }
  };
   String base64body=base64.encode(utf8.encode(json.encode(data)));
   checksum="${sha256.convert(utf8.encode(base64body+endPoint+saltKey))}###$saltIndex";
   return base64body;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: TextButton(onPressed: (){
          startTransaction();
        }, child: Text("click here")),
      ),
    );
  }

  void handleError(error) {
    error;
  }
}

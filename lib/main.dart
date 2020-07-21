import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/bloc/list_style_color_bloc.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/feedback_form.dart';
import 'package:vilmod/screens/forgot_password.dart';
import 'package:vilmod/screens/home_page.dart';
import 'package:vilmod/screens/splash_screen.dart';
import 'package:vilmod/services/auth.dart';
import 'package:vilmod/utils/SizeConfig.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => CartListBloc()),
        Bloc((i) => ColorBloc()),
      ],
      child: MultiProvider(
        providers: [
          StreamProvider<FirebaseUser>.value(
              value: FirebaseAuth.instance.onAuthStateChanged),
          Provider<FoodItemList>(create: (_) => FoodItemList()),
        ],
        child: StreamProvider<User>.value(
          value: AuthService().user,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  SizeConfig().init(constraints, orientation);
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    //home: ProcessOrderPayment(),
                    home: VMSplashScreen(),
                    theme: ThemeData(
                        primaryColor: Colors.red[900], fontFamily: 'Poppins'),
                    routes: {
                      '/reset_password': (context) => PasswordReset(),
                      '/home_page': (context) => MyHomePage(),
                      '/feedback_page': (context) => FeedbackPage(),
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

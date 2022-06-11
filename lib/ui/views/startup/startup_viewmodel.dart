import 'package:spark/app/app.locator.dart';
import 'package:spark/app/app.logger.dart';
import 'package:spark/app/app.router.dart';
import 'package:spark/services/bluetooth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');

  final _navigationService = locator<NavigationService>();
  final _bluetoothService = locator<BluetoothService>();

  void handleStartupLogic() async {
    log.i('Startup');
    // _baseService.setCurrentRoute(Routes.startUpView);
    _bluetoothService.init();
    await Future.delayed(const Duration(milliseconds: 800));
    // if (isUserLoggedIn) {
    //   log.d('Logged in user available');
    _navigationService.replaceWith(Routes.homeView);
    // } else {
    //   log.d('No logged in user');
    // }
  }

  // void doSomething() {
  //   _navigationService.replaceWith(
  //     Routes.hostel,
  //     arguments: DetailsArguments(name: 'FilledStacks'),
  //   );
  // }

  // void getStarted() {
  //   _navigationService.replaceWith(
  //     Routes.details,
  //     arguments: DetailsArguments(name: 'FilledStacks'),
  //   );
  // }
}

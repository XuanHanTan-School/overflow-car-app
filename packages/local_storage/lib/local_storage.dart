import 'package:overflow_car_api/overflow_car.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const carsKey = "cars";
  static const selectedCarIndexKey = "selectedCarIndex";

  static Future<List<Car>> getCars() async {
    final prefs = await SharedPreferences.getInstance();
    final carJsons = prefs.getStringList(carsKey) ?? [];
    final cars =
        carJsons.map((eachCarJson) => Car.fromJson(eachCarJson)).toList();
    return cars;
  }

  static Future<void> storeCar(Car car) async {
    final prefs = await SharedPreferences.getInstance();
    final cars = await getCars();
    cars.add(car);
    final carJsons = cars.map((eachCar) => eachCar.toJson()).toList();
    await prefs.setStringList(carsKey, carJsons);
  }

  static Future<void> removeCar(Car car) async {
    final prefs = await SharedPreferences.getInstance();
    final cars = await getCars();
    cars.removeWhere((eachCar) => eachCar.name == car.name);
    final carJsons = cars.map((eachCar) => eachCar.toJson()).toList();
    await prefs.setStringList(carsKey, carJsons);
  }

  static Future<int?> getSelectedCarIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(selectedCarIndexKey);
  }

  static Future<void> setSelectedCarIndex(int? selectedCarIndex) async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedCarIndex == null) {
      await prefs.remove(selectedCarIndexKey);
    } else {
      await prefs.setInt(selectedCarIndexKey, selectedCarIndex);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

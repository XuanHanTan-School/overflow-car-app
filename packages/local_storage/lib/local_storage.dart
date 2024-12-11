import 'package:overflow_car_api/overflow_car.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const key = "cars";

  Future<List<Car>> getCars() async {
    final prefs = await SharedPreferences.getInstance();
    final carJsons = prefs.getStringList(key) ?? [];
    final cars = carJsons.map((eachCarJson) => Car.fromJson(eachCarJson)).toList();
    return cars;
  }

  Future<void> storeCar(Car car) async {
    final prefs = await SharedPreferences.getInstance();
    final cars = await getCars();
    cars.add(car);
    final carJsons = cars.map((eachCar) => eachCar.toJson()).toList();
    await prefs.setStringList(key, carJsons);
  }
}
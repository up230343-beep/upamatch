import 'profile.dart';

/// Filtros de la hoja "Filtros" de Explorar.
///
/// El tipo de perfil (Personas / Perros / Gatos) se elige en la barra de
/// píldoras; aquí solo van distancia y edad.
class ExploreFilters {
  const ExploreFilters({
    this.maxDistanceKm = defaultMaxDistanceKm,
    this.minAge = ageLimitMin,
    this.maxAge = ageLimitMax,
  });

  static const double defaultMaxDistanceKm = 50;
  static const int ageLimitMin = 0;
  static const int ageLimitMax = 60;

  final double maxDistanceKm;
  final int minAge;
  final int maxAge;

  bool get isDefault =>
      maxDistanceKm == defaultMaxDistanceKm &&
      minAge == ageLimitMin &&
      maxAge == ageLimitMax;

  bool matches(Profile profile) =>
      profile.distanceKm <= maxDistanceKm &&
      profile.age >= minAge &&
      profile.age <= maxAge;

  ExploreFilters copyWith({double? maxDistanceKm, int? minAge, int? maxAge}) {
    return ExploreFilters(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
    );
  }
}

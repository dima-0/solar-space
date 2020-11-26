part of solarspace;

/// Die Klasse [Obstacle] erweitert [StaticObject].
/// Objekte vom Typ [Obstacle] befinden sich über das ganze Spiel
/// auf einer festen Position. 
/// 
/// Dem [Playership] wird ein Lebenspunkt abgezogen, falls er mit [Obstacle]
/// kollidiert. Das [Projectile] wird bei einer Kollision komplett zestört.
class Obstacle extends StaticObject{

  /// Konstruktor
  /// 
  /// [id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  /// 
  /// [rotation] Startrotation.
  Obstacle(String id, Vector2 position, Vector2 collisionBoxSize, Level level, Vector2 rotation) : 
  super(id, position, collisionBoxSize, level, rotation);

  @override
  void actionOnCollide(LevelObject other) {}

  @override
  LevelObject clone() {
    return Obstacle(
      id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level, 
      Vector2.copy(rotation));
  }
}
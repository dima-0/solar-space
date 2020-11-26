part of solarspace;

/// Die abstrakte Klasse [MoveableObject] erweitert das [LevelObject]
/// um weiteres Verhalten, die Bewegung.
/// 
/// @Author Dmitrij Bauer
abstract class MoveableObject extends LevelObject{
  /// Geschwindigkeitsfaktor, wird bei der Berechnung der neuen Position benötigt.
  double _speed;
  /// Flugrichtung (nicht [rotation], da [rotation] == Blickrichtung),
  /// wird bei der Berechnung der neuen Position benötigt.
  Vector2 _velocity = Vector2.zero();
  
  /// Konstruktor.
  /// 
  /// [id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  /// 
  /// [_speed] Geschwindigkeitsfaktor.
  /// 
  /// [lifepoints] Maximale Anzahl der Lebenspunkte.
  /// 
  /// [rotation] Startrotation.
  MoveableObject(String id, Vector2 position, Vector2 collisionBoxSize, Level level, this._speed, int lifepoints, Vector2 rotation) : 
  super(id, position, collisionBoxSize, level, lifepoints, rotation);

  /// Liefert den Geschwindgkeitsfaktor.
  double get speed => this._speed;

  /// Liefert die aktuelle Flugrichtung.
  Vector2 get velocity => this._velocity;

  /// Setzt [vel] als aktulle Flugrichtung.
  set velocity (Vector2 vel) => this._velocity = Vector2.copy(vel);

  @override
  void move({double dx, double dy, pxPerFrame}){
    _updatePosition(dx: dx, dy: dy, pxPerFrame: pxPerFrame);
    if(collisionCircle.top < 0) {
      position.y = collisionCircle.radius;
      actionOnCollideWithWall("TOP");
    }
    if(collisionCircle.left < 0) {
      position.x = collisionCircle.radius;
      actionOnCollideWithWall("LEFT");
    }
    if(collisionCircle.bottom > level.gameSize.y) {
      position.y = level.gameSize.y - collisionCircle.radius;
      actionOnCollideWithWall("BOTTOM");
    }
    if(collisionCircle.right > level.gameSize.x) {
      position.x = level.gameSize.x - collisionCircle.radius;
      actionOnCollideWithWall("RIGHT");
    }
    collisionCircle.position.setFrom(position);
  }

  /// Definiert ein Verhalten bei Kollision mit dem Spielfeldrand, wobei
  /// [wall] die Richtung {TOP, BOTTOM, LEFT, RIGHT} liefert, wo sich der Rand befindet
  /// (Muss von Unterklassen überschrieben werden).
  void actionOnCollideWithWall(String wall){}
}
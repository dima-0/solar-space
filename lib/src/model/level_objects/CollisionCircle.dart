part of solarspace;

/// Eine kreisförmige Hitbox, die für Kollisionsberechnungen verwendet wird.
/// 
/// @Author Dmitrij Bauer
class CollisionCircle{
  /// Aktuelle Position des Mittelpunktes vom [CollisionCircle].
  Vector2 _position;
  /// Größe der Hitbox (x: Breite / y: Höhe), da es sich um eine Kreis handelt
  /// => x = y (dabei ist y der Durchmesser des Kreises).
  Vector2 _size;

  /// Konstruktor.
  /// 
  /// [_position] Position des Mittelpunktes der Hitbox.
  /// [_size] Größe der Hitbox (x: Breite / y: Höhe).
  CollisionCircle(this._position, this._size);

  /// Aktuelle Position des Mittelpunktes vom [CollisionCircle].
  Vector2 get position => this._position;

  /// Setzt die aktuelle Position des Mittelpunktes vom [CollisionCircle].
  set position(Vector2 newPos) => this._position;

  /// Größe der Hitbox (x: Breite / y: Höhe), da es sich um eine Kreis handelt
  /// => x = y (dabei ist y der Durchmesser des Kreises).
  Vector2 get size => this._size;

  /// Setzt die Größe der Hitbox (x: Breite / y: Höhe) vom [CollisionCircle].
  set size(Vector2 size) => this._size;

  /// Liefert den Radius von [CollisionCircle].
  double get radius => this._size.y / 2;

  /// Liefert die Breite von [CollisionCircle].
  double get width => this._size.x;

  /// Liefert die Höhe von [CollisionCircle].
  double get height => this._size.y;

  /// Liefert die Position des oberen Punktes von [CollisionCircle].
  double get top => position.y - radius;

  /// Liefert die Position des unteren Punktes von [CollisionCircle].
  double get bottom => position.y + radius;

  /// Liefert die Position des linken Punktes von [CollisionCircle].
  double get left => position.x - radius;

  /// Liefert die Position des rechten Punktes von [CollisionCircle].
  double get right => position.x + radius;

  /// Prüft ob [this] mit [other] kollidiert.
  bool isCollidingWith(CollisionCircle other){
    double distance = (other.position - this.position).length;
    return distance <= (this.radius + other.radius) ? true : false;
  }

  /// Prüft, ob [this] mit [other] kollidiert.
  /// Falls eine Kollision stattfindet, dann Liefert diese Methode einen
  /// [Vector2], der Kollision korrigieren soll.
  /// Andernfalls liefert diese Methode einen Nullvektor (0,0).
  Vector2 resolveCollision(CollisionCircle other){
    Vector2 direction = (this.position - other.position);
    double correctionDistance = (this.radius + other.radius) -  direction.length;
    direction.normalize();
    direction.scale(correctionDistance <= 0 ? 0 : correctionDistance);
    return direction;
  }
}
part of solarspace;

/// @Author Tobias Guenther
/// Diese Klasse beschreibt einen Asteroiden, der sich  im Spielverlauf  ueber das Spielfeld bewegt.
class Asteroid extends MoveableObject{

  /// Konstruktor.
  /// [id] Die ID soll folgender Form haben: <prefix>_<id> (nicht null).
  /// [position] Startposition des Mittelpunktes (nicht null).
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe (nicht null).
  /// [level] Levelinstanz, die dem [Asteroid] zugewiesen werden soll (nicht null).
  /// [speed] Geschwindigkeit des Asteroiden.
  /// [rotation] Startrotation (nicht null).
  Asteroid(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, Vector2 rotation) : 
  super(id, position, collisionBoxSize, level, speed, 0, rotation);

  @override
  void _updatePosition({double dx, double dy, double pxPerFrame = 1}){
    velocity = Vector2.copy(rotation);
    velocity.normalize();
    velocity.scale(pxPerFrame * speed);
    position += velocity;
    collisionCircle.position.setFrom(position);
  }

  @override
  void actionOnCollide(LevelObject other) {
    if (other is Spaceship || other is Projectile) this._isActive = false;
  }

  @override
  void actionOnCollideWithWall(String wall) {
    switch (wall) {
    case "TOP":
      this._rotation.y *= -1;
      break;
    case "RIGHT": 
      this._rotation.x *= -1;
      break;
    case "BOTTOM":
      this._rotation.y *= -1;
      break;
    case "LEFT":
      this._rotation.x *= -1;
      break;
    default:
      
      break;
    }
  }

  @override
  void decreaseLifepointsBy(int number) {}

   @override
  void increaseLifepointsBy(int number){}

  @override
  void move({double dx, double dy, pxPerFrame}){
    super.move(pxPerFrame: pxPerFrame);
    List<LevelObject> list = List();
    list.add(level.playerCharacter);
    for (LevelObject other in list) {
      if(other.isActive && other != this){
        if(this.collisionCircle.isCollidingWith(other.collisionCircle))  {
          this.actionOnCollide(other);
          other.actionOnCollide(this);
        }
      }
    }
  }

  @override
  LevelObject clone() {
    return Asteroid(
      id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level, speed, 
      Vector2.copy(rotation));
  }
}
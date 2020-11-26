part of solarspace;

/// Die Klasse [Projectile] erweitert [MoveableObject].
/// 
/// @Author Dmitrij Bauer
class Projectile extends MoveableObject{
  /// Erzeuger von [this].
  Spaceship _owner;

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
  /// [rotation] Startrotation.
  Projectile(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, this._owner, Vector2 rotation) : 
  super(id, position, collisionBoxSize, level, speed, 0, rotation){
    velocity = rotation.scaled(speed);
  }
  
  @override
  void _updatePosition({double dx, double dy, double pxPerFrame = 1}){
    velocity.normalize();
    velocity.scale(pxPerFrame * speed);
    position += velocity;
    collisionCircle.position.setFrom(position);
  }

  @override
  void actionOnCollide(LevelObject other) {
    if(other != _owner)_isActive = false;
  }

  @override
  void decreaseLifepointsBy(int number) {}

   @override
  void increaseLifepointsBy(int number){}

  @override
  void move({double dx, double dy, pxPerFrame}){
    super.move(pxPerFrame: pxPerFrame);
    String type = _owner.id.contains("player") ? "enemy" : "player";
    List<LevelObject> list = level.staticObjects + level.asteroids + level.getFilteredProjectiles(owner: type);
    for (LevelObject item in list) {
      if(item.isActive && item != this && this.collisionCircle.isCollidingWith(item.collisionCircle)){
        this.actionOnCollide(item);
        item.actionOnCollide(this);
      }
    } 
  }

  @override
  LevelObject clone() {
    return Projectile(
      id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level, speed, _owner, 
      Vector2.copy(rotation));
  }

  @override
  void actionOnCollideWithWall(String wall) {
    _isActive = false;
  }
}
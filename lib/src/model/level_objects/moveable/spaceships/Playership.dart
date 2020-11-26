part of solarspace;

/// Die Klasse [Playership] erweitert [Spaceship]
/// um ein weiteres Verhalten, die Unverwundbarkeit.
/// Zudem wird die neue Position in [Playership._updatePosition]
/// anders berechnet als bei den [LevelObject], die von der KI gesteuert werden.
/// 
/// Hier handelt es sich um ein [LevelObject], welcher vom Benutzer gesteuert wird.
/// 
/// @Author Dmitrij Bauer
class Playership extends Spaceship{
  final int INVULNERABILITY_INTERVALL = 1000;
  int currentInvulnerabilityDuration;

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
  /// [speed] Geschwindigkeitsfaktor.
  /// 
  /// [lifepoints] Maximale Anzahl der Lebenspunkte.
  /// 
  /// [rotation] Startrotation.
  /// 
  /// [projectileSpeed] Geschwindigkeitsfaktor der [Projectile].
  /// 
  /// [projectileScale] Skalierungfaktor für [Projectile] Größe. 
  /// 
  /// [reloadTime] Maximale Nachladezeit in ms.
  Playership(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, int lifepoints, Vector2 rotation, double projectileSpeed, double projectileScale, int reloadTime) : 
  super(id, position, collisionBoxSize, level, speed, lifepoints, rotation, projectileSpeed, projectileScale, reloadTime){
    currentInvulnerabilityDuration = INVULNERABILITY_INTERVALL;
  }

  @override
  void _updatePosition({double dx = 1, double dy = 1, double pxPerFrame = 1}) {
    velocity = Vector2(dx, dy);
    velocity.scale(pxPerFrame * speed);
    position += velocity;
    collisionCircle.position.setFrom(position);
  } 
  
  @override
  void actionOnCollide(LevelObject other) {
    if(!other.id.contains("powerup") && !isInvulnerable){
      decreaseLifepointsBy(1);
      currentInvulnerabilityDuration = INVULNERABILITY_INTERVALL;
      invulnerabilityTimer.reset();
      invulnerabilityTimer.start();
    }
  }

  @override
  void updateTimer(){
    if(invulnerabilityTimer.isRunning && invulnerabilityTimer.elapsedMilliseconds >= currentInvulnerabilityDuration){
      invulnerabilityTimer.stop();
      invulnerabilityTimer.reset();
    }
    if(reloadTimer.isRunning && _reloadTimer.elapsedMilliseconds >= reloadTime){
      reloadTimer.stop();
      reloadTimer.reset();
    }
  }

  @override
  void move({double dx, double dy, pxPerFrame}){
    super.move(dx: dx, dy: dy, pxPerFrame: pxPerFrame);
    List<LevelObject> list = level.powerups + level.staticObjects + level.getFilteredProjectiles(owner:"enemy");
    Vector2 offset = Vector2(0, 0);
    for (var item in list) {
      if(item.isActive && item != this){
        Vector2 correction = this.collisionCircle.resolveCollision(item.collisionCircle);
        if(correction != Vector2.zero()){
          if(!(item is Powerup)) offset += correction;
          this.actionOnCollide(item);
          item.actionOnCollide(this);
        }
      }
    } 
    position += offset.scaled(1.01);
    collisionCircle.position.setFrom(position);
  }

  @override
  LevelObject clone() {
    return Playership(
      id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level, speed, lifepoints, 
      Vector2.copy(rotation),
      projectileSpeed, projectileScale, reloadTime);
  }

  @override
  void actionOnCollideWithWall(String wall) {}
  
  @override
  void increaseLifepointsBy(int number){
    _lifepoints = min(_maxLifepoints, lifepoints + 1);
  }
}
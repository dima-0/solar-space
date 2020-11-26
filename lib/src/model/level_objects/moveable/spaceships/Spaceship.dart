part of solarspace;

/// Die abstrakte Klasse [Spaceship] erweitert [MoveableObject],
/// um ein weiteres Verhalten, das Verschießen von [Projectile].
/// 
/// @Author Dmitrij Bauer
abstract class Spaceship extends MoveableObject{
  /// Geschwindigkeitsfaktor der [Projectile], die verschossen werden.
  double _projectileSpeed;
  /// Skalierungfaktor für [Projectile] Größe. 
  double _projectileScale;
  /// Maximale Nachladezeit in ms.
  int _reloadTime;
  /// Stopuhr, misst die Zeit, die seit dem Abfeuern des [Projectile] vergangen ist.
  Stopwatch _reloadTimer = new Stopwatch();
  
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
  /// 
  /// [_projectileSpeed] Geschwindigkeitsfaktor der [Projectile].
  /// 
  /// [_projectileScale] Skalierungfaktor für [Projectile] Größe. 
  /// 
  /// [_reloadTime] Maximale Nachladezeit in ms.
  Spaceship(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, int lifepoints, Vector2 rotation, this._projectileSpeed, this._projectileScale, this._reloadTime) : 
  super(id, position, collisionBoxSize, level, speed, lifepoints, rotation);

  /// Liefert den Geschwindigkeitsfaktor der [Projectile].
  double get projectileSpeed => this._projectileSpeed;

  /// Liefert den Skalierungfaktor für [Projectile] Größe. 
  double get projectileScale => this._projectileScale;

  /// Liefert die maximale Nachladezeit.
  int get reloadTime => this._reloadTime;

  /// Liefert die Stopuhr, die die Zeit misst, die seit dem Abfeuern des [Projectile] vergangen ist.
  Stopwatch get reloadTimer => this._reloadTimer;

  @override
  void pause(){
    reloadTimer.stop();
    invulnerabilityTimer.stop();
  }

  @override
  void resume(){
    if(reloadTimer.elapsedMilliseconds > 0) _reloadTimer.start();
    if(invulnerabilityTimer.elapsedMilliseconds > 0) invulnerabilityTimer.start();
  }
  
  /// Erzeugt ein [Projectile] mit [Projectile.position] == [this.position] der Größe
  /// [this.collisionCircle.size] * [projectileScale].
  /// Das Projektile ist in Richtung [dest] gerichtet.
  void shoot(Vector2 dest){
    if(!reloadTimer.isRunning){
      Vector2 size = Vector2.copy(collisionCircle.size);
      size.scale(projectileScale);
      Vector2 projectilePosition = Vector2.copy(position);
      Vector2 rot = dest - position;
      String projectileID = LevelObject.generateValidId(level.projectiles, "projectile");
      LevelObject projectile = Projectile(projectileID, projectilePosition, size, level, projectileSpeed, this, rot);
      level.projectiles.add(projectile);
      reloadTimer.reset();
      reloadTimer.start();  
    }
  }

  @override
  void decreaseLifepointsBy(int number){
    _lifepoints = max(0, (_lifepoints - number));
    if(lifepoints == 0) _isActive = false; 
  }

  @override
  void increaseLifepointsBy(int number){}

  @override
  void stop(){
    reloadTimer.stop();
  }
}
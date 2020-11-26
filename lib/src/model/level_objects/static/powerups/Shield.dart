part of solarspace;

/// Die Klasse [Shield] erweitert [Powerup].
/// [Shield] verleiht dem [Playership] für [Shield.DURATION] ms Unverwundbarkeit, d.h. [Playership]
/// kann keinen Schaden nehmen während der Effekt aktiv ist.
/// 
/// @Author Dmitrij Bauer
class Shield extends Powerup{
  /// Dauer des Effektes in ms.
  final DURATION = 10000;

  /// Konstruktor.
  /// 
  /// [id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  Shield(String id, Vector2 position, Vector2 collisionBoxSize, Level level) : 
  super(id, position, collisionBoxSize, level);

  @override
  void effect(Playership player) {
    if(player.isInvulnerable) {
      player.invulnerabilityTimer.stop();
      player.invulnerabilityTimer.reset();
    }
    player.currentInvulnerabilityDuration = DURATION;
    player.invulnerabilityTimer.start();
  }

  @override
  void actionOnCollide(LevelObject other) {
    if(other is Playership){
      effect(other);
      _isActive = false;
    } 
  }

  @override
  LevelObject clone() {
    return Shield(id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level);
  }

  
}
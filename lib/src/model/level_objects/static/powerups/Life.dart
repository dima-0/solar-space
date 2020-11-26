part of solarspace;

/// Die Klasse [Life] erweitert [Powerup].
/// [Life] regeneriert [Life.LIFEPOINTS] der Lebenspnkte beim [Playership], falls
/// die maximale Anzahl noch nicht erreicht wurde.
/// 
/// @Author Dmitrij Bauer
class Life extends Powerup {
  final LIFEPOINTS = 1;
  
  Life(String id, Vector2 position, Vector2 collisionBoxSize, Level level) : 
  super(id, position, collisionBoxSize, level);

  @override
  void effect(Playership player) {
    player.increaseLifepointsBy(LIFEPOINTS);
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
    return Life(id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level);
  }
}
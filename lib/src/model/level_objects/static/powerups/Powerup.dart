part of solarspace;

/// Die abstrakte Klasse [Powerup] erweitert [StaticObject]
/// und soll dem Spieler [Playership] einen Vorteil im Spiel verschaffen.
/// 
/// @Author Dmitrij Bauer
abstract class Powerup extends StaticObject{

  /// Konstruktor
  /// 
  /// [id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  Powerup(String id, Vector2 position, Vector2 collisionBoxSize, Level level) : 
  super(id, position, collisionBoxSize, level, Vector2.zero());

  /// Powerup-Factory.
  /// 
  /// [type] Der konkrete Typ des Objektes der zurückgegeben werden soll
  /// ('shield' => [Shield] / 'life' => [Life] / sonst => null)
  /// 
  /// [id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  factory Powerup.fromType(String type, String id, Vector2 position, Vector2 collisionBoxSize, Level level){
    switch (type) {
      case "life":
        return Life(id, position, collisionBoxSize, level);
        break;
       case "shield":
        return Shield(id, position, collisionBoxSize, level);
        break;  
      default:
        return null;
    }
  }

  /// Löst einen positiven Effekt beim [player] aus.
  void effect(Playership player);
}
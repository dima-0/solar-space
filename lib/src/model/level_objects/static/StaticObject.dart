part of solarspace;

/// Die abstrakte Klasse [StaticObject] erweitert [LevelObject].
/// Objekte dieses Typs befinden sich über das ganze Spiel auf einer 
/// festen Position.
/// 
/// @Author Dmitrij Bauer
abstract class StaticObject extends LevelObject{

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
  StaticObject(String id, Vector2 position, Vector2 collisionBoxSize, Level level, Vector2 rotation) : 
  super(id, position, collisionBoxSize, level, 0, rotation);
  
  @override
  void move({double dx, double dy, pxPerFrame}){}

  @override
  void decreaseLifepointsBy(int number){}

  @override
  void increaseLifepointsBy(int number){}

  @override
  void _updatePosition({double dx, double dy, double pxPerFrame}){}
}

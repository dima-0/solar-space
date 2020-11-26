part of solarspace;

/// Zustand vom [GameManager].
/// 
/// @Author Dmitrij Bauer
enum State{
  /// Spiel pausiert, d.h. Model soll nicht
  /// weiter aktualisiert werden.
  PAUSED,
  /// Spiel läuft, d.h. Model wird ständig aktualisiert.
  RUNNING,
  /// Spiel ist beendet, d.h. Model wird nicht mehr aktualisiert.
  FINISHED,
  /// GameManager ist bereit ein neues Spiel zu starten.
  READY_TO_RUN
}

/// Verwaltet ein laufendes [Level], während ein Spiel läuft.
/// 
/// @Author Dmitrij Bauer
class GameManager{
  /// Der aktuelle Zustand vom [GameManager].
  State state = State.READY_TO_RUN;
  /// Das aktuell aktive [Level].
  Level _activeLevel;
  /// Stopuhr mit der aktuellen Spielzeit.
  Stopwatch _stopwatch = new Stopwatch();
  /// Spawn-Trigger für [Powerup].
  Timer _powerupSpawnTrigger;

  /// Konstruktor.
  GameManager();

  /// Liefert die aktuell ausgeführte Instanz vom [Level].
  Level get activeLevel => this._activeLevel;

  /// Startet das [level].
  /// Dabei wechselt der [GameManager] in den Zustand [State.RUNNING], der Spawn-Trigger für [Powerup]
  /// wird initialisiert und die Stopuhr gestartet.
  /// 
  /// [level] Level, welches gestartet werden soll (nicht null).
  void startLevel(Level level){
    this._activeLevel = level;
    stopwatch.reset();
    stopwatch.start();
    state = State.RUNNING;
    powerupSpawnTrigger = Timer.periodic(Duration(seconds: activeLevel.powerupSpawnInterval), (spawn){
      if(state == State.RUNNING && 
        activeLevel.powerups.length < activeLevel.maxPowerups){
        LevelObject powerup = _getPowerup();
        if(powerup != null) activeLevel.powerups.add(powerup);
      }
    });
  }

  /// Pausiert das Spiel, dabei werden alle [LevelObject] pausiert und der Zustand
  /// vom [GameManager] wechselt auf [State.PAUSED].
  void pauseGame(){
    if(state == State.RUNNING){
      activeLevel.allLevelObjects.forEach((o) => o.pause());
      state = State.PAUSED;
      stopwatch.stop();
    }
  }

  /// Setzt das Spiel wieder fort, dabei werden alle [LevelObject] ebenfalls fortgesetzt
  /// und der Zustand vom [GameManager] wechselt auf [State.RUNNING].
  void resumeGame(){
    if(state == State.PAUSED){
      activeLevel.allLevelObjects.forEach((o) => o.resume());
      state = State.RUNNING;
      stopwatch.start();
    }
  }

  /// Stopuhr mit der aktuellen Spielzeit.
  Stopwatch get stopwatch => this._stopwatch;

  /// Spawn-Trigger für [Powerup].
  Timer get powerupSpawnTrigger => this._powerupSpawnTrigger;

  /// Setzt den Spawn-Trigger für [Powerup].
  set powerupSpawnTrigger(Timer timer) => this._powerupSpawnTrigger = timer;

  /// Bewegt alle [LevelObject] in [Level], Prüft ob das Spiel
  /// beendet werden muss und entfernt alle inaktiven [LevelObject]
  /// aus dem [Level].
  /// 
  /// [dx] (Optional) x-Offset, um welchen die Position auf der x-Achse verschoben werden soll.
  /// 
  /// [dy] (Optional) y-Offset, um welchen die Position auf der y-Achse verschoben werden soll.
  /// 
  /// [fps] Anzahl der Updates der letzten Sekunde.
  void tick(double dx, double dy, double fps){
    // Anzahl der Pixel für den aktuellen Frame
    // skaliert mit der Spielfeldgröße und der Anzahl der Updates [fps] der letzten Sekunde.
    // Je höher [fps] desto weniger Pixel müssen zurückgelegt werden (da mehr Updates stattfinden)
    // Je größer die Spielfeldgröße desto mehr Pixel müssen zurückgelegt werden.
    double pxPerFrame = _calcPixelPerFrame(fps);
    // Spieler bewegen
    activeLevel.playerCharacter.move(dx: dx, dy: dy, pxPerFrame: pxPerFrame);
    activeLevel.playerCharacter.updateTimer();
    // KI LevelObejkte bewegen
    for(LevelObject levelObject in activeLevel.moveableObjects){
      if(levelObject.isActive){
        levelObject.move(pxPerFrame: pxPerFrame);
      }
      levelObject.updateTimer();
    }

    // Niederlage
    if(!activeLevel.playerCharacter.isActive || elapsedTimeSec >= 300){
      state = State.FINISHED;
      stopwatch.stop();
      stopwatch.reset();
      return;
    }
    // Inaktive Projektile entfernen
    activeLevel.projectiles.removeWhere((o) => !o.isActive);
    activeLevel.powerups.removeWhere((o) => !o.isActive);
    activeLevel.asteroids.removeWhere((o) => !o.isActive);
    activeLevel.enemies.removeWhere((o) => !o.isActive);
    
    // Sieg
    if(activeLevel.enemies.isEmpty){
      state = State.FINISHED;
      stopwatch.stop();
    }
  }

  /// Liefert die Anzahl der Pixel, die bei diesem Update zurückgelegt werden müssen.
  /// 
  /// Rechnung: min(Breite, Höhe) / Anzahl der Updates der letzen Sekunde
  /// 
  /// [fps] Anzahl der Updates der letzten Sekunde.
  double _calcPixelPerFrame(double fps) => min(activeLevel.gameSize.x, activeLevel.gameSize.y) / (fps == 0 ? 1 : fps);

  /// Setzt den [GameManager] zurück, dabei werden alle [LevelObject] gestoppt und der [GameManager]
  /// übergeht in den Zustand [State.READY_TO_RUN].
  void reset(){
    activeLevel.allLevelObjects.forEach((o) => o.stop());
    _activeLevel = null;
    powerupSpawnTrigger.cancel();
    stopwatch.reset();
    state = State.READY_TO_RUN;
  }

  /// Liefert True, falls der [GameManager] sich im Zustand [State.FINISHED] befindet
  /// und die gemessene Zeite > 0 ist.
  /// Bei einer Niederlage wird bereits in [GameManager.tick] die Stopuhr zurückgesetzt.
  bool isVictory() => state == State.FINISHED && elapsedTimeSec > 0;

  /// Liefert die aktuelle Zeit als String im Format mm:ss.
  String get elapsedTime {
    Duration duration = Duration(milliseconds: stopwatch.elapsedMilliseconds);
    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds % 60).toInt();
    return "${minutes}:${seconds < 10 ? '0' : ''}${seconds}";
  }

  /// Liefert die aktuelle Zeit in Sekunden.
  int get elapsedTimeSec{
    Duration duration = Duration(milliseconds: stopwatch.elapsedMilliseconds);
    return duration.inSeconds;
  }

  /// Liefert ein zufälliges [Powerup].
  /// Im Auswahlpool befinden sich [Powerup], die
  /// in [Level.possiblePowerups] definiert sind. Alle möglichen [Powerup]
  /// haben dieselbe Spawn-Wahrscheinlichkeit.
  /// 
  /// Das [Powerup] spawnt auf einer zufälligen Position auf dem Spielfeld. Die Größe beträgt 30% des [Playership].
  /// Falls keine gültige Position auf gefunden wurde Liefert diese Methode null.
  LevelObject _getPowerup(){
    LevelObject powerup;
    Vector2 size = activeLevel.playerCharacter.collisionCircle.size * 0.3;
    Vector2 randomPos = LevelObject.generateRandomPosition((activeLevel.staticObjects + activeLevel.powerups), activeLevel.gameSize, size, player: activeLevel.playerCharacter, distanceToPlayer: 3);
    if(randomPos != null){
      Random rand = Random();
      String prefix = activeLevel.possiblePowerups[rand.nextInt(activeLevel.possiblePowerups.length)];
      String id = LevelObject.generateValidId(activeLevel.powerups, "powerup-${prefix}");
      powerup = Powerup.fromType(prefix, id, randomPos, size, activeLevel);
    }
    return powerup;
  }
  
}
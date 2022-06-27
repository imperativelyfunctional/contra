import 'package:contra/constructions/bridge.dart';
import 'package:contra/events/event.dart';
import 'package:contra/player/player.dart';
import 'package:contra/wall/wall.dart';
import 'package:event/event.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiled/tiled.dart' show ObjectGroup;

const worldWidth = 3327.0;
const worldHeight = 240.0;
const viewPortHeight = 240.0;
const viewPortWidth = 256.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  var contra = Contra()
    ..camera.viewport =
        FixedResolutionViewport(Vector2(viewPortWidth, viewPortHeight));
  runApp(GameWidget(game: contra));
}

final keyEvents = Event<KeyEventArgs>();
final touchWaterEvents = Event<TouchWallArgs>();
final touchWallEvents = Event<TouchWallArgs>();
final inAirEvents = Event<InAirArgs>();
final spawnEvents = Event();

class Contra extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late Timer cameraTimer;
  late Lance player;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var map = await TiledComponent.load('map.tmx', Vector2.all(16));
    add(map);
    for (var object
        in map.tileMap.getLayer<ObjectGroup>('collisions')!.objects) {
      add(Wall(WallType.fromString(object.type),
          position: Vector2(object.x, object.y),
          size: Vector2(object.width, object.height)));
    }
    add(Bridge()
      ..position = Vector2(768, 113)
      ..size = Vector2(32 * 4, 32 * 4));
    add(Bridge()
      ..position = Vector2(1024, 113)
      ..size = Vector2(32 * 4, 32 * 4));
    player = Lance(
      'player.png',
      position: Vector2(30, 0),
      size: Vector2(41, 42),
    );
    await add(player);

    Sprite life = await loadSprite('life.png', srcSize: Vector2(8, 16));
    add(SpriteComponent(sprite: life, position: Vector2(20, 0))
      ..positionType = PositionType.viewport);
    add(SpriteComponent(sprite: life, position: Vector2(35, 0))
      ..positionType = PositionType.viewport);
    add(SpriteComponent(sprite: life, position: Vector2(50, 0))
      ..positionType = PositionType.viewport);
    add(SpriteComponent(sprite: life, position: Vector2(65, 0))
      ..positionType = PositionType.viewport);

    Sprite logo =
        await loadSprite('contra_logo.png', srcSize: Vector2(191, 79));

    add(SpriteComponent(
        sprite: logo,
        anchor: Anchor.topCenter,
        position: Vector2(viewPortWidth / 2, 0),
        size: Vector2(191, 79) / 4)
      ..positionType = PositionType.viewport);
    add(ScreenHitbox());
    spawnEvents.subscribe((args) {
      player = Lance(
        'player.png',
        position: Vector2(camera.position.x + 30, 0),
        size: Vector2(41, 42),
      );
      add(player);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    var cameraXPos = camera.position.x;
    if (cameraXPos < worldWidth - viewPortWidth) {
      camera.followComponent(player,
          worldBounds: Rect.fromLTWH(
              cameraXPos, 0, worldWidth - cameraXPos, worldHeight));
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    {
      if (keysPressed.isNotEmpty) {
        for (var element in keysPressed) {
          keyEvents.broadcast(KeyEventArgs(element, true));
        }
      }

      if (event is RawKeyUpEvent) {
        keyEvents.broadcast(KeyEventArgs(event.logicalKey, false));
      }
      return super.onKeyEvent(event, keysPressed);
    }
  }
}

import 'dart:async';

import 'package:contra/player/player_states.dart';
import 'package:contra/wall/wall.dart';
import 'package:flame/components.dart' hide Timer;

import '../player/player.dart';

class Bridge extends PositionComponent {
  bool _exploded = false;

  Bridge();

  @override
  Future<void>? onLoad() {
    var cellSize = Vector2(32, 32);
    var leftBridge = DestructibleBridge('bridge.png', Vector2.zero(),
        position: Vector2.zero(), size: cellSize);
    var middleBridge = DestructibleBridge('bridge.png', Vector2(32, 0),
        position: Vector2(32, 0), size: cellSize);
    var middle2Bridge = DestructibleBridge('bridge.png', Vector2(32 * 2, 0),
        position: Vector2(32 * 2, 0), size: cellSize);
    var rightBridge = DestructibleBridge('bridge.png', Vector2(32 * 3, 0),
        position: Vector2(32 * 3, 0), size: cellSize);
    add(leftBridge);
    add(middleBridge);
    add(middle2Bridge);
    add(rightBridge);

    playerInfoEvents.subscribe((args) {
      var hitBox = hitBoxes[args!.playerState];
      if (!_exploded &&
          args.playerState != PlayerStates.leftUnderWater &&
          args.playerState != PlayerStates.rightUnderWater &&
          args.position.x + hitBox![0].x + hitBox[1].x >= position.x) {
        _exploded = true;
        Timer(const Duration(milliseconds: 100), () {
          leftBridge.explode();
        });
        Timer(const Duration(milliseconds: 500), () {
          middleBridge.explode();
        });
        Timer(const Duration(milliseconds: 900), () {
          middle2Bridge.explode();
        });
        Timer(const Duration(milliseconds: 1300), () {
          rightBridge.explode();
        });
        Timer(const Duration(milliseconds: 1700), () {
          removeFromParent();
        });
      }
    });
    return super.onLoad();
  }
}

class DestructibleBridge extends SpriteComponent with HasGameRef {
  final String path;
  final Vector2 srcPosition;
  late Wall _wall;

  DestructibleBridge(
    this.path,
    this.srcPosition, {
    super.position,
    super.size,
  });

  @override
  Future<void>? onLoad() async {
    var position = Vector2(0, 7) + (parent as Bridge).position + srcPosition;
    _wall = Wall(WallType.bridge, position: position, size: Vector2(32, 9));
    gameRef.add(_wall);
    sprite = await gameRef.loadSprite(path,
        srcSize: Vector2(32, 32), srcPosition: srcPosition);
    return super.onLoad();
  }

  void explode() async {
    gameRef.remove(_wall);
    add(SpriteAnimationComponent(
        animation: await gameRef.loadSpriteAnimation(
          path,
          SpriteAnimationData.sequenced(
            amount: 3,
            textureSize: Vector2(32, 32),
            texturePosition: Vector2(0, 32),
            stepTime: stepTimeFast15,
            loop: false,
          ),
        ),
        removeOnFinish: true,
        size: Vector2(32, 32),
        position: Vector2.zero()));
    Timer(const Duration(milliseconds: 200), () {
      removeFromParent();
    });
  }
}

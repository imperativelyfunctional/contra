import 'package:contra/player/player_states.dart';
import 'package:event/event.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../wall/wall.dart';

class KeyEventArgs extends EventArgs {
  final LogicalKeyboardKey key;
  final bool pressed;

  KeyEventArgs(this.key, this.pressed);
}

class TouchWallArgs extends EventArgs {
  final bool touching;
  final WallType wallType;
  final Vector2 wallPosition;

  TouchWallArgs(this.touching, this.wallType, this.wallPosition);
}

class InAirArgs extends EventArgs {
  final bool inAir;

  InAirArgs(this.inAir);
}

class PlayerInfoArgs extends EventArgs {
  final Vector2 position;
  final PlayerStates playerState;

  PlayerInfoArgs(this.position, this.playerState);
}

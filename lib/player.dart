import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/particles.dart' as fp;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'main.dart';

enum PlayerDirection {
  up,
  down,
  left,
  right,
}

class Player extends BodyComponent {
  final Vector2 position;
  late PlayerSprite playerSprite;

  Player(this.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    playerSprite = PlayerSprite(size: Vector2(48, 48) / scaleFactor)
      ..anchor = Anchor.center;
    add(playerSprite);
    body.setFixedRotation(true);
  }

  @override
  Body createBody() {
    var bodyDef = BodyDef();
    bodyDef.position.setFrom(position);
    bodyDef.type = BodyType.dynamic;

    var bodyFixtureDef = FixtureDef(PolygonShape()
      ..setAsBox(
          8 / scaleFactor, 9 / scaleFactor, Vector2(0, 0) / scaleFactor, 0))
      ..restitution = 0
      ..friction = 0
      ..density = 0;
    var body = world.createBody(bodyDef);
    body.createFixture(bodyFixtureDef);
    return body;
  }

  @override
  void update(double dt) async {
    super.update(dt);
    var linearVelocity = body.linearVelocity;
    var horizontalVelocity = linearVelocity.x;
    var verticalVelocity = linearVelocity.y;
    if (horizontalVelocity > 0) {
      await _addFollowers(PlayerDirection.right);
    }
    if (horizontalVelocity < 0) {
      await _addFollowers(PlayerDirection.left);
    }
    if (verticalVelocity > 0) {
      await _addFollowers(PlayerDirection.down);
    }
    if (verticalVelocity < 0) {
      await _addFollowers(PlayerDirection.up);
    }
  }

  _addFollowers(PlayerDirection direction) async {
    final Sprite sprite;
    switch (direction) {
      case PlayerDirection.down:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 0), srcSize: Vector2(48, 48));
          break;
        }
      case PlayerDirection.up:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48), srcSize: Vector2(48, 48));
          break;
        }
      case PlayerDirection.left:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48 * 2), srcSize: Vector2(48, 48));
          break;
        }
      default:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48 * 2), srcSize: Vector2(48, 48));
          break;
        }
    }
    sprite.paint = Paint()
      ..color = Colors.amber.withOpacity(0.4)
      ..blendMode = BlendMode.darken;

    gameRef.add(
        ParticleSystemComponent(particle: trailParticles(sprite, direction))
          ..position = body.position);
  }

  fp.Particle trailParticles(Sprite sprite, PlayerDirection direction) {
    const count = 3;
    const rowHeight = 0.3;
    const columnWidth = 0.3;

    return fp.Particle.generate(
      count: count,
      lifespan: 0.1,
      generator: (i) => TranslatedParticle(
        offset: Vector2(
          (direction == PlayerDirection.left ||
                  direction == PlayerDirection.right)
              ? (i % count) *
                  columnWidth *
                  ((direction == PlayerDirection.right) ? -1 : 1)
              : 0,
          (direction == PlayerDirection.up || direction == PlayerDirection.down)
              ? (i % count) *
                  rowHeight *
                  ((direction == PlayerDirection.down) ? -1 : 1)
              : 0,
        ),
        child: SpriteParticle(
          size: Vector2(2.8, 3.2),
          sprite: sprite,
        ),
      ),
    );
  }
}

class PlayerSprite extends SpriteAnimationGroupComponent<PlayerDirection>
    with HasGameRef {
  PlayerSprite({
    required Vector2 size,
  }) : super(size: size);

  @override
  Future<void>? onLoad() async {
    anchor = Anchor.center;
    final down = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 0),
        amount: 4,
        textureSize: Vector2(48, 48),
        stepTime: 0.3,
        loop: true,
      ),
    );

    final up = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 48),
        amount: 4,
        textureSize: Vector2(48, 48),
        stepTime: 0.3,
        loop: true,
      ),
    );

    final left = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(48, 48),
        texturePosition: Vector2(0, 96),
        stepTime: 0.3,
      ),
    );

    final right = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(48, 48),
        texturePosition: Vector2(0, 144),
        stepTime: 0.3,
        loop: true,
      ),
    );

    animations = {
      PlayerDirection.up: up,
      PlayerDirection.down: down,
      PlayerDirection.left: left,
      PlayerDirection.right: right,
    };
    current = PlayerDirection.right;
    return super.onLoad();
  }
}

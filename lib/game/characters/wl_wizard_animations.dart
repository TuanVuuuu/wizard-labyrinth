import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../../core/wl_character_constants.dart';

enum WLWizardAnimState { idle, walk, jump }

class WLWizardAnimations {
  WLWizardAnimations._();

  static final Images images = Images(prefix: WLCharacterConstants.assetsPrefix);

  static Future<Map<WLWizardAnimState, SpriteAnimation>> loadAll() async {
    final idleImage = await images.load(WLCharacterConstants.idleSheet);
    final walkImage = await images.load(WLCharacterConstants.walkSheet);
    final jumpImage = await images.load(WLCharacterConstants.jumpSheet);

    final textureSize = Vector2.all(WLCharacterConstants.frameSize);

    return {
      WLWizardAnimState.idle: SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: WLCharacterConstants.idleFrameCount,
          stepTime: WLCharacterConstants.idleStepTime,
          textureSize: textureSize,
        ),
      ),
      WLWizardAnimState.walk: SpriteAnimation.fromFrameData(
        walkImage,
        SpriteAnimationData.sequenced(
          amount: WLCharacterConstants.walkFrameCount,
          stepTime: WLCharacterConstants.walkStepTime,
          textureSize: textureSize,
        ),
      ),
      WLWizardAnimState.jump: SpriteAnimation.fromFrameData(
        jumpImage,
        SpriteAnimationData.sequenced(
          amount: WLCharacterConstants.jumpFrameCount,
          stepTime: WLCharacterConstants.jumpStepTime,
          textureSize: textureSize,
          loop: false,
        ),
      ),
    };
  }
}

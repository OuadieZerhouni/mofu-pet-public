import '../../l10n/app_localizations.dart';
import '../../l10n/species_text.dart';
import '../../model/house_store.dart';
import '../names.dart';

/// Localised text for ids that come from the simulations (bubbles, rooms,
/// journal reactions).
extension HouseText on AppLocalizations {
  String roomName(Room r) => switch (r) {
        Room.living => roomLiving,
        Room.spa => roomSpa,
        Room.kitchen => roomKitchen,
        Room.bedroom => roomBedroom,
        Room.playroom => roomPlayroom,
        Room.garden => roomGarden,
      };

  String bubble(String key) => switch (key) {
        'bubble.full' => bubbleFull,
        'bubble.oink' => bubbleOink,
        'bubble.oinkq' => bubbleOinkQuestion,
        'bubble.sneeze' || 'bubble.wuff.achoo' => bubbleAchoo,
        'bubble.combo10' => bubbleCombo10,
        'bubble.fresh' => bubbleFresh,
        'bubble.combo25' => bubbleCombo25,
        'bubble.combo50' => bubbleCombo50,
        'bubble.wuff.yip' => bubbleYip,
        'bubble.wuff.howl' => bubbleHowl,
        'bubble.wuff.whimper' => bubbleWhimper,
        'bubble.wuff.growl' => bubbleGrrr,
        'bubble.wuff.squeak' => bubbleSqueak,
        'bubble.wuff.pant' => bubblePant,
        'bubble.wuff.play' => bubblePlay,
        'bubble.wuff.hello' || 'bubble.wuff.bark' => bubbleWoof,
        _ => bubbleHi,
      };

  /// Journal name of a reaction id (`mofu.boing`, `oink.belly`, `house.pileUp`).
  String reactionName(String id) => reactionText(id).$1;

  /// (name, hint) for any reaction id, localised.
  (String, String) reactionText(String id) {
    if (id.startsWith('mofu.')) return reaction(id.substring(5));
    return speciesReaction(localeName, id) ?? (id, '');
  }
}

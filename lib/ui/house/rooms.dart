import '../../model/house_store.dart';
import 'room_context.dart';
import 'rooms/bedroom_room.dart';
import 'rooms/garden_room.dart';
import 'rooms/kitchen_room.dart';
import 'rooms/playroom_room.dart';
import 'rooms/spa_room.dart';

export 'friend_card.dart' show showFriendCard;
export 'settings_sheet.dart' show showHouseSettings;

class LivingRoom extends RoomModule {
  const LivingRoom();
}

final _modules = <Room, RoomModule>{
  Room.living: const LivingRoom(),
  Room.spa: SpaRoom(),
  Room.kitchen: KitchenRoom(),
  Room.bedroom: BedroomRoom(),
  Room.playroom: const PlayroomRoom(),
  Room.garden: GardenRoom(),
};

RoomModule roomModule(Room r) => _modules[r]!;

/// The bedroom lamp (others have no lamp to switch).
bool roomLampOn(Room r) => r == Room.bedroom ? BedroomRoom.lampOn.value : true;

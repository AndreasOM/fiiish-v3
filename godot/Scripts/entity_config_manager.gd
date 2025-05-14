extends Node
class_name EntityConfigManager

var _configs: Dictionary[ EntityId.Id, EntityConfig ] = {
	EntityId.Id.PICKUPCOIN: EntityConfig.new( "Coin", EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin.tscn") ),
	EntityId.Id.PICKUPRAIN: EntityConfig.new( "Rain", EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin_rain.tscn") ),
	EntityId.Id.PICKUPEXPLOSION: EntityConfig.new( "Explosion", EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin_explosion.tscn") ),
	EntityId.Id.PICKUPMAGNET: EntityConfig.new( "Magnet", EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/magnet.tscn") ),
	EntityId.Id.ROCKA: EntityConfig.new( "Rock A", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_a.tscn") ),
	EntityId.Id.ROCKB: EntityConfig.new( "Rock B", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_b.tscn") ),
	EntityId.Id.ROCKC: EntityConfig.new( "Rock C", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_c.tscn") ),
	EntityId.Id.ROCKD: EntityConfig.new( "Rock D", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_d.tscn") ),
	EntityId.Id.ROCKE: EntityConfig.new( "Rock E", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_e.tscn") ),
	EntityId.Id.ROCKF: EntityConfig.new( "Rock F", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_f.tscn") ),
	EntityId.Id.SEAWEEDA: EntityConfig.new( "SeaWeed A", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_a.tscn") ),
	EntityId.Id.SEAWEEDB: EntityConfig.new( "SeaWeed B", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_b.tscn") ),
	EntityId.Id.SEAWEEDC: EntityConfig.new( "SeaWeed C", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_c.tscn") ),
	EntityId.Id.SEAWEEDD: EntityConfig.new( "SeaWeed D", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_d.tscn") ),
	EntityId.Id.SEAWEEDE: EntityConfig.new( "SeaWeed E", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_e.tscn") ),
	EntityId.Id.SEAWEEDF: EntityConfig.new( "SeaWeed F", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_f.tscn") ),
	EntityId.Id.SEAWEEDG: EntityConfig.new( "SeaWeed G", EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_g.tscn") ),	
}


func get_entry( id: EntityId.Id ) -> EntityConfig:
	return self._configs.get( id )

func get_id_by_index( idx: int ) -> EntityId.Id:
	if idx >= self._configs.size():
		return EntityId.Id.INVALID
		
	return self._configs.keys()[ idx ]

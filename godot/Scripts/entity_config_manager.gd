extends Node
class_name EntityConfigManager

var _configs: Dictionary[ EntityId.Id, EntityConfig ] = {
	EntityId.Id.PICKUPCOIN: EntityConfig.new( EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin.tscn") ),
	EntityId.Id.PICKUPRAIN: EntityConfig.new( EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin_rain.tscn") ),
	EntityId.Id.PICKUPEXPLOSION: EntityConfig.new( EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/coin_explosion.tscn") ),
	EntityId.Id.PICKUPMAGNET: EntityConfig.new( EntityTypes.Id.PICKUP, preload("res://Scenes/Pickups/magnet.tscn") ),
	EntityId.Id.ROCKA: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_a.tscn") ),
	EntityId.Id.ROCKB: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_b.tscn") ),
	EntityId.Id.ROCKC: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_c.tscn") ),
	EntityId.Id.ROCKD: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_d.tscn") ),
	EntityId.Id.ROCKE: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_e.tscn") ),
	EntityId.Id.ROCKF: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/rock_f.tscn") ),
	EntityId.Id.SEAWEEDA: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_a.tscn") ),
	EntityId.Id.SEAWEEDB: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_b.tscn") ),
	EntityId.Id.SEAWEEDC: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_c.tscn") ),
	EntityId.Id.SEAWEEDD: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_d.tscn") ),
	EntityId.Id.SEAWEEDE: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_e.tscn") ),
	EntityId.Id.SEAWEEDF: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_f.tscn") ),
	EntityId.Id.SEAWEEDG: EntityConfig.new( EntityTypes.Id.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_g.tscn") ),	
}


func get_entry( id: EntityId.Id ) -> EntityConfig:
	return self._configs.get( id )

extends Node

signal user_info_required( steam_id: int )

signal user_name_updated( steam_id: int, name: String )
signal user_texture_updated( steam_id: int, texture: ImageTexture )

func broadcast_user_info_required( steam_id: int ):
	self.user_info_required.emit( steam_id )
#	broadcast_user_name_updated( steam_id, "DUMMY" )
	

func broadcast_user_name_updated( steam_id: int, name: String ):
	self.user_name_updated.emit( steam_id, name )
	
func broadcast_user_texture_updated( steam_id: int, texture: ImageTexture ):
	self.user_texture_updated.emit( steam_id, texture )
	

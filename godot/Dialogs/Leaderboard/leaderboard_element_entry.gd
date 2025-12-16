@tool

extends MarginContainer
class_name LeaderboardEntryElement

@export var rank: String = "" : set = _set_rank
@export var participant: String = "" : set = _set_participant
@export var score: String = "" : set = _set_score
@export var was_latest: bool = false : set = _set_was_latest
@export var duration: float = 0.3

@onready var avatar_texture_rect: TextureRect = %AvatarTextureRect

var _steam_id: int = -1
var _avatar_texture: ImageTexture = null

func _ready() -> void:
	_update_look()
	self._update()

func _set_was_latest( b: bool ) -> void:
	was_latest = b
	_update_look()

func _update_look() -> void:
	%RankLabel.highlighted = was_latest
	%ParticipantLabel.highlighted = was_latest
	%ScoreLabel.highlighted = was_latest

func _set_rank( r: String) -> void:
	rank = r
	%RankLabel.text = rank

func _set_participant( p: String ) -> void:
	participant = p
	if self.participant.begins_with("SteamId="):
		%ParticipantLabel.text = "?"
		self._steam_id = int(self.participant.trim_prefix("SteamId="))
		SteamEvents.user_name_updated.connect( _on_steam_user_name_updated )
		SteamEvents.user_texture_updated.connect( _on_steam_user_texture_updated )
		SteamEvents.broadcast_user_info_required( self._steam_id )
	else:
		self._steam_id = -1
		%ParticipantLabel.text = p

func _on_steam_user_name_updated( steam_id: int, name: String ):
	if self._steam_id != steam_id:
		return
		
	%ParticipantLabel.text = "%s" %[ name ]

func _on_steam_user_texture_updated( steam_id: int, texture: ImageTexture ):
	if self._steam_id != steam_id:
		return
	
	self._avatar_texture = texture
	self._update()
	
func _update() -> void:
	if(
			self.avatar_texture_rect != null
			&& self._avatar_texture != null
	):
		self.avatar_texture_rect.texture = self._avatar_texture
func _set_score( s: String) -> void:
	score = s
	%ScoreLabel.text = s

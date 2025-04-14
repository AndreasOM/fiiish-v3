class_name NewZoneLayerObject

var id: int = 0
var crc: int = 0
var pos_x: float = 0.0
var pos_y: float = 0.0
var rotation: float = 0.0

func serialize( s: Serializer ):
	self.id = s.serialize_u16( self.id )
	self.crc = s.serialize_u32( self.crc )
	self.pos_x = s.serialize_f32( self.pos_x )
	self.pos_y = -self.pos_y # :HACK:
	self.pos_y = s.serialize_f32( self.pos_y )
	self.pos_y = -self.pos_y # :HACK:
	self.rotation = s.serialize_f32( self.rotation )

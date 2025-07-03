class_name NewZoneLayer

var name: String = ""
var objects: SerializableArray = SerializableArray.new(
	func() -> NewZoneLayerObject:
		return NewZoneLayerObject.new() 
)

func serialize( s: Serializer ) -> bool:
	self.name = s.serialize_fixed_string( 16, self.name )
	self.objects.serialize( s )
	
	return true

func add_object( o: NewZoneLayerObject ) -> void:
	self.objects.push_back( o )

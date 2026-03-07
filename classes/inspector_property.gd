class_name InspectorProperty
extends Resource

@export var property_name: String
@export var value : Variant
@export var default_value: Variant

func reset(): value = default_value

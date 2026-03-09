extends Node

var timeline : Array[HistoryAction] = []
var index : int = 0

func commit(action):
	if index < timeline.size():
		timeline = timeline.slice(0, index)
	
	if action.get("id") != null:
		print("ACTION: ", action.name, ", ID: ", action.id)
	else:
		print("ACTION: ", action.name)
	
	timeline.append(action)
	index += 1

func undo():
	if index == 0:
		return
	
	print("UNDO")
	#print(timeline)
	#print(index)
	index -= 1
	timeline[index].undo()

func redo():
	if index >= timeline.size():
		return
	
	print("REDO")
	#print(timeline)
	#print(index)
	timeline[index].redo()
	index += 1

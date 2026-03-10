extends Node

var timeline : Array[HistoryAction] = []
var index : int = 0

func commit(action):
	if index < timeline.size():
		timeline = timeline.slice(0, index)
	
	if action.get("id") != null:
		if Constants.DEV_MODE: print("ACTION: ", action.name, ", ID: ", action.id)
	else:
		if Constants.DEV_MODE: print("ACTION: ", action.name)
	
	timeline.append(action)
	index += 1

func undo():
	if index == 0:
		return
	
	#print(timeline)
	#print(index)
	index -= 1
	timeline[index].undo()
	if timeline[index].get("id") != null:
		if Constants.DEV_MODE: print("UNDO: ", timeline[index].name, ", ID: ", timeline[index].id)
	else:
		if Constants.DEV_MODE: print("UNDO: ", timeline[index].name)

func redo():
	if index >= timeline.size():
		return
	
	#print(timeline)
	#print(index)
	timeline[index].redo()
	if timeline[index].get("id") != null:
		if Constants.DEV_MODE: print("REDO: ", timeline[index].name, ", ID: ", timeline[index].id)
	else:
		if Constants.DEV_MODE: print("REDO: ", timeline[index].name)
	index += 1

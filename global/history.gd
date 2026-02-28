extends Node

var timeline : Array[HistoryAction] = []
var index : int = 0

func commit(action):
	if index < timeline.size():
		timeline = timeline.slice(0, index)

	timeline.append(action)
	index += 1

func undo():
	if index == 0:
		return
	
	index -= 1
	timeline[index].undo()

func redo():
	if index >= timeline.size():
		return
	
	timeline[index].redo()
	index += 1

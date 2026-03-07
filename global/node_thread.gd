extends Node

var thread : Thread
var mutex := Mutex.new()
var semaphore := Semaphore.new()

var jobs : Array[Callable] = []
var running := true

func _worker():
	while running:
		semaphore.wait()

		mutex.lock()
		if jobs.is_empty():
			mutex.unlock()
			continue

		var job : Callable = jobs.pop_front()
		mutex.unlock()

		job.call()

func _ready():
	thread = Thread.new()
	thread.start(_worker)

func run(callable : Callable):
	mutex.lock()
	jobs.append(callable)
	mutex.unlock()

	semaphore.post()

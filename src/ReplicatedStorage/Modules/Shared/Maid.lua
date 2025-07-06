-- TOLIS MAID SYSTEM V1

local Maid = {}
Maid.__index = Maid

function Maid.New()
	local self = setmetatable({}, Maid)
	self._tasks = {}
	return self
end

-- // Gives single connection to maid
function Maid:GiveTask(task: any): ()
	assert(task, "Given Task to maid is NIL")

	local taskId = #self._tasks + 1
	self._tasks[taskId] = task
end

-- // Gives single connection to maid with a key
function Maid:GiveTaskID(key: string, task: any): ()
	assert(task, "Given Task to maid is NIL")
	assert(key, "Given Key to maid is NIL")

	self:CleanUp(key)
	self._tasks[key] = task
end

-- // Cleans up connections
function Maid:CleanUp(key: any): ()
	if key then
		local task = self._tasks[key]

		if task then
			self._Clean(task)
			self._tasks[key] = nil
		end
	else
		for k, v in pairs(self._tasks) do
			self._Clean(v)
			self._tasks[k] = nil
		end
	end
end

-- // Clean function for maid
function Maid._Clean(task: any)
	if typeof(task) == "RBXScriptConnection" then
		if task.Connected then
			task:Disconnect()
		end
	elseif typeof(task) == "function" then
		task()
	elseif typeof(task) == "Instance" then
		task:Destroy()
	end

	if typeof(task) == "thread" then
		if coroutine.status(task) == "suspended" then
			coroutine.close(task)
		end
	end
end

return Maid

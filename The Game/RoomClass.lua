Room = {}
Room.__index = Room

function Room.new(row,col,botCol,botRow)
	r = {}   -- create object if user does not provide one
    setmetatable(r, Room)
	self.row = row
	self.col = col
	self.botCol = botCol
	self.botRow = botRow
	
	return r
end
function Room:connectRooms(firstRoom,secondRoom)

	
end

function Room:getRow()
	return self.row
end
function Room:getCol()
	return self.col
end
function Room:getBotRow()
	return self.botRow
end
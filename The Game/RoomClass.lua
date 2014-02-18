Room = {}
Room.__index = Room

function Room.new(row,col,botCol,botRow)
	r = {}   -- create object if user does not provide one
    setmetatable(r, Room)
	r.row = row
	r.col = col
	r.botCol = botCol
	r.botRow = botRow
	
	return r
end

function Room:connectRooms(secondRoom)
	row = self.row
	column = self.col
	targetRow = secondRoom:getRow()
	targetCol = secondRoom:getCol()
	while(column ~= targetColumn and row ~= targetRow)do
		if(row < targetRow)then
			row = row + 1
			adjMatrix[column][row] = 1
			adjMatrix[column+1][row] = 1
		elseif(row > targetRow)then
			row = row - 1
			adjMatrix[column][row] = 1
			adjMatrix[column+1][row] = 1
		end
		if(column < targetCol)then
			column = column + 1
			adjMatrix[column][row] = 1
			adjMatrix[column][row+1] = 1
		elseif(column > targetCol)then
			column = column - 1
			adjMatrix[column][row] = 1
			adjMatrix[column][row+1] = 1
		end
		adjMatrix[column][row] = 1
	end
	
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
function Room:getbotCol()
	return self.botCol
end
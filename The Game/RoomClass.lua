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
	while(row ~= targetRow)do
		if(row < targetRow)then
			--shift the point to the right and make a tile there and at the spot above it to the right
			row = row + 1
			adjMatrix[column][row] = 1
			adjMatrix[column+1][row] = 1
		elseif(row > targetRow)then
			--shift the room point to the left and make a tile there and at the spot below it
			row = row - 1
			adjMatrix[column][row] = 1
			adjMatrix[column+1][row] = 1
		end
	end--end of while
	while(column ~= targetCol)do
		if(column < targetCol)then
			--shift the room down a row and then make a tile there and to the right
			column = column + 1
			adjMatrix[column][row] = 1
			adjMatrix[column][row+1] = 1
		elseif(column > targetCol)then
			--shift the room up a row and then make it and a column to the right
			column = column - 1
			adjMatrix[column][row] = 1
			adjMatrix[column][row+1] = 1
		end
	end--end of while loop
	
end--end of function Room:connectRooms(secondRoom)

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
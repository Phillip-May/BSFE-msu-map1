//Overwrite the value for limited starts in the header
//Allows for game to played more than 0 times.
	origin $007FD5
	db $00
	
//Overwrite the Japanese header title with english
//Header is in shift japanese so it supports normal text encoding
//	"BSFE MAP 1"
	origin $007FC0
	db	"BSFE MAP 1"
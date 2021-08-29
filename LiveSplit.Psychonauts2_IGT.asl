state("Psychonauts2-Win64-Shipping")
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x512A97C;
}
start
{
}

split
{

}

isLoading
{
	return current.isLoading;
}

exit
{
	timer.IsGameTimePaused = true;
} 

init
{
	timer.IsGameTimePaused = false;
}

gameTime
{
}

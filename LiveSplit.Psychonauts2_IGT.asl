state("Psychonauts2-Win64-Shipping", "Steam1086854")			
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x512A97C;	//Steam Patch 1 Loading pointer
}
state("Psychonauts2-Win64-Shipping", "Steam1087071")			
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x0556DE20, 0x40, 0x30, 0x18, 0x328, 0x390, 0x170, 0x8;	//Steam Patch 2 Loading Pointer
}
state("Psychonauts2-Win64-Shipping", "DRMFree")
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x4E8159C;	//Humble/GoG Launch Patch Loading pointer
}
state("Psychonauts2-WinGDK-Shipping", "Gamepass")
{
	bool isLoading : "Psychonauts2-WinGDK-Shipping.exe", 0x4D6210C; //Gamepass Launch Patch Loading pointer
}
start
{
}
init
{
	timer.IsGameTimePaused = false;

	switch (modules.First().ModuleMemorySize)
	{
		case 92176384:					//Humble, GoG launch version
			version = "DRMFree";			
			break;
		case 95219712:
			version = "Steam1086854";		//Steam patch 1
			break;
		case 95236096:
			version = "Steam1087071";		//Steam patch 2
			break;
		case 390800128:
			version = "Gamepass";			//Gamepass Launch version
			break;
	}

	print("ModuleMemorySize: " + modules.First().ModuleMemorySize.ToString()); //Used to find the Memory Size of the game.
}
isLoading
{
	return current.isLoading;
}
exit
{
	timer.IsGameTimePaused = true;
}
gameTime
{
}
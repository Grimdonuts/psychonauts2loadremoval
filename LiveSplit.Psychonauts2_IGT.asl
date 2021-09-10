state("Psychonauts2-Win64-Shipping", "Steam1086854")			
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x512A97C;	//Steam Patch 1 Loading pointer
}
state("Psychonauts2-Win64-Shipping", "Steam1087071")			
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x0553D168, 0x8, 0x5E0, 0x30;    //Steam Patch 2 Loading Pointer
}
state("Psychonauts2-Win64-Shipping", "Steam1087126")			
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x05333880, 0x2D0, 0x1C0, 0x448, 0x30;    //Steam Patch 2 Loading Pointer
}
state("Psychonauts2-Win64-Shipping", "DRMFree")
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x052754E8, 0x8, 0x5E0, 0x30;	//Humble/GoG Launch Patch Loading pointer
}
state("Psychonauts2-Win64-Shipping", "DRMFree1087071")
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x05278568, 0x8, 0x5E0, 0x30;	//Humble/GoG Patch 1 Loading pointer
}
state("Psychonauts2-Win64-Shipping", "DRMFree1087126")
{
	bool isLoading : "Psychonauts2-Win64-Shipping.exe", 0x05278568, 0x8, 0x5E0, 0x30;	//Humble/GoG Patch 2 Loading pointer
}
state("Psychonauts2-WinGDK-Shipping", "Gamepass")
{
	bool isLoading : "Psychonauts2-WinGDK-Shipping.exe", 0x0506FCA0, 0x2D0, 0x1C0, 0x448, 0x30; //Gamepass Launch Patch Loading pointer
}
start
{
}
init
{
	timer.IsGameTimePaused = false;

	switch (modules.First().ModuleMemorySize)
	{
		case 92176384:						//Humble, GoG launch version
			version = "DRMFree";
			break;
		case 92188672:
			version = "DRMFree1087071";		//GOG Patch 1
			break;
		case 92196864:
			version = "DRMFree1087126";		//GOG Patch 2
			break;
		case 95219712:
			version = "Steam1086854";		//Steam patch 1
			break;
		case 95236096:
			version = "Steam1087071";		//Steam patch 2
			break;
		case 95240192:
			version = "Steam1087126";		//Steam patch 3
			break;
		case 390800128:
			version = "Gamepass";			//Gamepass Launch version
			break;
	}

	// print("ModuleMemorySize: " + modules.First().ModuleMemorySize.ToString()); //Used to find the Memory Size of the game.
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
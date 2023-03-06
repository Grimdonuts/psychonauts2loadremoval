state("Psychonauts2-Win64-Shipping"){}
state("Psychonauts2-WinGDK-Shipping"){}

startup
{
	vars.Log = (Action<object>)((output) => print("[P2] " + output));

	// Code by Micrologist
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Psychonauts 2",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
		var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
		var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
		if (textSetting == null)
		{
			var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
			var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
			timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
			textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
			textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
		}
		if (textSetting != null)
			textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});

	settings.Add("SEQ_LOBO_CBFINI", true, "Loboto's Labyrinth");
	settings.Add("SEQ_HQIN_HSCENT", true, "Hub 1");
	settings.Add("SEQ_HOLLCLASS_HS1OUT", true, "Hollis' Classroom");
	settings.Add("SEQ_HOLLCASINO_HSFINI", true, "Hollis' Hot Streak");
	settings.Add("SEQ_HOLL_LLSHRB", true, "Casino");
	settings.Add("SEQ_FORV_HQFPOP", true, "Ford 1");
	settings.Add("SEQ_QUAR_QCLIFF", true, "Quarry");
	settings.Add("SEQ_QUAR_QRCOIN", true, "Enter Compton's Mind");
	settings.Add("SEQ_COMPT_CPBFOU", true, "Compton's Cookoff");
	settings.Add("SEQ_FORH_FHOUTR", true, "Ford's Follicles");
	settings.Add("SEQ_FORB_FBOUTR", true, "Strike City");
	settings.Add("SEQ_HELM_HMBVIC", true, "Psi King");
	settings.Add("SEQ_FORV_FVGINT", true, "Cruller's Correspondence");
	settings.Add("SEQ_FORG_FGGDMA", true, "Sharkophagus");
	settings.Add("SEQ_BOBZ_BBMIND", true, "Enter Bob's Mind");
	settings.Add("SEQ_BOBZ_BBOUTR", true, "Bob's Bottles");
	settings.Add("SEQ_HUB2_OCPORT", true, "Enter Cassie's Mind");
	settings.Add("SEQ_CASS_CSOUTR", true, "Cassie's Collection");
	settings.Add("SEQ_MALI_MAOUTR", true, "Lucrecia's Lament");
	settings.Add("SEQ_GRIS_GRLIFS", true, "Fatherland Follies");

	settings.Add("subsplits", false, "Subsplits");
	settings.Add("psiKing", false, "Psi King", "subsplits");
	settings.Add("sub SEQ_HELM_HMGUIT", false, "Vision", "psiKing");
	settings.Add("sub SEQ_HELM_HMNMIN", false, "Mouth Nose", "psiKing");
	settings.Add("sub SEQ_HELM_HMTHIN", false, "Ear Hand", "psiKing");

	settings.Add("bobsBottles", false, "Bob's Bottles", "subsplits");
	settings.Add("sub SEQ_BOBZ_BBTISD", false, "Tia's Bottle", "bobsBottles");
	settings.Add("sub SEQ_BOBZ_BBTRSD", false, "Truman's Bottle", "bobsBottles");
	settings.Add("sub SEQ_BOBZ_BBHLSD", false, "Helmut's Bottle", "bobsBottles");

	settings.Add("cassiesCollection", false, "Cassie's Collection", "subsplits");
	settings.Add("sub SEQ_CASS_CSCLNC", false, "Children's Corner", "cassiesCollection");
	settings.Add("sub SEQ_CASS_NOCODE_OpenWaterfrontDoor_CassieOffice", false, "Literature Lane", "cassiesCollection");

	settings.Add("lucrecia", false, "Lucrecia's Lament", "subsplits");
	settings.Add("sub SEQ_MALI_MAHDJP", false, "Circus", "lucrecia");

	settings.Add("debug", false, "[DEBUG] Show tracked values on overlay");
}

init
{
	timer.IsGameTimePaused = false;

	vars.CancelSource = new CancellationTokenSource();
	vars.ScanThread = new Thread(() =>
	{
		vars.Log("Starting scan thread.");

		var gWorld = IntPtr.Zero;
		var gWorldTrg = new SigScanTarget(10, "80 7C 24 ?? 00 ?? ?? 48 8B 3D ???????? 48")
		{ OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr) };

		var scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);
		var token = vars.CancelSource.Token;

		while (!token.IsCancellationRequested)
		{
			if (gWorld == IntPtr.Zero && (gWorld = scanner.Scan(gWorldTrg)) != IntPtr.Zero)
			{
				vars.Data = new MemoryWatcherList
				{
					new MemoryWatcher<bool>(new DeepPointer(gWorld, 0x180, 0x6C0, 0x30)) { Name = "Loading" },
					new MemoryWatcher<int>(new DeepPointer(gWorld, 0x180, 0x488, 0x80, 0x10)) { Name = "SequenceID" },
					new StringWatcher(new DeepPointer(gWorld, 0x4A0, 0x14), 255) { Name = "World" },
				};

				vars.Log("Found GWorld at 0x" + gWorld.ToString("X") + ".");
				break;
			}

			Thread.Sleep(2000);
		}

		vars.Log("Exitng scan thread.");
	});

	vars.ScanThread.Start();

	vars.OldSequenceName = string.Empty;
	vars.CurrentSequenceName = string.Empty;

	Int32 gNameBlocksDebugOffset = 0;
	switch (modules.First().ModuleMemorySize)
	{
		case 95350784: // Steam version 1101213
			gNameBlocksDebugOffset = 88113424;
			break;
		case 90849280: // Xbox store version 1101128
			gNameBlocksDebugOffset = 84018256;
			break;
		case 92307456: // DRM-free version 1095580
			gNameBlocksDebugOffset = 85210320;
			break;
		default:
			break;
	}

	Func<int, string> FNameToString = (comparisonIndex) =>
	{
		if (gNameBlocksDebugOffset == 0)
		{
			return null;
		}

		var blockIndex = comparisonIndex >> 16;
		var blockOffset = 2 * (comparisonIndex & 0xFFFF);
		var headerPtr = new DeepPointer(gNameBlocksDebugOffset + blockIndex * 8, blockOffset);

		byte[] headerBytes = null;
		if (headerPtr.DerefBytes(game, 2, out headerBytes))
		{
			bool isWide = (headerBytes[0] & 0x01) != 0;
			int length = (headerBytes[1] << 2) | ((headerBytes[0] & 0xC0) >> 6);

			IntPtr headerRawPtr;
			if (headerPtr.DerefOffsets(game, out headerRawPtr))
			{
				var stringPtr = new DeepPointer(headerRawPtr + 2);
				ReadStringType stringType = isWide ? ReadStringType.UTF16 : ReadStringType.ASCII;
				int numBytes = length * (isWide ? 2 : 1);

				string str;
				if (stringPtr.DerefString(game, stringType, numBytes, out str))
				{
					return str;
				}
			}
		}

		return null;
	};

	Func<string, string> GetObjectNameFromObjectPath = (objectPath) =>
	{
		if (objectPath == null)
		{
			return null;
		}

		int lastDotIndex = objectPath.LastIndexOf('.');
		if (lastDotIndex == -1)
		{
			return objectPath;
		}

		return objectPath.Substring(lastDotIndex + 1);
	};

	Func<int, string> GetObjectNameFromFName = (comparisonIndex) =>
	{
		return GetObjectNameFromObjectPath(FNameToString(comparisonIndex));
	};
	vars.GetObjectNameFromFName = GetObjectNameFromFName;
}

isLoading
{
	return vars.Data["Loading"].Current;
}

exit
{
	timer.IsGameTimePaused = true;
}

update
{
	if (vars.ScanThread.IsAlive) return false;

	vars.Data.UpdateAll(game);

	vars.OldSequenceName = vars.GetObjectNameFromFName(vars.Data["SequenceID"].Old);
	vars.CurrentSequenceName = vars.GetObjectNameFromFName(vars.Data["SequenceID"].Current);

	if (settings["debug"])
	{
		vars.SetTextComponent("--------------DEBUG--------------", "");
		vars.SetTextComponent("ID:", vars.Data["SequenceID"].Current.ToString());
		vars.SetTextComponent("Name:", vars.CurrentSequenceName);
		vars.SetTextComponent("World:", vars.Data["World"].Current);
		vars.SetTextComponent("Loading:", vars.Data["Loading"].Current.ToString());
	}
	
}

start
{
	if (vars.Data["World"].Current == "/Entry/Entry")
		return (vars.CurrentSequenceName == "SEQ_LOBO_CBLOAD");
}

split
{
	// Maligula ending split
	if (vars.OldSequenceName == "SEQ_BOSS_MALBIG_EndPhase2" && vars.CurrentSequenceName == "SEQ_BOSS_MAFINI_MaligDefeat")
		return true;

	// Split on loads
	if (vars.Data["Loading"].Old == false && vars.Data["Loading"].Current == true)
		return settings[vars.CurrentSequenceName];

	// Split on sequence change (cutscenes, dialogue)
	if (settings["subsplits"])
	{
		if (vars.Data["SequenceID"].Old != vars.Data["SequenceID"].Current)
			return settings["sub " + vars.CurrentSequenceName];
	}
}
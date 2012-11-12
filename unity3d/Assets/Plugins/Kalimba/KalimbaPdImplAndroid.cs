using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;

public class KalimbaPdImplAndroid : KalimbaPdImplAbstract
{

#if UNITY_ANDROID
	private void _sendBangToReceiver (string receiverName)
	{
		AndroidJavaClass jc = new AndroidJavaClass("org.puredata.core.PdBase");
		jc.CallStatic<int>("sendBang", receiverName);
	}

	private void _sendFloat (float val, string receiverName)
	{
		AndroidJavaClass jc = new AndroidJavaClass("org.puredata.core.PdBase");
		jc.CallStatic<int>("sendFloat", receiverName, val);
	}
	
	private void _sendSymbol (string symbol, string receiverName)
	{
		AndroidJavaClass jc = new AndroidJavaClass("org.puredata.core.PdBase");
		jc.CallStatic<int>("sendSymbol", receiverName, symbol);
	}
	
	/// <summary>
	/// _opens the file.
	/// </summary>
	/// <returns>
	/// The file.
	/// </returns>
	/// <param name='baseName'>
	/// Base name.
	/// </param>
	/// <param name='pathName'>
	/// Path name. Relative directory in StreamingAssets
	/// </param>
	private int _openFile (string baseName, string pathName)
	{
		// spawn files from path
		foreach(string path in listAssetsContent(pathName))
		{
			string newFilePath = copyFromStreamingAssetsIntoPersistant(path);
			
			if (newFilePath.Substring(newFilePath.Length - 3) == ".pd")
			{
				// oggread path hack
				Debug.Log("MATCHING PD FILE " + newFilePath);
				
				string t = File.ReadAllText(newFilePath);
				
				// patch ogg paths
				// #X msg 36 45 open 1.ogg;
				Regex pOgg = new Regex(@"#X msg ([0-9]+) ([0-9]+) open (.*[/\\])?([^/\\;]+);", RegexOptions.Multiline);
				t = pOgg.Replace(t, "#X msg $1 $2 open " + Application.persistentDataPath + "/pd/$4;");
				
				// patch wav paths
				// #X msg 792 390 read -resize /Volumes/3rd PROJECTS/2012/tridek/tridek_git/unity3d-tridek/Assets/StreamingAssets/pd/sfx_gui_button.wav
				Regex pWav = new Regex(@"#X msg ([0-9]+) ([0-9]+) read -resize (.*[/\\])?([^/\\;]+)\s+([^/\\;]+);", RegexOptions.Multiline);
				t = pWav.Replace(t, "#X msg $1 $2 read -resize " + Application.persistentDataPath + "/pd/$4 $5;");

				File.WriteAllText(newFilePath, t);
			}
		}
		
		string file = Application.persistentDataPath + "/" + pathName + "/" + baseName;
		
		AndroidJavaClass jc = new AndroidJavaClass("org.puredata.core.PdBase");
		return jc.CallStatic<int>("openPatch", file);
	}

	private void _closeFile (int patchId)
	{
		AndroidJavaClass jc = new AndroidJavaClass("org.puredata.core.PdBase");
		jc.CallStatic("closePatch", patchId);
	}
	
	public string copyFromStreamingAssetsIntoPersistant(string p)
	{
		string filepath = Application.persistentDataPath + "/" + p;

		WWW f = new WWW ("jar:file://" + Application.dataPath + "!/assets/" + p);  // this is the path to your StreamingAssets in android
		
		// CAREFUL here, for safety reasons you shouldn't let this while loop unattended, place a timer and error check
		while (!f.isDone) {
		}  

		// then save to Application.persistentDataPath
		var fileDirectoryParts = filepath.Split('/');
		if (fileDirectoryParts.Length > 1)
		{
			string directory = string.Join("/", fileDirectoryParts.Take(fileDirectoryParts.Length - 1).ToArray());
			Directory.CreateDirectory(directory);
		}
		
		File.WriteAllBytes (filepath, f.bytes);
		
		return filepath;
	}
	
	private List<string> listAssetsContent(string path)
	{
		AndroidJavaClass jc = new AndroidJavaClass("com.bitbarons.kalimba.KalimbaActivity");
		AndroidJavaObject l = jc.CallStatic<AndroidJavaObject>("listAssetsContent", path);
		
		int size = l.Call<int>("size");
		
		List<string> assets = new List<string>();
		
		for(int i = 0; i < size; ++i)
		{
			string x = l.Call<string>("get", i);
			assets.Add(x);
			//Debug.Log(string.Format("listAssetsContent {0}", x));
		}		
		
		return assets;
	}
	
	private void _init (){

	}
#endif
	
	/* Public interface for use inside C# / JS code */
	
	public override void CloseFile(int patchId)
	{
#if UNITY_ANDROID
		_closeFile(patchId);
#endif
	}
	
	public override int OpenFile(string baseName, string pathName)
	{
#if UNITY_ANDROID
		return _openFile(baseName, pathName);
#else
		return 0;
#endif
	}
	
	public override void SendBangToReceiver(string receiverName)
	{
#if UNITY_ANDROID
		_sendBangToReceiver(receiverName);
#endif
	}
	
	public override void SendFloat(float val, string receiverName)
	{
#if UNITY_ANDROID
		_sendFloat(val, receiverName);
#endif
	}
	
	public override void SendSymbol(string symbol, string receiverName)
	{
#if UNITY_ANDROID
		_sendSymbol(symbol, receiverName);
#endif
	}
	
	public override void Init()
	{
#if UNITY_ANDROID
		_init();
#endif
	}
}

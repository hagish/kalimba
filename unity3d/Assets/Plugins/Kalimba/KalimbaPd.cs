using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public static class KalimbaPd {
	private static KalimbaPdImplAbstract impl;
	
	private static void setup()
	{
		if (impl == null)
		{
			if (Application.platform == RuntimePlatform.Android)
			{
				impl = new KalimbaPdImplAndroid();
			}
			else if (Application.platform == RuntimePlatform.IPhonePlayer)
			{
				impl = new KalimbaPdImplIOs();
			}
			else {
				impl = new KalimbaPdImplNetwork();
			}
		}
	}
	
	public static void CloseFile(int patchId)
	{
		if (impl != null)impl.CloseFile(patchId);
	}
	
	public static int OpenFile(string baseName, string pathName)
	{
		if (impl != null)return impl.OpenFile(baseName, pathName);
		else return 0;
	}
	
	public static void SendBangToReceiver(string receiverName)
	{
		if (impl != null)impl.SendBangToReceiver(receiverName);
	}
	
	public static void SendFloat(float val, string receiverName)
	{
		if (impl != null)impl.SendFloat(val, receiverName);
	}
	
	public static void SendSymbol(string symbol, string receiverName)
	{
		if (impl != null)impl.SendSymbol(symbol, receiverName);
	}
	
	public static void Init()
	{
		setup();
		if (impl != null)impl.Init();
	}
}

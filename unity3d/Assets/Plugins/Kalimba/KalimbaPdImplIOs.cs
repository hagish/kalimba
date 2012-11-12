using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class KalimbaPdImplIOs : KalimbaPdImplAbstract {
#if UNITY_IPHONE
	[DllImport ("__Internal")]
	private static extern void _sendBangToReceiver (string receiverName);

	[DllImport ("__Internal")]
	private static extern void _sendFloat (float val, string receiverName);
	
	[DllImport ("__Internal")]
	private static extern void _sendSymbol (string symbol, string receiverName);
	
	[DllImport ("__Internal")]
	private static extern int _openFile (string baseName, string pathName);

	[DllImport ("__Internal")]
	private static extern int _closeFile (int patchId);
	
	private static void _init (){}
#endif
	
	/* Public interface for use inside C# / JS code */
	
	public override void CloseFile(int patchId)
	{
#if UNITY_IPHONE
		_closeFile(patchId);
#endif
	}
	
	public override int OpenFile(string baseName, string pathName)
	{
#if UNITY_IPHONE
		// TODO currently there is no automatic workflow for ios
		return _openFile(baseName, ".");
#else
		return 0;
#endif
	}
	
	public override void SendBangToReceiver(string receiverName)
	{
#if UNITY_IPHONE
		_sendBangToReceiver(receiverName);
#endif
	}
	
	public override void SendFloat(float val, string receiverName)
	{
#if UNITY_IPHONE
		_sendFloat(val, receiverName);
#endif
	}
	
	public override void SendSymbol(string symbol, string receiverName)
	{
#if UNITY_IPHONE
		_sendSymbol(symbol, receiverName);
#endif
	}
	
	public override void Init()
	{
#if UNITY_IPHONE
		_init();
#endif
	}
}

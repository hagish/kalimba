using System;

public abstract class KalimbaPdImplAbstract
{
	public abstract void CloseFile(int patchId);
	public abstract int OpenFile(string baseName, string pathName);
	public abstract void SendBangToReceiver(string receiverName);
	public abstract void SendFloat(float val, string receiverName);
	public abstract void SendSymbol(string symbol, string receiverName);
	public abstract void Init();
}

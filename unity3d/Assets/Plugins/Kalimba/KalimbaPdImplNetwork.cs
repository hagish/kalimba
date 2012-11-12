using UnityEngine;
using System;
using System.Collections;
using System.IO;
using System.Text;
using System.Net.Sockets;

public class KalimbaPdImplNetwork : KalimbaPdImplAbstract
{
    private TcpClient client;
	private Stream stream;
	private ASCIIEncoding asciiEncoding;
	
	private string host;
	private int port;
	
	/// <summary>
	/// if true errors wont get printed.
	/// Purpose is to only display connect errors once.
	/// </summary>
	private bool suppressErrors = false;
	
	public KalimbaPdImplNetwork()
	{
		asciiEncoding = new ASCIIEncoding();
		host = "127.0.0.1";
		port = 32000;		
	}
	
	private void setup()
	{
		if (client == null || client.Connected == false)
		{
			try {
				if (suppressErrors == false)Debug.Log("trying to connect to " + host + ":" + port);
				client = new TcpClient();
				client.Connect(host, port);
			
				if (stream != null)stream.Dispose();
				stream = client.GetStream();
				suppressErrors = false;
			}
			catch(Exception e)
			{
				error("network error: " + e.Message);
				if (stream != null)stream.Dispose();
				stream = null;
				client = null;
			}
		}
	}
	
	private void error(string text)
	{
		if (suppressErrors == false)
		{
			Debug.LogWarning(text);
			suppressErrors = true;
		}
	}
	
	public override void CloseFile(int patchId)
	{
		setup();
		Debug.LogWarning("closing patch");
	}
	
	public override int OpenFile(string baseName, string pathName)
	{
		setup();
		Debug.LogWarning("you need to manually open patch " + baseName + " at " + pathName);
		return 1;
	}
	
	// no need adding a closing ;
	private void sendPdMessage(string message)
	{
		if (client != null && client.Connected && stream != null)
		{
	        byte[] ba = asciiEncoding.GetBytes(message.Trim().TrimEnd(new char[]{';'}).Trim() + ";");
	
	        stream.Write(ba, 0, ba.Length);
			suppressErrors = false;
		}
		else
		{
			error("could not send message " + message + " to " + client);
		}
	}
	
	private void constructAndSendMessagesToSendMessage(string message)
	{
		sendPdMessage("set;");
		sendPdMessage("addsemi;");
		sendPdMessage("add " + message);
		sendPdMessage("bang;");
	}
	
	public override void SendBangToReceiver(string receiverName)
	{
		setup();
		constructAndSendMessagesToSendMessage(receiverName + " bang");
	}
	
	public override void SendFloat(float val, string receiverName)
	{
		setup();
		constructAndSendMessagesToSendMessage(receiverName + " " + val.ToString());
	}
	
	public override void SendSymbol(string symbol, string receiverName)
	{
		setup();
		constructAndSendMessagesToSendMessage(receiverName + " " + symbol);
	}
	
	public override void Init()
	{
		setup();
	}
}

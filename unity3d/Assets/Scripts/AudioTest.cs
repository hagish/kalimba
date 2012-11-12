using UnityEngine;

using System.Collections;

using System.IO;

using System.Text;

public class AudioTest : MonoBehaviour
{
	void Start ()
	{
		KalimbaPd.Init();
		
		KalimbaPd.OpenFile("kalimbaTest.pd", "pd");
	}

	void OnGUI ()
	{
		if (GUI.Button (new Rect (10, 10, 100, 50), "sine_on")) 
		{
			KalimbaPd.SendBangToReceiver("sine_on");
		}
		
		if (GUI.Button (new Rect (10, 10+50+10, 100, 50), "sine_off")) 
		{
			KalimbaPd.SendBangToReceiver("sine_off");
		}

		if (GUI.Button (new Rect (10, 10+50+10+50+10, 100, 50), "oggtest")) 
		{
			KalimbaPd.SendBangToReceiver("startogg");
		}
	}
}

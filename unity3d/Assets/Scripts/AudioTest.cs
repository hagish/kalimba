using UnityEngine;

using System.Collections;

using System.IO;

using System.Text;

public class AudioTest : MonoBehaviour
{
	private float hSliderValue = 0.5f;

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

		hSliderValue = GUI.HorizontalSlider (new Rect (10, 10+180, 100, 50), hSliderValue, 0.0f, 1.0f);
                KalimbaPd.SendFloat(hSliderValue, "myAmp");

		GUI.Label (new Rect (20, 200, 100, 50), "Volume [0..1]");
	}
}
